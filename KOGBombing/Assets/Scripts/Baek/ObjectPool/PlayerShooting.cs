using Knife.Effects;
using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.UIElements;

public class PlayerShooting : MonoBehaviour
{
    [Header("Bullet")]
    [SerializeField] int InitBulletCount = 9;
    [SerializeField] int InitMagazineCount = 4;
    int bulletCount;
    int magazineCount;
    [SerializeField] float reloadTime;
    [SerializeField] float shootingTerm;

    [SerializeField][Tooltip("Shot emitters array")] private ParticleGroupEmitter[] shotEmitters;
    [SerializeField] private GameObject projectilePrefab;

    Coroutine shootingCoroutine;
    Coroutine reloadCoroutine;
    Magazine magazine;

    PlayerAnimation animator;
    AttackRange attackRange;
    PlayerData playerData;

    #region Shooting
    public void Init(PlayerAnimation animator, AttackRange attackRange)
    {
        playerData = GetComponent<PlayerData>();
        magazine = GetComponent<Magazine>();
        magazineCount = InitMagazineCount;
        bulletCount = InitBulletCount;
        this.attackRange = attackRange;
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
        //Vector3 direction = (playerData.mousePos - playerData.shootStartPos.position);
        Vector3 direction = (playerData.playerLookObj.transform.position - playerData.playerObj.transform.position);
        Debug.Log($"dir: {direction}");
        bullet.GetComponent<BulletController>().DestroyDistance = playerData. maxLength;
        bullet.GetComponent<BulletController>().shootDirection = direction.normalized;
        bullet.GetComponent<BulletController>().strTeamBullet = (string)playerData.pv.Owner.CustomProperties["Team"];  // << : 추가된 코드(다른 팀만 공격하기 위한 설정)
        bullet.transform.position = playerData.shootStartPos.position + new Vector3(1, 0, 1) * Random.Range(-0.2f, 0.2f);// + new Vector3(0, 0.8f, 0);
        bullet.SetActive(true);
    }
    IEnumerator Shooting()
    {
        attackRange.ShowDistance(true);
        while (bulletCount > 0)
        {
            if(shotEmitters != null)
            {
                foreach (var emitter in shotEmitters)
                {
                    emitter.Emit(1);
                }
            }
            animator.Shoot();
            playerData.pv.RPC("BulletSpawn", RpcTarget.AllBuffered);
			bulletCount--;
			yield return new WaitForSeconds(0.1f);
		}
        magazineCount--;
		if (magazineCount > 0)
        {
            bulletCount = InitBulletCount;
        }
        attackRange.ShowDistance(false);

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
            if (magazine.Count > InitBulletCount)
            {
                magazineCount++;
                if (bulletCount == 0)
                    bulletCount = InitBulletCount;
            }
        }
        reloadCoroutine = null;
    }
    #endregion
}
