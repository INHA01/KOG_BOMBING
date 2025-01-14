using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerShooting : MonoBehaviour
{
    [Header("AttackRange")]
    [SerializeField] GameObject attackRange;
    [SerializeField] Transform shootStartPos;
    [SerializeField] Transform shootEndPos;

    [Header("Bullet")]
    [SerializeField] int bulletCount;
    [SerializeField] int magazineCount;

    [SerializeField] float bulletDestroyTime;
    [SerializeField] float reloadTime;
    [SerializeField] float shootingTerm;

    Coroutine shootingCoroutine;
    Coroutine reloadCoroutine;
    ObjectPool magazine;

    Transform playerTransform;

    Vector3 mousePos;

    void Start()
    {
        playerTransform = transform.GetChild(0);
        
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
        float length = (attackPoint - this.transform.position).magnitude;

        //공격 범위 설정
        //Vector3 direction = this.transform.position + playerObj.transform.forward * 2.0f;
        //if (length < 1)
        //    length = 1;
        //attackRange.transform.position = playerObj.transform.position + direction.normalized * length / 2;
        //attackRange.transform.localScale = new Vector3(0.1f, length / 2, 2.0f);

        Vector3 directoin = shootEndPos.position - shootStartPos.position;
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
    }
    private void Shoot()
    {
        GameObject bullet = magazine.GetPooledObject().gameObject;
        if (bullet == null)
        {
            Debug.Log("bullet is null");
            return;
        }
        bullet.GetComponent<BulletController>().DestroyTime = bulletDestroyTime;
        Vector3 dir = new Vector3(shootStartPos.position.x, 0, shootStartPos.position.z) - new Vector3(playerTransform.position.x, 0, playerTransform.position.z);
        bullet.GetComponent<BulletController>().shootDirection = dir.normalized;
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
            if (magazine.Count > 9 * magazineCount)
            {
                Debug.Log("Reload");
                Debug.Log("queue count: " + magazine.Count);
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
