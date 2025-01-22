using System.Collections;
using System.Collections.Generic;
using Orpul1;
using Unity.VisualScripting;
using UnityEngine;

public class PlayerInteract
{
    Transform trPlayer;
    IInteractAble interactObj;
    private bool canInteract = true;
    public bool CanInteract {  get { return canInteract; } }
    // >> TODO : Blackboard를 사용하여 값을 따로 설정해 주는 작업을 줄이는 방안 검토해보기
    public void Init(Transform transform)
    {
        trPlayer = transform;
    }

    public void ProcessInteract()
    {
        Collider[] colliders = Physics.OverlapSphere(trPlayer.position, 1f);
        if (colliders.Length == 0) return;
        for (int i = 0; i < colliders.Length; i++) 
        {
            interactObj = colliders[i] as IInteractAble;
            if (interactObj != null)
                break;
        }
        if (interactObj == null) return;
        canInteract = false;
        Debug.Log("상호작용 실행");
        interactObj.ProcessInteract();
    }

    public void AbortInteract()
    {
        if (interactObj == null) return;
        Debug.Log("상호작용 중단");
        interactObj.AbortInteract();
        canInteract = true;
        interactObj = null;
    }

}
