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
    
    Vector3 mousePos;
    Vector3 direction;
    float maxDistance;
    float attackRangelength;
    float noAttackRangeLength;

    [Header("Bullet")]
    [SerializeField] int bulletCount;
    [SerializeField] int magazineCount;

    [SerializeField] float reloadTime;
    [SerializeField] float shootingTerm;

    Coroutine shootingCoroutine;
    Coroutine reloadCoroutine;
    ObjectPool magazine;
    public Vector3 attackPoint;


    void Start()
    {
        maxDistance = (shootEndPos.position - shootStartPos.position).magnitude;
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
    void ShowAttackArea()
    {
        if (!CheckMouseOutScreen())
            return;
        direction = attackPoint - shootStartPos.position;
        attackRangelength = (attackPoint - shootStartPos.position).magnitude;
        if (attackRangelength > maxDistance)
        {
            noAttackRangeLength = attackRangelength - maxDistance;
            SetArea(noAttackRange, shootEndPos.position, noAttackRangeLength);
            noAttackRange.SetActive(true);

            attackRangelength = maxDistance;
        }
        else
        {
            noAttackRange.SetActive(false);

            if (attackRangelength < 1)
                attackRangelength = 1;
        }
        SetArea(attackRange, shootStartPos.position, attackRangelength);
    }
    void SetArea(GameObject area , Vector3 pos, float length)
    {
        Vector3 areaPos = pos + direction.normalized * length / 2;
        area.transform.position = new Vector3(areaPos.x, area.transform.position.y, areaPos.z);
        area.transform.localScale = new Vector3(0.1f, length / 2, 2.0f);
    }
    public void ShootButton()
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
    private void Shoot()
    {
        GameObject bullet = magazine.GetPooledObject().gameObject;
        if (bullet == null)
        {
            Debug.Log("bullet is null");
            return;
        }
        if(attackRangelength > maxDistance)
            attackRangelength = maxDistance;
        bullet.GetComponent<BulletController>().DestroyDistance = attackRangelength;
        bullet.GetComponent<BulletController>().shootDirection = direction.normalized;
        bullet.transform.position = shootStartPos.position;

        bullet.SetActive(true);
    }
    IEnumerator Shooting()
    {
        while (bulletCount > 0)
        {
            yield return new WaitForSeconds(0.1f);
            Shoot();
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
