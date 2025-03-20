using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Orpul1;
using Photon.Pun;
using Semin;
using PhotonHashtable = ExitGames.Client.Photon.Hashtable;
using ExitGames.Client.Photon;
using Photon.Realtime;
using BAEK;

public class PlayerHitBehavior : PlayerBehavior, IPunObservable, IDamageAble
{
    [SerializeField]
    GameDirector gameDirector;
    [SerializeField]
    PlayerMaterialController playerMaterialController;
    [SerializeField]
    PlayPointController playerPointController;
    RaiseEventOptions options = new RaiseEventOptions();
	[SerializeField] public GameObject hitPrefab;

	float groggyTime;
    Coroutine groggyCoroutine;
    bool isActiveHitSound = false;
    BulletController bullet;
    Coroutine hitCoroutine;

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
        
        if (blackBoard.playerTeam != localPlayerTeam)
        {
            SetOtherTeamInfo();
        }
        else
        {
            blackBoard.hpBar.SetIsMyTeam(true);
			playerMaterialController.SetLayerToMyPlayer();
		}

		blackBoard.hpBar.Init(blackBoard.playerStatus.maxHp, blackBoard.playerStatus.maxDefence);
        playerMaterialController.SaveCurrentMaterial();
        options.Receivers = ReceiverGroup.All;
	}

    IEnumerator DamageTest(float damage, float time)
    {
        yield return new WaitForSeconds(time);
        int playerIndex = (int)playerData.pv.Owner.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
        OnDamaged(damage, playerIndex);
    }
    private void OnEnable()
    {
        if (playerData.pv.IsMine)
            playerPointController.Initialize();
    }
    [PunRPC]
	private void ChangeWeaponHit(int type)
	{
		ChangeWeapon(type);
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
		while (true)
		{
            if (!blackBoard.playerStatus.isGroggy)
                playerData.timeWithoutDamage += Time.deltaTime;
			if (playerData.timeWithoutDamage >= duration)
			{
                float value = 0;
                if (blackBoard.playerStatus.hp != blackBoard.playerStatus.maxHp)    // hp�� ä������ ���
                {
                    float temp = blackBoard.playerStatus.hp + blackBoard.playerStatus.maxHp / 100 * 10;
                    value = blackBoard.playerStatus.maxHp / 100 * 10 - (blackBoard.playerStatus.maxHp - blackBoard.playerStatus.hp);
                    blackBoard.playerStatus.hp = Mathf.Min(temp, blackBoard.playerStatus.maxHp);
                    if (value <= 0) value = 0;
                }
                else  // defence�� ä������ ���
                {
					value = blackBoard.playerStatus.defence + blackBoard.playerStatus.maxDefence / 100 * 10;
					blackBoard.playerStatus.defence = Mathf.Min(value, blackBoard.playerStatus.maxDefence);
                    value = 0;
				}
				blackBoard.playerStatus.defence = Mathf.Min(blackBoard.playerStatus.defence + value, blackBoard.playerStatus.maxDefence);
				blackBoard.hpBar.SetHpValue(blackBoard.playerStatus.hp, blackBoard.playerStatus.defence);
				playerData.timeWithoutDamage = 9f;
			}
			yield return null;
		}
	}

	public void OnDamaged(float damage, int playerIndex)
    {
        //playerData.pv.RPC("Damage", RpcTarget.All, damage, playerIndex);
        Damage(damage, playerIndex);
        playerData.pv.RPC("HitEffectToPivot", RpcTarget.All);
		if (playerData.pv.IsMine)
        {
            Debug.Log($"OnDamged index {playerIndex}");
            playerPointController.OnDamagePoint(playerIndex, (int)damage);
            PhotonNetwork.RaiseEvent((int)PunEventType.UPDATETEAMSTATE, null, options, SendOptions.SendReliable);
            blackBoard.viewCamera.GetComponent<PlayerCamera>().Shake(0.15f, 0.125f);
            if (isActiveHitSound) return;
            isActiveHitSound = true;
            StartCoroutine(CoHitSound());
        }
    }

    [PunRPC]
    public void HitEffectToPivot()
    {
        if (hitCoroutine == null)
        {
            Debug.Log("Hit Effect To Pivot");
            hitCoroutine = StartCoroutine(StartAnimatePivot());
        }
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

    public bool CanRespawnPlayer()
    {
        if (!blackBoard.canRespawn) return false;
        return true;
    }
    public INode.ENodeState RespawnNode()
    {
        if(!playerData.pv.IsMine)return INode.ENodeState.Fail;
        playerData.pv.RPC("PunRespawn", RpcTarget.All);
        playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Groggy, false);
        playerData.supportWeapon.LoadWeaponIcon();
        playerData.skill.LoadSkillIcon();
        blackBoard.viewCamera.GetComponent<PlayerCamera>().SetTarget(gameObject);
		playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.All, (int)WeaponType.GUN);

		return INode.ENodeState.Success;
    }
    [PunRPC]
    private void PunRespawn()
    {
        blackBoard.Initialize();
        playerMaterialController.StartCreateEffect();
		//animator.SetAnimBool(PlayerAnimation.AnimType.Groggy, false);
        SetActiveState(true);
        playerData.InitializeCount();

		this.transform.position = blackBoard.spawnPoint;
        this.transform.rotation = blackBoard.initRotation;
	}
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
        if (!playerData.pv.IsMine) return INode.ENodeState.Fail;
        playerData.pv.RPC("PunDeathSound", RpcTarget.All);

        playerPointController.OnKillPoint();
        playerPointController.OnDeathPoint();
        playerPointController.OnAssistPoint();
        playerPointController.Initialize();
        blackBoard.setTeam.DecreaseTeamCount((int)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()]);//blackBoard.playerTeam
        blackBoard.isSetScore = true;
        return INode.ENodeState.Success;
    }
    [PunRPC]
    private void PunDeathSound()
    {
        EHitDeathSound soundType = (EHitDeathSound)((int)blackBoard.characterType * (int)EHitDeathSound.UNI_DEATH);
        playerData.playerSound.hitDeathSound.ActiveSound(transform, soundType);
    }
    private IEnumerator CoHitSound()
    {
        int soundIndex = (int)EHitDeathSound.NED_HIT1 + (int)blackBoard.characterType * 4;
        
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
    private void Damage(float damage,int playerIndex)
	{
		if (blackBoard.playerStatus.invincibility) return;
        if(playerData.pv.IsMine)
        {
            playerPointController.SetAttackPlayer(playerIndex);
            playerData.pv.RPC("PunHitMaterial",RpcTarget.All);

        }
        //Debug.Log($"Damage, Player: {transform.name}, Damage: {damage}");

        float decreaseHp = blackBoard.playerStatus.defence - damage;
        //Debug.Log($"Decrease Hp: {decreaseHp}, hp: {blackBoard.playerStatus.hp}");
        blackBoard.playerStatus.defence = Mathf.Max(decreaseHp, 0);
		if (decreaseHp < 0)
        {
            float decreaseGroggy = blackBoard.playerStatus.hp + decreaseHp;
			//Debug.Log($"decreaseGroggy Hp: {decreaseGroggy}, hp: {blackBoard.playerStatus.hp}");
			blackBoard.playerStatus.hp = Mathf.Max(decreaseGroggy, 0);
            if (decreaseGroggy < 0)
                blackBoard.playerStatus.groggyValue += decreaseGroggy;
        }
        blackBoard.hpBar.SetHpValue(blackBoard.playerStatus.hp, blackBoard.playerStatus.defence);
		blackBoard.hpBar.SetGroggyValue(blackBoard.playerStatus.groggyValue);
		playerData.timeWithoutDamage = 0;
        //Debug.Log($"hp: {blackBoard.playerStatus.hp}");
        if (blackBoard.playerStatus.hp <= 0)
        {
            if (blackBoard.playerStatus.groggyable)  // Groggy
            {
                if (!CanGroggy())   // ���� �Ѹ��� ������ �ٷ� ����
				{
					blackBoard.playerStatus.groggyable = false;
					blackBoard.hpBar.SetGroggyValue(0);
					Death();
					return;
				}

				if (blackBoard.inputs[EKey.NUM_2])  // ��ź ��ü ���̾����� Interaction ���
                {
                    if (blackBoard.bombInteraction.GetBomb() != null)
                        blackBoard.bombInteraction.SetBombInteraction(false);
                }

				blackBoard.playerStatus.isGroggy = true;
				blackBoard.playerStatus.groggyable = false;
				blackBoard.speedDebuff.groggyValue = 0.1f;

                playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Skill, false);
                playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Granade, false);
                playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Groggy, true);
				if (playerData.skill is ThrowableSkill skill)
					skill.Disable();
				playerData.supportWeapon.Disable();

				playerData.pv.RPC("ChangeWeaponHit", RpcTarget.All, (int)WeaponType.NONE);
                blackBoard.hpBar.ShowGroggy();
				blackBoard.hpBar.SetHpValue(blackBoard.playerStatus.hp, blackBoard.playerStatus.defence);
				groggyCoroutine = StartCoroutine(Groggy());
			}
            else if (blackBoard.playerStatus.groggyValue <= 0)
			{
                blackBoard.playerStatus.groggyValue = 0;
				blackBoard.hpBar.SetGroggyValue(0);
				Death();
            }
        }

		playerData.pv.RPC("SetHp", RpcTarget.All);
	}

	[PunRPC]
	private void SetHp()
    {
        blackBoard.hpBar.SetHpValue(blackBoard.playerStatus.hp, blackBoard.playerStatus.defence);
        blackBoard.hpBar.SetGroggyValue(blackBoard.playerStatus.groggyValue);
	}

	private bool CanGroggy()
    {
        GameObject[] players = GameObject.FindGameObjectsWithTag("Player");
        ETeam myTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];

		for (int i = 0; i < players.Length; i++)
        {
            if (players[i] == gameObject) continue;
            ETeam otherPlayerTeam = (ETeam)players[i].GetComponent<PlayerData>().pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()];
            if (myTeam == otherPlayerTeam)  // ���� ���ٸ� �°� ����ִ��� Ȯ��
            {
                Debug.Log($"MyPlayer: {myTeam}, otherTeam: {otherPlayerTeam}, {players[i].name}");
                if (players[i].GetComponent<PlayerBlackBoard>().playerStatus.isLive)
                    return true;
            }
		}
        return false;
    }

    private void Death()
    {
        ShowCursor showCursor = Managers.UI.GetPopupUI<ShowCursor>(UIKEY.Play);
        int soundIndex = (int)blackBoard.characterType * (int)EHitDeathSound.UNI_DEATH;
        EHitDeathSound deathSound = (EHitDeathSound)soundIndex;
        playerData.playerSound.hitDeathSound.ActiveSound(transform, deathSound);
        if (!blackBoard.showSoundEffect)
        {
            blackBoard.showSoundEffect = true;
            showCursor.ShowSoundCursor(blackBoard.transform.position, 3, blackBoard);
        }
        if (playerData.pv.IsMine)
		{
			ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()];
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashtable { { EPropertyType.STATE.ToString(), EPlayerState.WAITROUND } });

            blackBoard.hpBar.SetStopHpUI(true);
            blackBoard.playerStatus.isLive = false;
            SetActiveState(false);
        }
		if (groggyCoroutine != null)
			StopCoroutine(groggyCoroutine);

        blackBoard.playerStatus.hp = blackBoard.playerStatus.maxHp;
		blackBoard.playerStatus.defence = blackBoard.playerStatus.maxDefence;
        blackBoard.playerStatus.groggyValue = blackBoard.playerStatus.maxGroggy;
        playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Groggy, false);
		//animator.SetAnimBool(PlayerAnimation.AnimType.Groggy, false);
        blackBoard.playerStatus.groggyable = true;
		blackBoard.playerStatus.isGroggy = false;
        blackBoard.speedDebuff.Initialize();
		blackBoard.hpBar.InitializeValues();
        blackBoard.hpBar.HideGroggy();
		this.transform.position = blackBoard.spawnPoint;
	}

    IEnumerator Groggy()
    {
        blackBoard.playerStatus.invincibility = true;
        yield return new WaitForSeconds(2f);
		blackBoard.playerStatus.invincibility = false;
		groggyTime = 0;
        float time = 1f;
        while (blackBoard.playerStatus.groggyValue > 0)
		{
			if (!blackBoard.playerStatus.isGroggy) break;
            while (playerData.isGroggyInteracting) yield return null;
			groggyTime += Time.deltaTime;
            if (groggyTime >= time)
            {
                Damage(blackBoard.playerStatus.maxGroggy / 10, -1);
				groggyTime = 0;
			}
            yield return null;
		}
	}

    private void SetActiveState(bool isDie)
    {
        for (int i = 0; i < playerData.changeMaterialMeshs.Count; i++)
			playerData.changeMaterialMeshs[i].SetActive(isDie);

        blackBoard.rigidBody.isKinematic = !isDie;
        blackBoard.playerCollider.enabled = isDie;
    }
    public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info)
    {
        if (stream.IsWriting)
        {
            stream.SendNext(blackBoard.playerStatus.isLive);
            stream.SendNext((int)blackBoard.playerStatus.hp);
            stream.SendNext((int)blackBoard.playerStatus.defence);
            stream.SendNext(blackBoard.playerStatus.groggyable);
            stream.SendNext((int)blackBoard.playerStatus.groggyValue);
            stream.SendNext(blackBoard.playerStatus.isGroggy);
        }
        else if (stream.IsReading)
        {
            blackBoard.playerStatus.isLive = (bool)stream.ReceiveNext();
            blackBoard.playerStatus.hp = (int)stream.ReceiveNext();
            blackBoard.playerStatus.defence = (int)stream.ReceiveNext();
            blackBoard.playerStatus.groggyable = (bool)stream.ReceiveNext();
            blackBoard.playerStatus.groggyValue = (int)stream.ReceiveNext();
            blackBoard.playerStatus.isGroggy = (bool)stream.ReceiveNext();
            SetActiveState(blackBoard.playerStatus.isLive);

            blackBoard.hpBar.SetHpValue(blackBoard.playerStatus.hp, blackBoard.playerStatus.defence);
        }
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
    }
    public bool IsTargetDie()
    {
        if (blackBoard.observaTargetNickname == null) return true;
        if (blackBoard.observaTargetNickname.Equals("")) return true;
        bool isLiveTarget = Managers.PunData.GetPlayerBlackBoard(blackBoard.observaTargetNickname.ToString()).playerStatus.isLive;
        if (!isLiveTarget) return true;
        Debug.Log("IsTargetDie Return False");
        return false;
    }
    public INode.ENodeState FindAlivePlayer()
    {
        List<PlayerBlackBoard> blackBoards = Managers.PunData.GetAllBlackBoard();
        Debug.Log("Search Alive Player");
        for (int i = 0; i < blackBoards.Count; i++)
        {
            if (blackBoards[i].rigidBody == null) return INode.ENodeState.Fail;
            if (blackBoards[i].playerTeam != blackBoard.playerTeam) continue;
            if (blackBoards[i].rigidBody.gameObject == gameObject) continue;
            if (!blackBoards[i].playerStatus.isLive) continue;

            Debug.Log($"Find Target {blackBoards[i].nickname}");
            blackBoard.observaTarget = blackBoards[i].rigidBody.gameObject;
            blackBoard.observaTargetNickname.Clear();
            blackBoard.observaTargetNickname.Append(blackBoards[i].nickname);
            return INode.ENodeState.Success;

        }
        blackBoard.observaTarget = null;
        return INode.ENodeState.Fail;
    }
    public INode.ENodeState SetCameraTarget()
    {
        
        if (Managers.PunData.GetPlayerBlackBoard(blackBoard.observaTargetNickname.ToString()).playerStatus.isLive)
        {
            blackBoard.viewCamera.GetComponent<PlayerCamera>().SetTarget(blackBoard.observaTarget);
            blackBoard.viewCamera.transform.LookAt(blackBoard.observaTarget.transform);
            Debug.Log("Set Camera Look Alive Player");
            return INode.ENodeState.Success;
        }
        blackBoard.observaTarget = null;
        return INode.ENodeState.Fail;
    }
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

            //Debug.Log($"mine: {GetComponent<IGetTeamTypeable>().GetTeamType()}, other: {bullet.eTeamBullet}");
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