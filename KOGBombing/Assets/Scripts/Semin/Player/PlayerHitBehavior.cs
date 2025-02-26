using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Orpul1;
using Photon.Pun;
using Semin;
using PhotonHashtable = ExitGames.Client.Photon.Hashtable;
using ExitGames.Client.Photon;
using Photon.Realtime;
using UnityEngine.Rendering.UI;

public class PlayerHitBehavior : PlayerBehavior, IPunObservable, IDamageAble
{
    [SerializeField]
    GameDirector gameDirector;
    [SerializeField]
    PlayerMaterialController playerMaterialController;
    RaiseEventOptions options = new RaiseEventOptions();
    

    float groggyTime;
    Coroutine groggyCoroutine;
    
    private void Start()
    {
        ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties["Team"];
        //Debug.Log($"Character: {gameObject.name}, PlayerTeam: {playerTeam}, Local: {(ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"]}");
        if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"] != playerTeam)
            SetOtherTeamInfo();
        else blackBoard.hpBar.SetIsMyTeam(true);
        blackBoard.hpBar.Init(blackBoard.playerStatus.maxHp, blackBoard.playerStatus.maxDefence);
		playerData.pv.RPC("SetRecoverDefence", RpcTarget.AllBuffered, 10f);
        playerMaterialController.SaveCurrentMaterial();
        options.Receivers = ReceiverGroup.All;
		StartCoroutine(DamageTest(2f, 350));
	}

	[PunRPC]
	private void ChangeWeaponHit(int type)
	{
		ChangeWeapon(type);
	}

	void SetOtherTeamInfo()
    {
        if (!playerData.pv.IsMine)
        {
            playerMaterialController.SetOtherTeamMaterial(playerData.changeMaterials, blackBoard.hpBar);
            blackBoard.fieldOfView.SetActive(false);
			blackBoard.hpBar.SetIsMyTeam(false);
		}
    }

    IEnumerator DamageTest(float time, float damage)
    {
        yield return new WaitForSeconds(time);
        OnDamaged(damage);
	}


	[PunRPC]
	private void SetRecoverDefence(float time)
	{
		StartCoroutine(RecoverDefence(time));
	}

	IEnumerator RecoverDefence(float duration)
	{
		while (true)
		{
            if (!blackBoard.playerStatus.isGroggy)
                playerData.timeWithoutDamage += Time.deltaTime;
			if (playerData.timeWithoutDamage >= duration)
			{
				float value = blackBoard.playerStatus.defence + blackBoard.playerStatus.maxDefence / 100 * 10;
				blackBoard.playerStatus.defence = Mathf.Min(value, blackBoard.playerStatus.maxDefence);
				blackBoard.hpBar.SetHpValue(blackBoard.playerStatus.hp, blackBoard.playerStatus.defence);
				playerData.timeWithoutDamage = 9f;
			}
			yield return null;
		}
	}

	public void OnDamaged(float damage)
    {
        playerData.pv.RPC("Damage", RpcTarget.AllBuffered, damage);

        
        if (playerData.pv.IsMine)
        {
            PhotonNetwork.RaiseEvent((int)PunEventType.UPDATETEAMSTATE, null, options, SendOptions.SendReliable);
            blackBoard.viewCamera.GetComponent<PlayerCamera>().Shake(0.15f, 0.25f);
        }
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
        Debug.Log("ResapwnPlayer");
        blackBoard.playerStatus.isLive = true;
        blackBoard.hpBar.SetStopHpUI(false);
        blackBoard.playerStatus.groggyValue = 150;
        blackBoard.playerStatus.groggyable = true;
        blackBoard.playerStatus.isGroggy = false;
        blackBoard.playerStatus.hp = blackBoard.playerStatus.maxHp;
        blackBoard.playerStatus.defence = blackBoard.playerStatus.maxDefence;
        blackBoard.hpBar.HideGroggy();

        SetActiveState(true);
        this.transform.position = blackBoard.spawnPoint;
        this.transform.rotation = blackBoard.initRotation;
        blackBoard.viewCamera.GetComponent<PlayerCamera>().SetTarget(gameObject);
        blackBoard.canRespawn = false;
        return INode.ENodeState.Success;
    }
    public bool IsDie()
    {
        return !blackBoard.playerStatus.isLive;
    }
    public bool IsTargetDie()
    {
        if (blackBoard.gmlookTarget == null) return true;
        string name = blackBoard.gmlookTarget.GetComponent<PhotonView>().Owner.NickName;
        if (Managers.PunData.GetPlayerBlackBoard(name).playerStatus.isLive) return true;
        Debug.Log("IsTargetDie Return False");
        return false;
    }
    [PunRPC]
    private void Damage(float damage)
	{
        if (blackBoard.playerStatus.invincibility) return; // 무적 시 Damage 안 받음

		float decreaseHp = blackBoard.playerStatus.defence - damage;
        blackBoard.playerStatus.defence = Mathf.Max(decreaseHp, 0);
		playerMaterialController.Hit();
		if (decreaseHp < 0)
        {
            float decreaseGroggy = blackBoard.playerStatus.hp + decreaseHp;
            blackBoard.playerStatus.hp = Mathf.Max(decreaseGroggy, 0);
            if (decreaseGroggy < 0)
                blackBoard.playerStatus.groggyValue += decreaseGroggy;
        }
        blackBoard.hpBar.SetHpValue(blackBoard.playerStatus.hp, blackBoard.playerStatus.defence);
		playerData.timeWithoutDamage = 0;

        if (blackBoard.playerStatus.hp <= 0)
        {
            if (blackBoard.playerStatus.groggyable)  // Groggy
            {
                blackBoard.playerStatus.isGroggy = true;
				blackBoard.playerStatus.groggyable = false;
                animator.SetAnimBool(PlayerAnimation.AnimType.Groggy, true);
				blackBoard.speedDebuffPercent *= 0.1f;

				playerData.pv.RPC("ChangeWeaponHit", RpcTarget.AllBuffered, (int)WeaponType.NONE);
				//ChangeWeapon(WeaponType.NONE);
                blackBoard.hpBar.ShowGroggy();
				groggyCoroutine = StartCoroutine(Groggy());
			}
            else if (blackBoard.playerStatus.groggyValue <= 0)
			{
				blackBoard.hpBar.SetGroggyValue(0);
				Death();
            }
        }
    }

    private void Death()
    {
        if (playerData.pv.IsMine)
		{
			ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties["Team"];
            blackBoard.setTeam.SetTeamCount((int)blackBoard.eTeam);
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashtable { { "State", EPlayerState.WAITROUND } });

            blackBoard.hpBar.SetStopHpUI(true);
            blackBoard.playerStatus.isLive = false;
            SetActiveState(false);
        }
		if (groggyCoroutine != null)
			StopCoroutine(groggyCoroutine);
		blackBoard.playerStatus.hp = blackBoard.playerStatus.maxHp;
		blackBoard.playerStatus.defence = blackBoard.playerStatus.maxDefence;
        blackBoard.playerStatus.groggyValue = blackBoard.playerStatus.maxGroggy;
		animator.SetAnimBool(PlayerAnimation.AnimType.Groggy, false);
        blackBoard.playerStatus.groggyable = true;
		blackBoard.playerStatus.isGroggy = false;
		blackBoard.speedDebuffPercent = 1f;
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
        int time = 1;
        while (groggyTime <= 15f)
        {
            if (!blackBoard.playerStatus.isGroggy) break;
            groggyTime += Time.deltaTime;
            if (groggyTime >= time)
            {
                time++;
                blackBoard.playerStatus.groggyValue -= blackBoard.playerStatus.maxGroggy / 10;
                blackBoard.hpBar.SetGroggyValue(blackBoard.playerStatus.groggyValue);
            }
            if (blackBoard.playerStatus.groggyValue <= 0)
            {
                Death();
				blackBoard.hpBar.SetGroggyValue(0);
				yield break;
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
        }
        else if (stream.IsReading)
        {
            bool isLive = (bool)stream.ReceiveNext();
            SetActiveState(isLive);
        }
    }

    public void OnRigidity(float time)
    {
        playerData.pv.RPC("Rigidity", RpcTarget.AllBuffered, time);
    }
	/* [PunRPC]
	 public void OnResurrect()
	 {
		 blackBoard.playerStatus.hp = 50f;
		 blackBoard.hpBar.SetHpValue(blackBoard.playerStatus.hp, blackBoard.playerStatus.defence);
		 animator.SetAnimBool(PlayerAnimation.AnimType.Groggy, false);
		 ChangeWeapon(WeaponType.GUN);
		 blackBoard.speedDebuffPercent *= 2f;
	 }*/
	[PunRPC]
    private void Rigidity(float time)
    {
		blackBoard.speedDebuffPercent *= 0.5f;
        StartCoroutine(ResetRigidity(time));
    }

    public INode.ENodeState FindAlivePlayer()
    {
        List<PlayerBlackBoard> blackBoards = Managers.PunData.GetAllBlackBoard();
        for (int i = 0; i < blackBoards.Count; i++)
        {
            if (blackBoards[i].rigidBody == null) return INode.ENodeState.Fail;
            if (blackBoards[i].eTeam != blackBoard.eTeam) continue;
            if (blackBoards[i].rigidBody.gameObject == gameObject) continue;
            if (blackBoards[i].playerStatus.isLive)
            {
                Debug.Log($"Find Target {blackBoards[i].nickname}");
                blackBoard.gmlookTarget = blackBoards[i].rigidBody.gameObject;
                return INode.ENodeState.Success;
            }
        }
        blackBoard.gmlookTarget = null;
        return INode.ENodeState.Fail;
    }
    public INode.ENodeState SetCameraTarget()
    {
        string nickname = blackBoard.gmlookTarget.GetComponent<PhotonView>().Owner.NickName;

        if (Managers.PunData.GetPlayerBlackBoard(nickname).playerStatus.isLive)
        {
            blackBoard.viewCamera.GetComponent<PlayerCamera>().SetTarget(blackBoard.gmlookTarget);
            Debug.Log("Set Camera Look Alive Player");
            return INode.ENodeState.Success;
        }
        blackBoard.gmlookTarget = null;
        return INode.ENodeState.Fail;
    }
    IEnumerator ResetRigidity(float time)
    {
        yield return new WaitForSeconds(time);
		blackBoard.speedDebuffPercent *= 2.0f;
    }
}