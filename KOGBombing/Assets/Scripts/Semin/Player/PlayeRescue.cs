using System.Collections;
using Orpul1;
using Photon.Pun;
using Semin;
using UnityEngine;

public class PlayeRescue : InteractObject
{
    [SerializeField]
    PlayerBlackBoard blackBoard;
    [SerializeField]
    PlayerData playerData;
    IRescueAble rescuePlayer;
    private void Start()
    {
        interactCollider.enabled = false;
        rescuePlayer = GetComponent<PlayerInteract>();
    }
    public INode.ENodeState ActiveRescueCollider()
    {
        playerData.pv.RPC("RPCActiveRescueCollider", RpcTarget.AllBuffered);
        return INode.ENodeState.Fail;
    }
    
    public INode.ENodeState DeactiveRescueCollider()
    {
        playerData.pv.RPC("RPCDeactiveRescueCollider", RpcTarget.AllBuffered);
        return INode.ENodeState.Fail;
    }
    [PunRPC]
    private void RPCActiveRescueCollider()
    {
        if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"]!= (ETeam)playerData.pv.Owner.CustomProperties["Team"]) return;

        interactCollider.enabled = true;
        interactUI.ActivePanel();
    }
    [PunRPC]
    private void RPCDeactiveRescueCollider()
    {

        interactCollider.enabled = false;
        interactUI.DeactivePanel();
    }
    public override bool ProcessInteract(PhotonView pView)
    {
        if (pView == null) return false;
        ETeam otherTeam = (ETeam)pView.Owner.CustomProperties["Team"];

        if (otherTeam != blackBoard.eTeam) return false;
        if (!Managers.PunData.GetPlayerBlackBoard(pView.Owner.NickName).playerStatus.isLive) return false;
        StartCoroutine(CoInteractDelay());
        return true;
    }

    protected override IEnumerator CoInteractDelay()
    {
        if (interactState == InteractState.INTERACTING) yield break;
        interactState = InteractState.INTERACTING;
        float deltaTime = 0;
        while(deltaTime<interactTime)
        {
            deltaTime += Time.deltaTime;
            interactUI.ProgressInteract(deltaTime);
            yield return null;
        }
        playerData.pv.RPC("RPCDeactiveRescueCollider", RpcTarget.AllBuffered);
        rescuePlayer.Rescue();
        interactCollider.enabled = false;
    }
    protected override void OnTriggerEnter(Collider other)
    {
        
    }
    protected override void OnTriggerExit(Collider other)
    {
        
    }

}