using Knife.Effects;
using Orpul1;
using BAEK;
using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.UIElements;
using static UnityEditor.ShaderGraph.Internal.KeywordDependentCollection;


public class PlayerShooting : Magazine
{
    [Header("Bullet")]
    [SerializeField] int InitBulletCount = 9;
    [SerializeField] int InitMagazineCount = 4;
    int bulletCount;
    int magazineCount;
    [SerializeField] float reloadTime;
    [SerializeField] float shootingTerm;
    float time;

    Coroutine shootingCoroutine;
    Coroutine reloadCoroutine;

    PlayerAnimation animator;
    AttackRange attackRange;
    PlayerData playerData;
    PlayerInfo playerInfo;

    public int MagazineCount { get { return magazineCount; } }
    public float ReloadTime { get { return time / reloadTime; } }
    BulletController targetBullet;

    #region Shooting
    public void Init(PlayerAnimation animator, AttackRange attackRange, PlayerInfo playerInfo)
    {
        playerData = GetComponent<PlayerData>();
        magazineCount = InitMagazineCount;
        bulletCount = InitBulletCount;
        this.attackRange = attackRange;
        this.animator = animator;
        this.playerInfo = playerInfo;
    }
    public void RoundChange()
    {
        magazineCount = InitMagazineCount;
        bulletCount = InitBulletCount;
    }
    public void Shoot()
    {
        if (magazineCount > 0 && shootingCoroutine == null)
        {
            shootingCoroutine = StartCoroutine(Shooting());
        }
        else if (magazineCount == 0)
        {
            playerData.playerSound.weaponSound.ActiveSound(transform, EWeaponSound.EMPTYCLICK);
            Debug.Log("No magazine");
        }
    }
    [PunRPC]
    void PunPlaySound(int type)
    {
        playerData.playerSound.weaponSound.ActiveSound(transform, (EWeaponSound)type);
    }

    [PunRPC]
    void BulletSpawn(Vector3 shootDirection)
    {
        GameObject bullet = GetPooledObject().gameObject;
		if (bullet == null)
        {
            Debug.Log("bullet is null");
            return;
        }
        bullet.GetComponent<BulletController>().direction = shootDirection.normalized;
        bullet.GetComponent<BulletController>().DestroyDistance = playerData. maxLength;
        bullet.GetComponent<BulletController>().eTeamBullet = playerInfo.team; 
        bullet.GetComponent<BulletController>().playerIndex = playerInfo.teamIndex;
        bullet.transform.position = playerData.shootPos[(int)ShootPos.Start].position + new Vector3(1, 0, 1) * Random.Range(-0.05f, 0.05f);// + new Vector3(0, 0.8f, 0);
        bullet.transform.rotation = playerData.playerObj.transform.rotation;
        bullet.GetComponent<BulletController>().ShowMuzzle();
        bullet.SetActive(true);
    }

    public void CreateParticleAtPlayerPos(BulletController bullet)
	{
        targetBullet = bullet;
        playerData.pv.RPC("RPCCreateParticleAtPlayerPos", RpcTarget.All);
	}


	[PunRPC]
    void RPCCreateParticleAtPlayerPos()
    {
        if (targetBullet != null)
        {
            targetBullet.HitAndMakeParticle();
            Debug.Log("CreateParticle");
        }
	}

    IEnumerator Shooting()
    {
        if(playerData.pv.IsMine)
        {
            playerData.pv.RPC("PunPlaySound", RpcTarget.All, (int)EWeaponSound.SHOOTING);
        }
            
        attackRange.ShowDistance(true);
        while (bulletCount > 0)
        {
            playerData.punAnimator.Shoot(playerData.mousePos);
            playerData.pv.RPC("BulletSpawn", RpcTarget.All, playerData.shootDirection);
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
        time = 0;
        while (magazineCount < InitMagazineCount)
        {
            yield return null;
            time += Time.deltaTime;
            if((time > reloadTime) && (Count > InitBulletCount))
            {
                time = 0;
                magazineCount++;
                playerData.playerSound.weaponSound.ActiveSound(transform, EWeaponSound.RELOAD);
                if (bulletCount == 0)
                    bulletCount = InitBulletCount;
            }
        }
        reloadCoroutine = null;
    }
    #endregion
}
