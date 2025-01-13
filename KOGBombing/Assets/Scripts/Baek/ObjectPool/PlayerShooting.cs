using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerShooting : MonoBehaviour
{
    [SerializeField] Transform bulletSpawnPosi;

    [SerializeField] int bulletCount;
    [SerializeField] int magazineCount;

    [SerializeField] float bulletDestroyTime;
    [SerializeField] float reloadTime;
    [SerializeField] float shootingTerm;

    Coroutine shootingCoroutine;
    Coroutine reloadCoroutine;
    ObjectPool magazine;

    Transform playerTransform;

    void Start()
    {
        playerTransform = transform.GetChild(0);
        
        magazine = GetComponent<ObjectPool>();
        bulletCount = 9;
        magazineCount = 4;
    }
    void Update()
    {
        Debug.DrawRay(new Vector3(bulletSpawnPosi.position.x, 0, bulletSpawnPosi.position.z), new Vector3(playerTransform.position.x, 0, playerTransform.position.z) - new Vector3(bulletSpawnPosi.position.x, 0, bulletSpawnPosi.position.z), Color.red);
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
        Vector3 dir = new Vector3(bulletSpawnPosi.position.x, 0, bulletSpawnPosi.position.z) - new Vector3(playerTransform.position.x, 0, playerTransform.position.z);
        bullet.GetComponent<BulletController>().shootDirection = dir.normalized;
        bullet.transform.position = bulletSpawnPosi.position;

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
