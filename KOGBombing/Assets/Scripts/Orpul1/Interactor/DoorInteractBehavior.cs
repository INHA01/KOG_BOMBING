using System;
using System.Collections;
using System.Collections.Generic;
using Orpul1;
using Photon.Pun;
using UnityEngine;

public class DoorInteractBehavior : MonoBehaviour, IInteractAble
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
    bool isInteracting = false;
    bool isOpened = false;
    public bool ProcessInteract(PhotonView pView)
    {
        if (isOpened) return false;
        StartCoroutine(CoWaitOpen());
        
        return true;
    }
    public void AbortInteract()
    {
        Debug.Log("AbortInteract");
        if (isOpened) return;
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
        float interval = Time.time + doorOpenInterval;
        while (interval > Time.time)
        {
            if (!isInteracting) yield break;
            yield return null;
        }
        
        pView.RPC("DoInteractDoor", RpcTarget.AllBuffered);
        
    }
}
