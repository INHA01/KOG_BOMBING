using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Orpul1;
using Photon.Pun;
using Semin;
using System;
using Unity.VisualScripting;

public class PlayerHitBehavior : PlayerBehavior, IPunObservable, IDamageAble
{
    [SerializeField]
    GameDirector gameDirector;
    [SerializeField]
    PlayerMaterialController playerMaterialController;
    

    TeamUIController teamUIController = new TeamUIController();
    float groggyTime;
    Coroutine groggyCoroutine;

    
    private void Start()
    {
        ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties["Team"];
        if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"] != playerTeam)
            SetOtherTeamInfo();
        else blackBoard.hpBar.SetIsMyTeam(true);
        blackBoard.hpBar.Init(blackBoard.maxHp, blackBoard.maxDefence);
		playerData.pv.RPC("SetRecoverDefence", RpcTarget.AllBuffered, 10f);
        playerMaterialController.SaveCurrentMaterial();
        //StartCoroutine(DamageTest(2f, 350));
	}
    void SetOtherTeamInfo()
    {
        if (!playerData.pv.IsMine)
        {
            playerMaterialController.SetOtherTeamMaterial(playerData.changeMaterials);
            blackBoard.fieldOfView.SetActive(false);
        }
        blackBoard.hpBar.SetIsMyTeam(false);
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
            if (!blackBoard.isGroggy)
                playerData.timeWithoutDamage += Time.deltaTime;
			if (playerData.timeWithoutDamage >= duration)
			{
				float value = blackBoard.defence + blackBoard.maxDefence / 100 * 10;
				blackBoard.defence = Mathf.Min(value, blackBoard.maxDefence);
				blackBoard.hpBar.SetHpValue(blackBoard.hp, blackBoard.defence);
				playerData.timeWithoutDamage = 9f;
			}
			yield return null;
		}
	}

	public void OnDamaged(float damage)
    {
        playerData.pv.RPC("Damage", RpcTarget.AllBuffered, damage);
        playerMaterialController.Hit();

        teamUIController.UpdateTeamUI();

        if (playerData.pv.IsMine)
            blackBoard.viewCamera.GetComponent<PlayerCamera>().Shake(0.15f, 0.25f);
    }
    public INode.ENodeState SuccessNode()
    {
        return INode.ENodeState.Success;
    }
    public bool IsDie()
    {
        return !blackBoard.isLive;
    }
    public bool IsTargetDie()
    {
        if (blackBoard.gmlookTarget == null) return true;
        string name = blackBoard.gmlookTarget.GetComponent<PhotonView>().Owner.NickName;
        if (Managers.PunData.GetPlayerBlackBoard(name).isLive) return true;
        Debug.Log("IsTargetDie Return False");
        return false;
    }
    [PunRPC]
    private void Damage(float damage)
	{
		float decreaseHp = blackBoard.defence - damage;
        blackBoard.defence = Mathf.Max(decreaseHp, 0);
        if (decreaseHp < 0)
        {
            float decreaseGroggy = blackBoard.hp + decreaseHp;
            blackBoard.hp = Mathf.Max(decreaseGroggy, 0);
            if (decreaseGroggy < 0)
                blackBoard.groggyValue += decreaseGroggy;
        }
        blackBoard.hpBar.SetHpValue(blackBoard.hp, blackBoard.defence);
		playerData.timeWithoutDamage = 0;

        if (blackBoard.hp <= 0)
        {
            if (blackBoard.groggyable)  // Groggy
            {
                blackBoard.isGroggy = true;
				blackBoard.groggyable = false;
                animator.SetAnimBool(PlayerAnimation.AnimType.Groggy, true);
                playerData.speedDebuffPercent = 0.1f;
                ChangeWeapon(WeaponType.NONE);
                blackBoard.hpBar.ShowGroggy();
				groggyCoroutine = StartCoroutine(Groggy());
			}
            else if (blackBoard.groggyValue <= 0)
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
			if (playerTeam == ETeam.REDTEAM)
				GameDirector.blueScore++;
			else
				GameDirector.redScore++;

			//gameDirector.pv.RPC("UpdateScores", RpcTarget.AllBuffered, GameDirector.blueScore, GameDirector.redScore);
			StartCoroutine(RespawnDelay(3.0f));
		}
		if (groggyCoroutine != null)
			StopCoroutine(groggyCoroutine);
		blackBoard.hp = blackBoard.maxHp;
		blackBoard.defence = blackBoard.maxDefence;
        blackBoard.groggyValue = blackBoard.maxGroggy;
		animator.SetAnimBool(PlayerAnimation.AnimType.Groggy, false);
		blackBoard.groggyable = true;
		blackBoard.isGroggy = false;
		playerData.speedDebuffPercent = 1f;
		blackBoard.hpBar.InitializeValues();
        blackBoard.hpBar.HideGroggy();
		this.transform.position = blackBoard.spawnPoint;
	}

    IEnumerator Groggy()
    {
        groggyTime = 0;
        int time = 1;
        while (groggyTime <= 15f)
        {
            groggyTime += Time.deltaTime;
            if (groggyTime >= time)
            {
                time++;
                blackBoard.groggyValue -= blackBoard.maxGroggy / 10;
                blackBoard.hpBar.SetGroggyValue(blackBoard.groggyValue);
            }
            if (blackBoard.groggyValue <= 0)
            {
                Death();
				blackBoard.hpBar.SetGroggyValue(0);
				yield break;
            }
            yield return null;
        }
    }

    IEnumerator RespawnDelay(float time)
    {
        blackBoard._uiScene = Managers.UI.ShowPopupUI<UIPopup>("DieCanvas");
        blackBoard.hpBar.SetStopHpUI(true);
        blackBoard.isLive = false;
        SetActiveState(false);
        yield return new WaitForSeconds(time);
        blackBoard.isLive = true;
        blackBoard.hpBar.SetStopHpUI(false);
        blackBoard.groggyValue = 150;
        SetActiveState(true);
        blackBoard.viewCamera.GetComponent<PlayerCamera>().SetTarget(gameObject);
        Managers.UI.ClosePopupUI();
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
            stream.SendNext(blackBoard.isLive);
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
    [PunRPC]
    public void OnResurrect()
    {
        blackBoard.hp = 50f;
        blackBoard.hpBar.SetHpValue(blackBoard.hp, blackBoard.defence);
        animator.SetAnimBool(PlayerAnimation.AnimType.Groggy, false);
        ChangeWeapon(WeaponType.GUN);
        playerData.speedDebuffPercent = 1f;
    }
    [PunRPC]
    private void Rigidity(float time)
    {
        playerData.speedDebuffPercent = 0.5f;
        StartCoroutine(ResetRigidity(time));
    }

    public INode.ENodeState FindAlivePlayer()
    {
        List<PlayerBlackBoard> blackBoards = Managers.PunData.GetAllBlackBoard();
        Debug.Log($"TeamPlayer {blackBoards.Count}");
        for (int i = 0; i < blackBoards.Count; i++)
        {
            if (blackBoards[i].eTeam != blackBoard.eTeam) continue;
            if (blackBoards[i].rigidBody.gameObject == gameObject) continue;
            if (blackBoards[i].isLive)
            {
                Debug.Log($"Find Target {blackBoards[i].nickname}");
                blackBoard.gmlookTarget = blackBoards[i].rigidBody.gameObject;
                return INode.ENodeState.Success;
            }
        }
        Debug.Log("All Team Player Die");
        blackBoard.gmlookTarget = null;
        return INode.ENodeState.Fail;
    }
    public INode.ENodeState SetCameraTarget()
    {
        string nickname = blackBoard.gmlookTarget.GetComponent<PhotonView>().Owner.NickName;

        if (Managers.PunData.GetPlayerBlackBoard(nickname).isLive)
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
        playerData.speedDebuffPercent = 1.0f;
    }
}