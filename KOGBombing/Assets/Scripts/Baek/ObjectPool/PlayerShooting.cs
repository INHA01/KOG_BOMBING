using Orpul1;
using BAEK;
using Photon.Pun;
using System.Collections;
using UnityEngine;


public class PlayerShooting : MonoBehaviour, IDestroyAble
{
    [Header("ObjectPool")]
    [SerializeField] BulletController bulletPrefab;
    [SerializeField] GenericObjectpool<BulletController> _bulletPool;
    [SerializeField] Transform _bulletParent;


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
    IChangeHitCursorAble hitCursor;

    public int MagazineCount { get { return magazineCount; } }
    public float ReloadTime { get { return time / reloadTime; } }

    #region Shooting
    private void InitializeObjectPool()
    {
        if (_bulletPool == null || _bulletParent == null)
        {
            Debug.LogError("Bullet Pool or Parent is not assigned.");
            return;
        }
        _bulletPool = new GenericObjectpool<BulletController>
            (
            bulletPrefab, _bulletParent, InitBulletCount,
            onGet: bullet => 
                {
                    // 총알이 반환을 요청할 때, 이 풀의 Release를 실행하도록 연결
                    bullet.OnRelease = (b) => _bulletPool.Release(b);
                }
            );
    }
    public void Init(PlayerAnimation animator, AttackRange attackRange, PlayerInfo playerInfo)
    {
        playerData = GetComponent<PlayerData>();
        magazineCount = InitMagazineCount;
        bulletCount = InitBulletCount;
        this.attackRange = attackRange;
        this.animator = animator;
        this.playerInfo = playerInfo;
        hitCursor = Managers.UI.GetPopupUI<CrossHairController>(UIKEY.CrossHair);

        InitializeObjectPool();
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

            if (playerData.playerSound.weaponSound.isPlayingSound) return;
            playerData.playerSound.weaponSound.isPlayingSound = true;
            StartCoroutine(playerData.playerSound.weaponSound.CoOneShotSound(transform, EWeaponSound.EMPTYCLICK));
            Debug.Log("No magazine");
        }
    }
    [PunRPC]
    void PunPlaySound(int type)
    {
        playerData.playerSound.weaponSound.ActiveSound(transform, (EWeaponSound)type);
    }

    [PunRPC]
    void BulletSpawn(Vector3 shootPosi,Vector3 shootDirection)
    {
        GameObject bullet = _bulletPool.GetPooledObject().gameObject;
		if (bullet == null)
        {
            Debug.Log("bullet is null");
            return;
        }
        bullet.GetComponent<BulletController>().direction = shootDirection.normalized;
        bullet.GetComponent<BulletController>().DestroyDistance = playerData. maxLength;
        bullet.GetComponent<BulletController>().eTeamBullet = playerInfo.team; 
        bullet.GetComponent<BulletController>().playerIndex = playerInfo.teamIndex;
        bullet.GetComponent<BulletController>().SetHitCursorDefency(hitCursor);
        bullet.transform.position = shootPosi;
        bullet.transform.rotation = playerData.playerObj.transform.rotation;
        bullet.GetComponent<BulletController>().ShowMuzzle();
        bullet.SetActive(true);
    }

    IEnumerator Shooting()
    {
        if(playerData.pv.IsMine)
        {
            playerData.pv.RPC("PunPlaySound", RpcTarget.All, (int)EWeaponSound.SHOOTING);
        }
        //+ new Vector3(1, 0, 1) * Random.Range(-0.05f, 0.05f)
        attackRange.ShowDistance(true);
        while (bulletCount > 0)
        {
            playerData.punAnimator.Shoot(playerData.mousePos);
            playerData.pv.RPC("BulletSpawn", RpcTarget.All, playerData.shootPos[(int)ShootPos.Start].position, playerData.shootDirection);
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
            if((time > reloadTime) && (_bulletPool.Count > InitBulletCount))
            {
                time = 0;
                magazineCount++;
                playerData.playerSound.weaponSound.ActiveSound(transform, EWeaponSound.RELOAD,EMixerGroup.EXTRA_ATKSOUND);
                if (bulletCount == 0)
                    bulletCount = InitBulletCount;
            }
        }
        reloadCoroutine = null;
    }
    #endregion

    public void DoDestory()
    {
        Destroy(_bulletParent.gameObject);
    }
}
