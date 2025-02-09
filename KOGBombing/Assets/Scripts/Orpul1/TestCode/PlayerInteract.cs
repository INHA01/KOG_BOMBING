using System.Collections;
using System.Collections.Generic;
using Orpul1;
using Photon.Pun;
using Semin;
using UnityEngine;

public class PlayerInteract : PlayerBehavior
{
    IInteractAble iInteractObj;
    public bool isInteracting = false;
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
    public INode.ENodeState FindInteractObj()
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
            interactObj = colliders[i].GetComponent<IInteractAble>();
            if (interactObj != null) break;
        }
        if (interactObj == null) return false;

        iInteractObj = interactObj;
        return true;
    }

    public INode.ENodeState ProcessInteract()
    {
        Debug.Log("Process Interact");
        isInteracting = true;
        iInteractObj.ProcessInteract();
        return INode.ENodeState.Success;

    }

    public INode.ENodeState AbortInteract()
    {
        if (iInteractObj == null) return INode.ENodeState.Fail;
        iInteractObj.AbortInteract();
        isInteracting = false;
        iInteractObj = null;
        blackBoard.inputs[EKey.F] = false;
        return INode.ENodeState.Success;
    }
    
}
