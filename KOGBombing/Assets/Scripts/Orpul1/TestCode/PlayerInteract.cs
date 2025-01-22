using System.Collections;
using System.Collections.Generic;
using Orpul1;
using Unity.VisualScripting;
using UnityEngine;

public class PlayerInteract
{
    Transform trPlayer;
    IInteractAble iInteractObj;
    private bool canInteract = true;
    public bool isInteracting = false;
    // >> TODO : Blackboard를 사용하여 값을 따로 설정해 주는 작업을 줄이는 방안 검토해보기
    public void Init(Transform transform)
    {
        trPlayer = transform;
    }

    public bool FindInteractObj()
    {
        Collider[] colliders = Physics.OverlapSphere(trPlayer.position, 1f);
        
        if (colliders.Length == 0) return false;
        IInteractAble interactObj = null;
        for (int i = 0; i < colliders.Length; i++) 
        {
            interactObj = colliders[i].GetComponent<IInteractAble>();
            if (interactObj != null) break;
        }
        if (interactObj == null) return false;
        
        iInteractObj = interactObj;
        Debug.Log("Find interact Object");
        return true;
    }

    public void ProcessInteract()
    {
        Debug.Log("Process Interact");
        isInteracting = true;
        iInteractObj.ProcessInteract();
    }

    public void AbortInteract()
    {
        Debug.Log("Abort Interact");
        if (iInteractObj == null) return;
        iInteractObj.AbortInteract();
        isInteracting = false;
        iInteractObj = null;
    }

}
