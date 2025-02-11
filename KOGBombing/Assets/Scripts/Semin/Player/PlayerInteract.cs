using System.Collections;
using System.Collections.Generic;
using Orpul1;
using Photon.Pun;
using Semin;
using UnityEngine;

public class PlayerInteract : PlayerBehavior,IInteractAble
{
    IInteractAble iInteractObj;
    public bool isInteracting = false;
    bool isReviving = false;
    public INode.ENodeState CanBehavior()
    {
        if (blackBoard.inputs[EKey.Escape])
            return INode.ENodeState.Success;
        return INode.ENodeState.Fail;
    }
    public bool IsInteracting()
    {
        return isInteracting;
    }

    // >> TODO : Blackboard를 사용하여 값을 따로 설정해 주는 작업을 줄이는 방안 검토해보기
    public INode.ENodeState FindInteractObjNode()
    {
        if (FindObject() == false)
            return INode.ENodeState.Fail;
        return INode.ENodeState.Success;
    }
    private bool FindObject()
    {
        Collider[] colliders = Physics.OverlapSphere(blackBoard.transform.position, 1f);

        if (colliders.Length == 0) return false;
        IInteractAble interactObj = null;
        string objName = "";
        for (int i = 0; i < colliders.Length; i++)
        {
            if (colliders[i].gameObject == gameObject) continue;
            PhotonView pView = colliders[i].GetComponent<PhotonView>();
            if(pView == null) continue;
            ETeam otherTeam = (ETeam)pView.Owner.CustomProperties["Team"];
            if (otherTeam != blackBoard.eTeam) continue;
            interactObj = colliders[i].GetComponent<IInteractAble>();
            if (!Managers.PunData.GetPlayerBlackBoard(pView.Owner.NickName).isLive) continue;
            objName = colliders[i].name;
            if (interactObj != null) break;
        }
        if (interactObj == null) return false;
        iInteractObj = interactObj;
        Debug.Log("Find Interact Obj");
        return true;
    }

    public INode.ENodeState ProcessInteractNode()
    {
        Debug.Log("Process Interact");
        isInteracting = true;
        iInteractObj.ProcessInteract();
        return INode.ENodeState.Success;

    }

    public INode.ENodeState AbortInteractNode()
    {
        if (iInteractObj == null) return INode.ENodeState.Fail;
        iInteractObj.AbortInteract();
        isInteracting = false;
        iInteractObj = null;
        blackBoard.inputs[EKey.F] = false;
        return INode.ENodeState.Success;
    }

    void IInteractAble.ProcessInteract()
    {
        playerData.pv.RPC("RPCProcess", RpcTarget.AllBuffered);
    }
    void IInteractAble.AbortInteract()
    {
        playerData.pv.RPC("RPCAbort", RpcTarget.AllBuffered);
    }
    [PunRPC]
    private void RPCProcess()
    {
        if (blackBoard.isLive) return;
        Debug.Log("RPC Process Interact");
        StartCoroutine(CoRevive());
    }
    [PunRPC]
    private void RPCAbort()
    {
        Debug.Log("RPC Abort Interact");
        isReviving = false;
    }

    IEnumerator CoRevive()
    {
        if (isReviving) yield break;
        float time = Time.time + blackBoard.reviveInterval;
        while (time > Time.time) 
        {
            if (!isReviving) yield break;
            yield return null;
        }
        OnResurrect();
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
}
