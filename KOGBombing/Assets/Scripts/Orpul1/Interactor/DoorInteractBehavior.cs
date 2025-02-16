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
    [SerializeField] Collider interactCollider;
    [SerializeField] float doorOpenInterval = 3;

    Action openOtherDoor;
    bool isInteracting = false;
    bool isOpened = false;
    private void Start()
    {
        openOtherDoor += otherDoor.OpenDoor;
    }
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
        openOtherDoor();

    }
    public void OpenDoor()
    {
        isInteracting = false;
        isOpened = true;
        interactCollider.enabled = false;
        SetOutline(false);
        animator.SetTrigger(EDoorAni.TriOpenDoor.ToString());
        interactUI.DeactivePanel();
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
        pView.RPC("DoInteractDoor", RpcTarget.AllBuffered);
        
    }
}
