using System.Collections;
using BAEK;
using Orpul1;
using Photon.Pun;
using Semin;
using Unity.VisualScripting;
using UnityEngine;

public class PlayeRescue : InteractObject
{
    [SerializeField]
    PlayerBlackBoard blackBoard;
    [SerializeField]
    PlayerData playerData;
    IRescueAble rescuePlayer;
    GameObject target;
    bool canInteract = false;

    protected override void Start()
    {
        base.Start();
        interactCollider.enabled = false;
        rescuePlayer = GetComponent<PlayerInteract>();
    }
    public INode.ENodeState ActiveRescueCollider()
    {
        if (!playerData.pv.IsMine) return INode.ENodeState.Fail;
        if (interactCollider.enabled == true) return INode.ENodeState.Fail;
        playerData.pv.RPC("OnInteractColl", RpcTarget.All);
        return INode.ENodeState.Fail;
    }
    
    public INode.ENodeState DeactiveRescueCollider()
    {
        if (!playerData.pv.IsMine) return INode.ENodeState.Fail;
        playerData.pv.RPC("OffInteractColl", RpcTarget.All);
        return INode.ENodeState.Fail;
    }
    [PunRPC]
    private void OnInteractColl() //상호작용 전용 콜라이더 활성화
    {
        if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()] != playerData.playerTeam) return;

        Debug.Log("Active InteractCollider");
        interactCollider.enabled = true;
        canInteract = true;
    }
    [PunRPC]
    private void OffInteractColl()//상호작용 전용 콜라이더 비활성화
    {
        Debug.Log("Deactive InteractCollider");
		interactCollider.enabled = false;
        interactUI.ActiveCanInteract(false, InteractUI.Interact);
        canInteract = false;
    }

    [PunRPC]
    private void SetGroggyInteract(bool isInteracting)
	{
		playerData.isGroggyInteracting = isInteracting;
	}

    public override bool ProcessInteract(PhotonView pView)
    {
        if (!canInteract) return false;
        if (pView == null) 
            return false;

        int playerIndex = (int)pView.Owner.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
        ETeam otherTeam = (ETeam)pView.Owner.CustomProperties[EPropertyType.TEAM.ToString()];

        if (otherTeam != playerData.playerTeam) 
            return false;

        if (!Managers.PunData.GetPlayerStateData(playerIndex).playerStatus.isLive) 
            return false;

        target = pView.gameObject;
		playerData.pv.RPC("SetGroggyInteract", RpcTarget.All, true);
		StartCoroutine(CoInteractDelay());
		return true;
    }
    public override void AbortInteract()
    {
        if (!canInteract) return;
        base.AbortInteract();
    }

    protected override IEnumerator CoInteractDelay()
    {
        if (interactState == InteractState.INTERACTING) yield break;
        interactState = InteractState.INTERACTING;
        float deltaTime = 0;
        while (deltaTime < interactTime) 
        {
            if (interactState == InteractState.NONE)
			{
                playerData.pv.RPC("PunInteractGage", RpcTarget.All, 0f, (byte)playerData.playerTeam);
                break;
            }

            playerData.pv.RPC("PunInteractGage", RpcTarget.All, deltaTime/interactTime, (byte)playerData.playerTeam);
            deltaTime += Time.deltaTime;
            yield return null;
        }
        if (deltaTime < interactTime) yield break;
        playerData.pv.RPC("OffInteractColl", RpcTarget.All);
        playerData.pv.RPC("SetGroggyInteract", RpcTarget.All, false);
        rescuePlayer.Rescue();
    }
    [PunRPC]
    private void PunInteractGage(float value, byte team)
    {
        ETeam mteam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        if (team != (byte)mteam) return;
        interactUI.Interact(value);
    }
    protected override void OnTriggerExit(Collider other)
    {
        if (other.tag != "Player") return;
        if (!canInteract) return;
        ETeam otherTeam = other.GetComponent<IGetTeamTypeable>().GetTeamType();
        if (otherTeam != playerData.playerTeam) return;
        interactUI.ActiveCanInteract(false, InteractUI.Interact);
        if (target == null || target != other.gameObject) return;
        playerData.pv.RPC("SetGroggyInteract", RpcTarget.All, false);
        target = null;
    }

}