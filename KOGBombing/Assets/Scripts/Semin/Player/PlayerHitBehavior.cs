using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Orpul1;
using Photon.Pun;
using UnityEngine.InputSystem;
using Semin;

public class PlayerHitBehavior : PlayerBehavior, IPunObservable, IDamageAble
{
    [SerializeField]
    GameDirector gameDirector;
    [SerializeField]
    PlayerMaterialController playerMaterialController;
    

    TeamUIController teamUIController = new TeamUIController();

    
    private void Start()
    {
        ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties["Team"];
        if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"] != playerTeam)
            SetOtherTeamInfo();
        else blackBoard.hpBar.SetIsMyTeam(true);
        blackBoard.hpBar.Init(blackBoard.maxHp, blackBoard.maxDefence);
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
            blackBoard.hp += decreaseHp;
        blackBoard.hpBar.SetHpValue(blackBoard.hp, blackBoard.defence);

        if (blackBoard.hp <= 0)
        {
            if (blackBoard.groggyable)  // Groggy
            {
                blackBoard.groggyable = false;
                animator.SetAnimBool(PlayerAnimation.AnimType.Groggy, true);
                playerData.speedDebuffPercent = 0.1f;
                ChangeWeapon(WeaponType.NONE);
            }
            else // Death
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
                blackBoard.hp = blackBoard.maxHp;
                blackBoard.defence = blackBoard.maxDefence;
                animator.SetAnimBool(PlayerAnimation.AnimType.Groggy, false);
                blackBoard.groggyable = true;
                playerData.speedDebuffPercent = 1f;
                blackBoard.hpBar.InitializeValues();
                this.transform.position = blackBoard.spawnPoint;
            }
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
        SetActiveState(true);
        blackBoard.viewCamera.GetComponent<PlayerCamera>().SetTarget(gameObject);
        Managers.UI.ClosePopupUI();
    }
    private void SetActiveState(bool isDie)
    {
        for (int i = 0; i < blackBoard.playerModels.Count; i++)
            blackBoard.playerModels[i].SetActive(isDie);

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

    public INode.ENodeState SetLookTarget()
    {
        List<PlayerBlackBoard> blackBoards = Managers.PunData.GetAllBlackBoard();
        Debug.Log($"TeamPlayer {blackBoards.Count}");
        for (int i = 0; i < blackBoards.Count; i++)
        {
            if (blackBoards[i].eTeam != blackBoard.eTeam) continue;
            if (blackBoards[i].isLive)
            {
                Debug.Log("Find Target");
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