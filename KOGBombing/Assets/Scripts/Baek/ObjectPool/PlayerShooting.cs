using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class PlayerShooting : MonoBehaviour
{
    [Header("AttackRange")]
    [SerializeField] GameObject attackRange;
    [SerializeField] GameObject noAttackRange;
    [SerializeField] Transform shootStartPos;
    [SerializeField] Transform shootEndPos;
    
    public Vector3 attackPoint;
    float maxLength;

    [Header("Bullet")]
    [SerializeField] int bulletCount;
    [SerializeField] int magazineCount;

    [SerializeField] float reloadTime;
    [SerializeField] float shootingTerm;

    Coroutine shootingCoroutine;
    Coroutine reloadCoroutine;
    ObjectPool magazine;


    void Start()
    {
        maxLength = (shootEndPos.position - shootStartPos.position).magnitude;
        magazine = GetComponent<ObjectPool>();
        bulletCount = 9;
        magazineCount = 4;
    }
    private void FixedUpdate()
    {
        ShowAttackArea();
    }
    #region Attack area
    bool CheckMouseOutScreen()
    {
        Vector3 mousePos = Input.mousePosition;
        return (mousePos.x >= 0 && mousePos.x <= Screen.width && mousePos.y >= 0 && mousePos.y <= Screen.height);
    }
    void SetArea(GameObject area, Vector3 pos, float length , Vector3 direction)
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
        RaycastHit hit;
        if (Physics.Raycast(shootRay, out hit, maxLength) && hit.collider.tag != "Bullet")
        {
            float distance = (hit.point - shootStartPos.position).magnitude;
            if(distance < attackRangeLength)
                attackRangeLength = distance;
            rayHit = true;
        }

        if (attackRangeLength > maxLength || rayHit)
        {
            float noAttackRangeLength;
            if (rayHit)
            {
                noAttackRangeLength = mousePosLength - attackRangeLength;
                SetArea(noAttackRange, hit.point, noAttackRangeLength, direction);
            }
            else
            {
                noAttackRangeLength = attackRangeLength - maxLength;
                SetArea(noAttackRange, shootEndPos.position, noAttackRangeLength, direction);
                attackRangeLength = maxLength;
            }
            noAttackRange.SetActive(true);

        }
        else
        {
            noAttackRange.SetActive(false);
        }
        
        SetArea(attackRange, shootStartPos.position, attackRangeLength , direction);
    }
    #endregion

    #region Shooting
    public void Shoot()
    {
        if (magazineCount > 0 && shootingCoroutine == null)
        {
            shootingCoroutine = StartCoroutine(Shooting());
        }
        else if(magazineCount == 0)
        {
            Debug.Log("No magazine");
        }
    }
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
            BulletSpawn();
            bulletCount--;
        }
        magazineCount--;
        if (magazineCount > 0)
        {
            bulletCount = 9;
        }
        Debug.Log("magazine count: " + magazineCount);
        yield return new WaitForSeconds(shootingTerm);
        if (reloadCoroutine == null)
            reloadCoroutine = StartCoroutine(Reload());
        shootingCoroutine = null;
    }
    IEnumerator Reload()
    {
        while (magazineCount < 4)
        {
            yield return new WaitForSeconds(reloadTime);
            if (magazine.Count > 9)
            {
                Debug.Log("Reload");
                magazineCount++;
                if (bulletCount == 0)
                    bulletCount = 9;
            }
            else
                Debug.Log("Not enough bullet");
        }
        reloadCoroutine = null;
    }
    #endregion
}
