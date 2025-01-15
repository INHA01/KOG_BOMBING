using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class PlayerShooting : MonoBehaviour
{
    [Header("AttackRange")]
    [SerializeField] GameObject attackRange;
    [SerializeField] Transform shootStartPos;
    [SerializeField] Transform shootEndPos;
    Vector3 mousePos;

    [Header("Bullet")]
    [SerializeField] int bulletCount;
    [SerializeField] int magazineCount;

    [SerializeField] float reloadTime;
    [SerializeField] float shootingTerm;

    Coroutine shootingCoroutine;
    Coroutine reloadCoroutine;
    ObjectPool magazine;

    float maxDistance;
    Vector3 directoin;
    float length;

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
        Vector3 attackPoint = Camera.main.ScreenToWorldPoint(new Vector3(mousePos.x, mousePos.y, 10));
        length = (attackPoint - this.transform.position).magnitude;
        directoin = shootEndPos.position - shootStartPos.position;
        if (length < 1)
            length = 1;
        attackRange.transform.position = shootStartPos.position + directoin.normalized * length / 2;
        attackRange.transform.localScale = new Vector3(0.1f, length / 2, 2.0f);
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
        if(length > maxDistance)
            length = maxDistance;
        bullet.GetComponent<BulletController>().DestroyDistance = length;
        bullet.GetComponent<BulletController>().shootDirection = directoin.normalized;
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
