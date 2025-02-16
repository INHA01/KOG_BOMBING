using System;
using System.Collections;
using System.Collections.Generic;
using Orpul1;
using Photon.Pun;
using UnityEngine;

public class DoorInteractBehavior : InteractObject, IInteractAble
{
    enum EDoorAni
    {
        TriCloseDoor,
        TriOpenDoor,
        TriInitDoor
    }
    [SerializeField] Animator animator;
    [SerializeField] PhotonView pView;
    [SerializeField] float doorOpenInterval = 3;
    [SerializeField] DoorInteractBehavior otherDoor;
    [SerializeField] Collider interactCollider;
    bool isInteracting = false;
    bool isOpened = false;
    public override bool ProcessInteract(PhotonView pView)
    {
        if (isOpened) return false;

        StartCoroutine(CoWaitOpen());
        
        return true;
    }
    public override void AbortInteract()
    {
        base.AbortInteract();
        Debug.Log("AbortInteract");
        if (isOpened) return;

        interactUI.AbortInteract();
        isInteracting = false;
        //pView.RPC("AbortInteractDoor", RpcTarget.AllBuffered);
    }
    [PunRPC]
    private void DoInteractDoor()
    {
        Debug.Log("DoInteractDoor");
        OpenDoor();
        otherDoor.OpenDoor();

        isInteracting = false;
        isOpened = true;
    }
    public void OpenDoor()
    {
        animator.SetTrigger(EDoorAni.TriOpenDoor.ToString());
    }
    [PunRPC]
    private void AbortInteractDoor()
    {
        isInteracting = false;
    }
    IEnumerator CoWaitOpen()
    {
        if (isInteracting) yield break;
        isInteracting = true;
        float deltaTime = 0;
        while (deltaTime < doorOpenInterval) 
        {
            if (!isInteracting) yield break;
            deltaTime += Time.deltaTime;
            interactUI.SetValue(deltaTime);
            yield return null;
        }
        interactUI.DeactivePanel();
        interactCollider.enabled = false;
        pView.RPC("DoInteractDoor", RpcTarget.AllBuffered);
        
    }
}
