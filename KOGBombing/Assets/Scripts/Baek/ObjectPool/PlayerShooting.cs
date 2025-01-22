using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.UIElements;

public class PlayerShooting : MonoBehaviour
{
    [Header("Bullet")]
    [SerializeField] int InitbulletCount = 9;
    [SerializeField] int InitMagazineCount = 4;
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
    AttackRange attackRange;
    PlayerData playerData;

    #region Shooting
    public void Init(PlayerAnimation animator)
    {
        playerData = GetComponent<PlayerData>();
        attackRange = GetComponent<AttackRange>();
        magazine = GetComponent<Magazine>();
        magazineCount = InitMagazineCount;
        bulletCount = InitbulletCount;
        this.animator = animator;
    }
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
        Vector3 direction = (playerData.shootEndPos.position - playerData.shootStartPos.position);
        bullet.GetComponent<BulletController>().DestroyDistance = playerData. maxLength;
        bullet.GetComponent<BulletController>().shootDirection = direction.normalized;
        if (canConnectPhoton)
            bullet.GetComponent<BulletController>().strTeamBullet = (string)pv.Owner.CustomProperties["Team"];  // << : 추가된 코드(다른 팀만 공격하기 위한 설정)
        bullet.transform.position = playerData.shootStartPos.position + new Vector3(1, 0, 1) * Random.Range(-0.2f, 0.2f) + new Vector3(0, 1, 0);
        bullet.SetActive(true);
    }
    IEnumerator Shooting()
    {
        attackRange.ShowDistance(true);
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
        attackRange.ShowDistance(false);
        Debug.Log("magazine count: " + magazineCount);

		yield return new WaitForSeconds(shootingTerm);
        if (reloadCoroutine == null)
            reloadCoroutine = StartCoroutine(Reload());
        shootingCoroutine = null;
    }
    IEnumerator Reload()
    {
        while (magazineCount < InitMagazineCount)
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
