using System.Collections;
using BAEK;
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
    GameObject target;

    protected override void Start()
    {
        base.Start();
        interactCollider.enabled = false;
        rescuePlayer = GetComponent<PlayerInteract>();
    }
    public INode.ENodeState ActiveRescueCollider()
    {
        playerData.pv.RPC("OnInteractColl", RpcTarget.All);
        return INode.ENodeState.Fail;
    }
    
    public INode.ENodeState DeactiveRescueCollider()
    {
        playerData.pv.RPC("OffInteractColl", RpcTarget.All);
        return INode.ENodeState.Fail;
    }
    [PunRPC]
    private void OnInteractColl() //상호작용 전용 콜라이더 활성화
    {
        if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()] != blackBoard.playerTeam) return;
        interactCollider.enabled = true;
    }
    [PunRPC]
    private void OffInteractColl()//상호작용 전용 콜라이더 비활성화
    {
		interactCollider.enabled = false;
        interactUI.ActiveCanInteract(false, InteractUI.Interact);
    }

    [PunRPC]
    private void SetGroggyInteract(bool isInteracting)
	{
		playerData.isGroggyInteracting = isInteracting;
	}

    public override bool ProcessInteract(PhotonView pView)
    {
        if (pView == null) return false;
        ETeam otherTeam = (ETeam)pView.Owner.CustomProperties[EPropertyType.TEAM.ToString()];

        if (otherTeam != blackBoard.playerTeam) return false;
        if (!Managers.PunData.GetPlayerBlackBoard(pView.Owner.NickName).playerStatus.isLive) return false;

        target = pView.gameObject;
		playerData.pv.RPC("SetGroggyInteract", RpcTarget.All, true);
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
            if (interactState == InteractState.NONE)
			{
				interactUI.Interact(0);
				break;
            }

            deltaTime += Time.deltaTime;
            interactUI.Interact(deltaTime);
            yield return null;
        }
        if (deltaTime >= interactTime)
        {
			playerData.pv.RPC("OffInteractColl", RpcTarget.All);
			rescuePlayer.Rescue();
			interactCollider.enabled = false;
		}        
	}

    protected override void OnTriggerEnter(Collider other)
    {
        
    }

    protected override void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            if (target == null || target != other.gameObject) return;
            playerData.pv.RPC("SetGroggyInteract", RpcTarget.All, false);
		}
        target = null;
    }

}