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
    Vector3 mousePos;
    Vector3 direction;
    float maxLength;
    float attackRangeLength;
    float noAttackRangeLength;

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
    bool CheckMouseOutScreen()
    {
        mousePos = Input.mousePosition;
        return (mousePos.x >= 0 && mousePos.x <= Screen.width && mousePos.y >= 0 && mousePos.y <= Screen.height);
    }
    void SetArea(GameObject area, Vector3 pos, float length)
    {
        Vector3 areaPos = pos + direction.normalized * length / 2;
        area.transform.position = new Vector3(areaPos.x, area.transform.position.y, areaPos.z);
        area.transform.localScale = new Vector3(0.1f, length / 2, 2.0f);
    }
    void ShowAttackArea()
    {
        if (!CheckMouseOutScreen())
            return;
        direction = attackPoint - shootStartPos.position;
        attackRangeLength = (attackPoint - shootStartPos.position).magnitude;
        if (attackRangeLength > maxLength)
        {
            noAttackRangeLength = attackRangeLength - maxLength;
            SetArea(noAttackRange, shootEndPos.position, noAttackRangeLength);
            noAttackRange.SetActive(true);

            attackRangeLength = maxLength;
        }
        else
        {
            noAttackRange.SetActive(false);

            if (attackRangeLength < 1)
                attackRangeLength = 1;
        }
        SetArea(attackRange, shootStartPos.position, attackRangeLength);
    }
    
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
        if(attackRangeLength > maxLength)
            attackRangeLength = maxLength;
        bullet.GetComponent<BulletController>().DestroyDistance = attackRangeLength;
        bullet.GetComponent<BulletController>().shootDirection = direction.normalized;
        bullet.transform.position = shootStartPos.position;

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
        while(magazineCount < 4)
        {
            yield return new WaitForSeconds(reloadTime);
            if (magazine.Count > 9)
            {
                Debug.Log("Reload");
                magazineCount++;
                if(bulletCount == 0)
                    bulletCount = 9;
            }
            else
                Debug.Log("Not enough bullet");
        }
        reloadCoroutine = null;
    }
}
