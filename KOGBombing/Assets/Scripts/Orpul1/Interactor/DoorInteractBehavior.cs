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
    [SerializeField] PhotonView pView;
    [SerializeField] DoorInteractBehavior otherDoor;
    [SerializeField] Animator animator;

    Action openOtherDoor;
   
    private void Start()
    {
        interactTime = 3;
        openOtherDoor += otherDoor.OpenDoor;
    }
    public override bool ProcessInteract(PhotonView pView)
    {
        if (interactState == InteractState.COMPLETE) return false;

        StartCoroutine(CoInteractDelay());
        
        return true;
    }/*
    public override void AbortInteract()
    {
        base.AbortInteract();
        Debug.Log("AbortInteract");
        if (interactState == InteractState.COMPLETE) return;

        interactUI.AbortInteract();
        interactState = InteractState.NONE;
    }*/
    [PunRPC]
    private void DoInteractDoor()
    {
        Debug.Log("DoInteractDoor");
        OpenDoor();
        openOtherDoor();

    }
    public void OpenDoor()
    {
        interactState = InteractState.COMPLETE;
        interactCollider.enabled = false;
        SetOutline(false);
        animator.SetTrigger(EDoorAni.TriOpenDoor.ToString());
        interactUI.DeactivePanel();
    }
    [PunRPC]
    private void AbortInteractDoor()
    {
        interactState = InteractState.NONE;
    }
    protected override IEnumerator CoInteractDelay()
    {
        if (interactState == InteractState.INTERACTING) yield break;
        interactState = InteractState.INTERACTING;
        float deltaTime = 0;
        while (deltaTime < interactTime)
        {
            if (interactState == InteractState.NONE) yield break;
            deltaTime += Time.deltaTime;
            interactUI.SetValue(deltaTime);
            yield return null;
        }
        pView.RPC("DoInteractDoor", RpcTarget.AllBuffered);
    }
}
