using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Orpul1;
using Photon.Pun;
using Semin;
using ExitGames.Client.Photon;
using Photon.Realtime;
using BAEK;

public class PlayerHitBehavior : PlayerBehavior, IDamageAble
{
    [SerializeField]
    PlayerMaterialController playerMaterialController;
    [SerializeField]
    PlayPointController playerPointController;
    RaiseEventOptions options = new RaiseEventOptions();
	[SerializeField] public GameObject hitPrefab;

    bool isActiveHitSound = false;
    BulletController bullet;
    Coroutine hitCoroutine;
    [SerializeField] PlayerHealthUpdater healthUpdater;
    protected override void Awake()
    {
        base.Awake();
        playerData.pivot.GenerateProjector();
    }
    private void Start()
    {
        ETeam localPlayerTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        if (playerData.pv.IsMine)
        {
            StartCoroutine(RecoverDefence(10));
            playerMaterialController.SetLayerToMyPlayer();
        }
        
        if (playerData.playerTeam != localPlayerTeam)
        {
            SetOtherTeamInfo();
        }
        else
        {
            blackBoard.hpBar.SetIsMyTeam(true);
			playerMaterialController.SetLayerToMyPlayer();
		}
        string nickname = playerData.pv.Owner.NickName;
		blackBoard.hpBar.Init(blackBoard.playerStatus.maxHp, blackBoard.playerStatus.maxDefence,nickname);
        playerMaterialController.SaveCurrentMaterial();
        options.Receivers = ReceiverGroup.All;
	}
    private void OnEnable()
    {
        if (playerData.pv.IsMine)
            playerPointController.Initialize();
    }
    [PunRPC]
	private void ChangeWeaponHit(int type)
	{
        animator.ChangeWeapon(playerData, type);
	}

    public void SetInvincibility(bool isInvincibility)
    {
        blackBoard.playerStatus.invincibility = isInvincibility;
	}

	void SetOtherTeamInfo()
    {
        playerMaterialController.SetOtherTeamMaterial(playerData.changeMaterials, blackBoard.hpBar);
        blackBoard.fieldOfView.SetActive(false);
        blackBoard.hpBar.SetIsMyTeam(false);
    }
	IEnumerator RecoverDefence(float duration)
	{
        bool isMaxHP = false;
        bool isMaxDefence = false;

        while (true)
		{
            if (!blackBoard.playerStatus.isGroggy)
                playerData.timeWithoutDamage += Time.deltaTime;
            yield return null;

            isMaxHP = blackBoard.playerStatus.hp >= blackBoard.playerStatus.maxHp;
            isMaxDefence = blackBoard.playerStatus.defence >= blackBoard.playerStatus.maxDefence;

            if (isMaxHP && isMaxDefence) continue;
            if (playerData.timeWithoutDamage < duration) continue;

            float value = 0;
            if (!isMaxHP)    //HP 회복
            {
                float temp = blackBoard.playerStatus.hp + blackBoard.playerStatus.maxHp / 100.0f * 10.0f;
                value = blackBoard.playerStatus.maxHp / 100.0f * 10.0f - (blackBoard.playerStatus.maxHp - blackBoard.playerStatus.hp);
                blackBoard.playerStatus.hp = Mathf.Min(temp, blackBoard.playerStatus.maxHp);
                if (value <= 0) value = 0;
            }
            else  //Defence 회복
            {
                value = blackBoard.playerStatus.defence + blackBoard.playerStatus.maxDefence / 100.0f * 10.0f;
                blackBoard.playerStatus.defence = Mathf.Min(value, blackBoard.playerStatus.maxDefence);
                value = 0;
            }
            blackBoard.playerStatus.defence = Mathf.Min(blackBoard.playerStatus.defence + value, blackBoard.playerStatus.maxDefence);
            blackBoard.hpBar.SetHpValue(blackBoard.playerStatus.hp, blackBoard.playerStatus.defence);
            playerData.timeWithoutDamage = 9f;


            // >> : RPC
            if (blackBoard.updateTeamState != null)
                blackBoard.updateTeamState.UpdateTeamState();
            playerData.pv.RPC("UpdateState", RpcTarget.All, (byte)blackBoard.playerStatus.hp, (byte)blackBoard.playerStatus.defence);
            // << :
        }
    }

    [PunRPC]
    private void UpdateState(byte hp, byte defence)
    {
        blackBoard.playerStatus.hp = hp;
        blackBoard.playerStatus.defence = defence;
        blackBoard.hpBar.SetHpValue(blackBoard.playerStatus.hp, blackBoard.playerStatus.defence);
    }
	
    [PunRPC]
    private void ShowHitCursor(byte playerIndex, byte playerTeam)
    {
        ETeam mTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        int mPlayerIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
        if (playerTeam == (byte)mTeam) return;
        if (playerIndex != mPlayerIndex) return;
    }
    [PunRPC]
    public void HitEffectToPivot()
    {
        if (hitCoroutine == null)
            hitCoroutine = StartCoroutine(StartAnimatePivot());
    }

    IEnumerator StartAnimatePivot()
    {
        float time = 0;
        float originRad = playerData.pivot.Radius;
        while (time < 0.03f)
        {
            time += Time.deltaTime;
            playerData.pivot.Radius += 0.1f;
			playerData.pivot.GenerateProjector();
            yield return new WaitForEndOfFrame();
        }
        time = 0;
        while (time < 0.03f)
		{
			time += Time.deltaTime;
			playerData.pivot.Radius -= 0.1f;
			playerData.pivot.GenerateProjector();
			yield return new WaitForEndOfFrame();
		}
        playerData.pivot.Radius = originRad;
		playerData.pivot.GenerateProjector();
		hitCoroutine = null;
    }
    
    public INode.ENodeState SuccessNode()
    {
        return INode.ENodeState.Success;
    }

   /* public bool CanRespawnPlayer()
    {
        if (!blackBoard.canRespawn) return false;
        return true;
    }
    public INode.ENodeState RespawnNode()
    {
        blackBoard.Initialize();
        if (!playerData.pv.IsMine)return INode.ENodeState.Fail;
        playerData.pv.RPC("PunRespawn", RpcTarget.All);
        playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Groggy, false);
        playerData.supportWeapon.LoadWeaponIcon();
        playerData.skill.LoadSkillIcon();
        blackBoard.viewCamera.GetComponent<PlayerCamera>().SetTarget(gameObject);
        blackBoard.updateTeamState.UpdateTeamState();
        playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.All, (int)WeaponType.GUN);

		return INode.ENodeState.Success;
    }*//*
    [PunRPC]
    private void PunRespawn()
    {
        blackBoard.Initialize();
        playerMaterialController.StartCreateEffect();
        SetActiveState(true);
        playerData.InitializeCount();

		this.transform.position = blackBoard.spawnPoint;
        this.transform.rotation = blackBoard.initRotation;
	}*/
    public bool IsDie()
    {
        return !blackBoard.playerStatus.isLive;
    }
    public INode.ENodeState SetDeactiveUI()
    {
        if (!playerData.pv.IsMine) return INode.ENodeState.Fail;
        playerData.pv.RPC("PunDeactiveUI", RpcTarget.All);
        return INode.ENodeState.Success;
    }
    public INode.ENodeState ShowKillUI()
    {
        if(blackBoard.nickname ==playerPointController.GetKillPlayerNickname().ToString())
            playerData.pv.RPC("PunShowKillUI", RpcTarget.All);
        //임시 초기화
        GetComponent<PlayeRescue>().DeactiveRescueCollider();

        return INode.ENodeState.Success;
    }
    [PunRPC]
    private void PunShowKillUI()
    {
        PlayScene playScene = Managers.UI.GetPopupUI<PlayScene>(UIKEY.Play);
        playScene.ActiveKill();
        playerData.playerSound.hitDeathSound.ActiveSound(transform, EHitDeathSound.PLAYERKILL);
    }
    [PunRPC]
    private void PunDeactiveUI()
    {
        Debug.Log("PunDeactiveUI");
        blackBoard.hpBar.HideGroggy();
        blackBoard.hpBar.HideHpUI();
    }
    public INode.ENodeState SetPlayerScore()
    {
        if (blackBoard.isSetScore) return INode.ENodeState.Fail;
        playerData.pv.RPC("PunDeathSound", RpcTarget.All);

        playerPointController.OnKillPoint();
        playerPointController.OnDeathPoint();
        playerPointController.OnAssistPoint();
        playerPointController.Initialize();
        blackBoard.setTeam.DecreaseTeamCount((int)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()]);
        blackBoard.isSetScore = true;
        return INode.ENodeState.Success;
    }
    [PunRPC]
    private void PunDeathSound()
    {
        EHitDeathSound soundType = (EHitDeathSound)((int)playerData.characterType * (int)EHitDeathSound.UNI_DEATH);
        playerData.playerSound.hitDeathSound.ActiveSound(transform, soundType);
    }
    private IEnumerator CoHitSound()
    {
        int soundIndex = (int)EHitDeathSound.NED_HIT1 + (int)playerData.characterType * 4;
        
        AudioClip hitSoundClip = playerData.playerSound.hitDeathSound.HitDeathList[soundIndex];
        float time = Time.time + hitSoundClip.length;
        playerData.pv.RPC("PunHitSound", RpcTarget.All, soundIndex);
        while (time > Time.time) yield return null;
        isActiveHitSound = false;
    }
    [PunRPC]
    private void PunHitSound(int soundIndex)
    {
        playerData.playerSound.hitDeathSound.ActiveSound(transform, (EHitDeathSound)soundIndex);
    }
    [PunRPC]
    private void PunHitMaterial()
    {
        playerMaterialController.Hit();
    }
    public void OnDamaged(float damage, int playerIndex)
    {
        playerData.pv.RPC("Damage", RpcTarget.All, damage, playerIndex);
        playerData.pv.RPC("HitEffectToPivot", RpcTarget.All);
        if (playerData.pv.IsMine)
        {
            Debug.Log($"OnDamged index {playerIndex}");
            playerData.pv.RPC("ShowHitCursor", RpcTarget.All, (byte)playerIndex, (byte)playerData.playerTeam);
            playerPointController.OnDamagePoint(playerIndex, (int)damage);
            PhotonNetwork.RaiseEvent((int)PunEventType.UPDATETEAMSTATE, null, options, SendOptions.SendReliable);
            blackBoard.viewCamera.GetComponent<PlayerCamera>().Shake(0.15f, 0.125f);
            playerPointController.SetAttackPlayer(playerIndex);
            playerData.timeWithoutDamage = 0;
            if (isActiveHitSound) return;
            blackBoard.updateTeamState.UpdateTeamState();
            isActiveHitSound = true;
            StartCoroutine(CoHitSound());
        }
    }
    [PunRPC]
    private void Damage(float damage,int playerIndex)
	{
		if (blackBoard.playerStatus.invincibility) return;
        if(playerData.pv.IsMine)
        {
            PunHitMaterial();
        }
        healthUpdater.Damage(damage, playerIndex);
	}
    private void SetActiveState(bool isDie)
    {
        for (int i = 0; i < playerData.changeMaterialMeshs.Count; i++)
			playerData.changeMaterialMeshs[i].SetActive(isDie);

        blackBoard.rigidBody.isKinematic = !isDie;
        blackBoard.playerCollider.enabled = isDie;
    }

    public void OnRigidity(float time)
    {
        playerData.pv.RPC("Rigidity", RpcTarget.All, time);
    }
	[PunRPC]
    private void Rigidity(float time)
    {
		blackBoard.speedDebuff.rigidityValue = 0.5f;
        StartCoroutine(ResetRigidity(time));
    }/*
    public bool IsTargetDie()
    {
        if (!Managers.PunData.IsContainKey(blackBoard.observaTargetIndex))
            return false ;

        bool isLiveTarget = Managers.PunData.GetPlayerStateData(blackBoard.observaTargetIndex).playerStatus.isLive;
        Debug.Log("PlayerDie Search alive Other Player");
        if (isLiveTarget) 
            return false;
        Debug.Log("PlayerDie Observe Other Player");
        return true;
    }
    public INode.ENodeState FindAlivePlayer()
    {
        List<PlayerStateData> playerStateList = Managers.PunData.GetAllStateData();
        Debug.Log("Search Alive Player");
        for (int i = 0; i < playerStateList.Count; i++)
        {
            if (playerStateList[i].rigidBody == null) return INode.ENodeState.Fail;
            if (playerStateList[i].playerTeam != playerData.playerTeam) continue;
            if (playerStateList[i].rigidBody.gameObject == gameObject) continue;
            if (!playerStateList[i].playerStatus.isLive) continue;

            Debug.Log($"Find Target {playerStateList[i].nickname}");
            blackBoard.observaTarget = playerStateList[i].observaTarget;
            blackBoard.observaTargetIndex = 0;
            blackBoard.observaTargetIndex = playerStateList[i].playerIndex;
            return INode.ENodeState.Success;

        }
        blackBoard.observaTarget = null;
        return INode.ENodeState.Fail;
    }
    public INode.ENodeState SetCameraTarget()
    {
        
        if (Managers.PunData.GetPlayerStateData(blackBoard.observaTargetIndex).playerStatus.isLive)
        {
            blackBoard.viewCamera.GetComponent<PlayerCamera>().SetTarget(blackBoard.observaTarget);
            blackBoard.viewCamera.transform.LookAt(blackBoard.observaTarget.transform);
            Debug.Log("Set Camera Look Alive Player");
            return INode.ENodeState.Success;
        }
        blackBoard.observaTarget = null;
        return INode.ENodeState.Fail;
    }*/
    IEnumerator ResetRigidity(float time)
    {
        yield return new WaitForSeconds(time);
		blackBoard.speedDebuff.rigidityValue = 1.0f;
    }
    protected virtual void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Bullet")
        {
            if (!playerData.pv.IsMine) return;
            bullet = other.GetComponent<BulletController>();
            if (bullet == null) return;

            if (GetComponent<IGetTeamTypeable>().GetTeamType() == bullet.eTeamBullet) return;
            bullet.HitAndMakeParticle(GetComponent<Collider>());

            Vector3 contactPoint = other.ClosestPoint(transform.position);
            Quaternion rot = Quaternion.FromToRotation(Vector3.up, other.transform.position - contactPoint);
            Vector3 pos = contactPoint;

            playerData.pv.RPC("SetParticleToHit", RpcTarget.All, pos, rot);
        }
    }
    [PunRPC]
    void SetParticleToHit(Vector3 pos, Quaternion rot)
    {
        if (hitPrefab != null)
        {
            var hitVFX = Instantiate(hitPrefab, pos, rot);
            var psHit = hitVFX.GetComponent<ParticleSystem>();
            if (psHit != null)
                Destroy(hitVFX, psHit.main.duration);

            else
            {
                var psChild = hitVFX.transform.GetChild(0).GetComponent<ParticleSystem>();
                Destroy(hitVFX, psChild.main.duration);
            }
        }
    }
}