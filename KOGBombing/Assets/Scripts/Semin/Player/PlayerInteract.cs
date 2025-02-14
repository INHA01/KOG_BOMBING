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
        if (blackBoard.inputs[EKey.ESC])
            return INode.ENodeState.Success;
        return INode.ENodeState.Fail;
    }
    public bool IsInteracting()
    {
        return isInteracting;
    }

    // >> TODO : Blackboard�� ����Ͽ� ���� ���� ������ �ִ� �۾��� ���̴� ��� �����غ���
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
        for (int i = 0; i < colliders.Length; i++)
        {
            if (colliders[i].gameObject == gameObject) continue;
            interactObj = colliders[i].GetComponent<IInteractAble>();
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
        bool isSuccess = iInteractObj.ProcessInteract(playerData.pv);
        if(!isSuccess) return INode.ENodeState.Fail;

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

    bool IInteractAble.ProcessInteract(PhotonView pView)
    {
        if (pView == null) return false;
        ETeam otherTeam = (ETeam)pView.Owner.CustomProperties["Team"];
        if (otherTeam != blackBoard.eTeam) return false;
        if (!Managers.PunData.GetPlayerBlackBoard(pView.Owner.NickName).isLive) return false;
        playerData.pv.RPC("RPCProcess", RpcTarget.AllBuffered);
        return true;
    }
    void IInteractAble.AbortInteract()
    {
        playerData.pv.RPC("RPCAbort", RpcTarget.AllBuffered);
    }
    [PunRPC]
    private void RPCProcess()
    {
        
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
        isReviving = true;
        int reviveInterval = 3;
        float time = Time.time + reviveInterval;
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
        blackBoard.playerStatus.hp = 50f;
        blackBoard.hpBar.SetHpValue(blackBoard.playerStatus.hp, blackBoard.playerStatus.defence);
        animator.SetAnimBool(PlayerAnimation.AnimType.Groggy, false);
        ChangeWeapon(WeaponType.GUN);
        playerData.speedDebuffPercent = 1f;
    }
}
