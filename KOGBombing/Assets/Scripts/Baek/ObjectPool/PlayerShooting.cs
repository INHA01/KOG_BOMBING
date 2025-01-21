using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.UIElements;

public class PlayerShooting : MonoBehaviour
{
    [Header("AttackRange")]
    [SerializeField] Transform shootStartPos;
    [SerializeField] Transform shootEndPos;
    [SerializeField] GameObject attackRangePrefab;
    [SerializeField] GameObject noAttackRangePrefab;
    [SerializeField] GameObject maxAttackRangePrefab;
    [SerializeField] float maxLength;

    GameObject attackRange;
    GameObject noAttackRange;
    GameObject maxAttackRange;

    LineRenderer lineRenderer1;
    LineRenderer lineRenderer2;
    DecalProjector decalProjector;

    public Vector3 attackPoint;

    [Header("Bullet")]
    [SerializeField] int InitbulletCount = 9;
    [SerializeField] int InitmagazineCount = 4;
    int bulletCount;
    int magazineCount;
    [SerializeField] float reloadTime;
    [SerializeField] float shootingTerm;

    Coroutine shootingCoroutine;
    Coroutine reloadCoroutine;
    Magazine magazine;

    [SerializeField]
    PhotonView pv;
    [SerializeField]
    bool canConnectPhoton = true;

    PlayerAnimation animator;

    private void FixedUpdate()
    {
        if (canConnectPhoton && !pv.IsMine) return;
        ShowAttackArea();
    }
    public void Init(Transform model)
    {
        bulletCount = InitbulletCount;
        magazineCount = InitmagazineCount;
        magazine = GetComponent<Magazine>();
        if (!canConnectPhoton || (pv != null && pv.IsMine))
        {
            attackRange = Instantiate(attackRangePrefab);
            lineRenderer1 = attackRange.GetComponent<LineRenderer>();
            lineRenderer1.startWidth = 2.0f * this.transform.localScale.x;
            lineRenderer1.endWidth = 2.0f * this.transform.localScale.x;
            attackRange.transform.SetParent(model);

            noAttackRange = Instantiate(noAttackRangePrefab);
            lineRenderer2 = noAttackRange.GetComponent<LineRenderer>();
            lineRenderer2.startWidth = 2.0f * this.transform.localScale.x;
            lineRenderer2.endWidth = 2.0f * this.transform.localScale.x;
            noAttackRange.transform.SetParent(model);

            maxAttackRange = Instantiate(maxAttackRangePrefab);
            maxAttackRange.transform.SetParent(model);
            maxAttackRange.transform.position = (shootStartPos.position + shootEndPos.position) / 2;
            maxAttackRange.SetActive(false);
            decalProjector = maxAttackRange.GetComponent<DecalProjector>();
            decalProjector.size = new Vector3(maxLength, 5 , 0.2f);
            Debug.Log("maxAttackRange: " + maxAttackRange.transform.position);
            Debug.Log("shootMagnitude: " + (shootEndPos.position - shootStartPos.position).magnitude);
        }
    }
    #region Attack area
    public void SetPoint(LineRenderer area ,Vector3 start, Vector3 end)
    {
        area.SetPosition(0, start);
        area.SetPosition(1, end);
    }
    void ShowAttackArea()
    {
        Vector3 direction = attackPoint - new Vector3(shootStartPos.position.x, attackPoint.y, shootStartPos.position.z);
        float mousePosLength = direction.magnitude;
        float attackRangeLength = mousePosLength;
        
        bool rayHit = false;
        Ray shootRay = new Ray(shootStartPos.position, direction);
        RaycastHit[] hits = Physics.RaycastAll(shootRay, maxLength);
        Vector3 hitPoint = Vector3.zero;
        for (int i = 0; i < hits.Length; i++)
        {
            if (hits[i].collider.tag != "Bullet")
            {
                float distance = (hits[i].point - shootStartPos.position).magnitude;
                if (distance < attackRangeLength)
                    attackRangeLength = distance;
                rayHit = true;
                hitPoint = hits[i].point;
                break;
            }
        }

        if (attackRangeLength > maxLength || rayHit)
        {
            float noAttackRangeLength;
            if (rayHit)
            {
                noAttackRangeLength = mousePosLength - attackRangeLength;
            }
            else
            {
                noAttackRangeLength = attackRangeLength - maxLength;
                attackRangeLength = maxLength;
            }
            noAttackRange.SetActive(true);
        }
        else
        {
            noAttackRange.SetActive(false);
        }
        Vector3 canAttackPoint = shootStartPos.position + direction.normalized * attackRangeLength;
        SetPoint(lineRenderer1, shootStartPos.position, canAttackPoint);
        Vector3 canNotAttackPoint = new Vector3(attackPoint.x, canAttackPoint.y, attackPoint.z);
        SetPoint(lineRenderer2, canAttackPoint, canNotAttackPoint);
    }
    #endregion

    #region Shooting
    public void Shoot(PlayerAnimation animator)
    {
        this.animator = animator;
        if (magazineCount > 0 && shootingCoroutine == null)
        {
            shootingCoroutine = StartCoroutine(Shooting());
        }
        else if (magazineCount == 0)
        {
            Debug.Log("No magazine");
        }
    }

    [PunRPC]
    void BulletSpawn()
    {
        GameObject bullet = magazine.GetPooledObject().gameObject;
		if (bullet == null)
        {
            Debug.Log("bullet is null");
            return;
        }
        Vector3 direction = (shootEndPos.position - shootStartPos.position);
        bullet.GetComponent<BulletController>().DestroyDistance = maxLength;
        bullet.GetComponent<BulletController>().shootDirection = direction.normalized;
        if (canConnectPhoton)
            bullet.GetComponent<BulletController>().strTeamBullet = (string)pv.Owner.CustomProperties["Team"];  // << : 추가된 코드(다른 팀만 공격하기 위한 설정)
        bullet.transform.position = shootStartPos.position + new Vector3(1, 0, 1) * Random.Range(-0.2f, 0.2f);

        bullet.SetActive(true);
    }
    IEnumerator Shooting()
    {
        maxAttackRange.SetActive(true);
        while (bulletCount > 0)
        {
            animator.Shoot();
			//>> 추후 RPC 사용하는거로 변경 예정
			if (canConnectPhoton)
                pv.RPC("BulletSpawn", RpcTarget.AllBuffered);
            else
                BulletSpawn();
			bulletCount--;
			yield return new WaitForSeconds(0.1f);
		}
        magazineCount--;
		if (magazineCount > 0)
        {
            bulletCount = InitbulletCount;
        }
        maxAttackRange.SetActive(false);
        Debug.Log("magazine count: " + magazineCount);

		yield return new WaitForSeconds(shootingTerm);
        if (reloadCoroutine == null)
            reloadCoroutine = StartCoroutine(Reload());
        shootingCoroutine = null;
    }
    IEnumerator Reload()
    {
        while (magazineCount < InitmagazineCount)
        {
            yield return new WaitForSeconds(reloadTime);
            if (magazine.Count > InitbulletCount)
            {
                Debug.Log("Reload");
                magazineCount++;
                if (bulletCount == 0)
                    bulletCount = InitbulletCount;
            }
            else
                Debug.Log("Not enough bullet");
        }
        reloadCoroutine = null;
    }
    #endregion
}
