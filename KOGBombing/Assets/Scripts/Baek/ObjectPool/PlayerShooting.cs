using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;
using UnityEngine.UIElements;

public class PlayerShooting : MonoBehaviour
{
    [Header("AttackRange")]
    [SerializeField] Transform shootStartPos;
    [SerializeField] Transform shootEndPos;
    [SerializeField] GameObject attackRangePrefab;
    [SerializeField] GameObject noAttackRangePrefab;
    [SerializeField] float maxLength;

    GameObject attackRange;
    GameObject noAttackRange;

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

    private void FixedUpdate()
    {
        if (canConnectPhoton && !pv.IsMine) return;
        //if (attackRange == null || noAttackRange == null) return;
        ShowAttackArea();
    }
    public void Init(Transform model)
    {
        bulletCount = InitbulletCount;
        magazineCount = InitmagazineCount;
        //maxLength = (shootEndPos.position - shootStartPos.position).magnitude;
        magazine = GetComponent<Magazine>();
        if (!canConnectPhoton || (pv != null && pv.IsMine))
        {
            attackRange = Instantiate(attackRangePrefab);
            attackRange.transform.SetParent(model);
            noAttackRange = Instantiate(noAttackRangePrefab);
            noAttackRange.transform.SetParent(model);
        }
    }
    #region Attack area
    bool CheckMouseOutScreen()
    {
        Vector3 mousePos = Input.mousePosition;
        return (mousePos.x >= 0 && mousePos.x <= Screen.width && mousePos.y >= 0 && mousePos.y <= Screen.height);
    }
    void SetArea(GameObject area, Vector3 pos, float length, Vector3 direction)
    {
        Vector3 areaPos = pos + direction.normalized * length / 2;
        area.transform.position = new Vector3(areaPos.x, area.transform.position.y, areaPos.z);
        area.transform.localScale = new Vector3(0.1f, length / 2, 2.0f);
    }
    void ShowAttackArea()
    {

        if (!CheckMouseOutScreen())
            return;
        Vector3 direction = attackPoint - shootStartPos.position;
        float mousePosLength = direction.magnitude;
        float attackRangeLength = mousePosLength;

        bool rayHit = false;
        Ray shootRay = new Ray(shootStartPos.position, direction);
        // 전부 다 검사
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
                //SetArea(noAttackRange, hit.point, noAttackRangeLength, direction);
                SetArea(noAttackRange, hitPoint, noAttackRangeLength, direction);
            }
            else
            {
                noAttackRangeLength = attackRangeLength - maxLength;
                shootEndPos.position = shootStartPos.position + direction.normalized * maxLength;
                SetArea(noAttackRange, shootEndPos.position, noAttackRangeLength, direction);
                attackRangeLength = maxLength;
            }
            noAttackRange.SetActive(true);

        }
        else
        {
            noAttackRange.SetActive(false);
        }

        SetArea(attackRange, shootStartPos.position, attackRangeLength, direction);
    }
    #endregion

    #region Shooting
    public void Shoot()
    {
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
        bullet.transform.position = shootStartPos.position + new Vector3(1, 0, 1) * Random.Range(-0.2f, 0.2f);

        bullet.SetActive(true);
    }
    IEnumerator Shooting()
    {
        while (bulletCount > 0)
        {
            yield return new WaitForSeconds(0.1f);
            //>> 추후 RPC 사용하는거로 변경 예정
            if(canConnectPhoton)
                pv.RPC("BulletSpawn", RpcTarget.AllBuffered);
            else
                BulletSpawn();

            bulletCount--;
        }
        magazineCount--;
        if (magazineCount > 0)
        {
            bulletCount = InitbulletCount;
        }
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
