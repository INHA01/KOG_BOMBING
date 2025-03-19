using System;
using System.Collections;
using System.Collections.Generic;
using BAEK;
using Orpul1;
using Photon.Pun;
using UnityEngine;

public enum EDoorSound
{
    INTERACT,
    OPEN,
}
public class DoorInteractBehavior : InteractObject, IInteractAble
{
    enum EDoorAni
    {
        TriCloseDoor,
        TriOpenDoor,
        TriInitDoor
    }
   
    [SerializeField] InteractSound sound;
    [SerializeField] PhotonView pView;
    [SerializeField] DoorInteractBehavior otherDoor;
    [SerializeField] Animator animator;
    [SerializeField] GameObject doorUI;
    IActiveable activeAlertUI;
    IResetAble interactUICamera;
    Action openOtherDoor;
   
    protected override void Start()
    {
        base.Start();
        interactTime = 3;
        activeAlertUI = doorUI.GetComponent<IActiveable>();
        openOtherDoor -= otherDoor.OpenDoor;
        openOtherDoor += otherDoor.OpenDoor;
        interactUICamera = lookUiCamera.GetComponent<IResetAble>();
    }
    private void OnEnable()
    {
        GameEventBus.Subscribe(GameEventBus.EGameEvent.DOORCLOSE,CloseDoor);
    }
    private void OnDisable()
    {
        GameEventBus.UnSubscribe(GameEventBus.EGameEvent.DOORCLOSE, CloseDoor);
    }
    public override bool ProcessInteract(PhotonView pView)
    {
        if (interactState == InteractState.COMPLETE) return false;
        StartCoroutine(CoInteractDelay());
        
        return true;
    }
    [PunRPC]
    private void DoInteractDoor()
    {
        Debug.Log("DoInteractDoor");
        interactUI.ActiveCanInteract(false, InteractUI.Interact);
        OpenDoor();
        openOtherDoor();

    }
    public void OpenDoor()
    {
        Managers.Sound.PlayEffect(sound.DoorSounds[(int)EDoorSound.OPEN], EMixerGroup.EFFECT, transform, 1, 0, 30);
        activeAlertUI.Active();
        interactState = InteractState.COMPLETE;
        interactCollider.enabled = false;
        SetOutline(false);
        animator.SetTrigger(EDoorAni.TriOpenDoor.ToString());
    }
    public void CloseDoor()
    {
        interactState = InteractState.NONE;
        interactCollider.enabled = true;
        animator.SetTrigger(EDoorAni.TriCloseDoor.ToString());
        interactUICamera.DoReset();
    }
    [PunRPC]
    private void AbortInteractDoor()
    {
        interactState = InteractState.NONE;
    }
    protected override IEnumerator CoInteractDelay()
    {
        if (interactState == InteractState.INTERACTING) yield break;
        Managers.Sound.PlayEffect(sound.DoorSounds[(int)EDoorSound.INTERACT]);
        interactState = InteractState.INTERACTING;
        float deltaTime = 0;
        while (deltaTime < interactTime)
        {
            if (interactState == InteractState.NONE) yield break;
            deltaTime += Time.deltaTime;
            interactUI.Interact(deltaTime / interactTime);
            yield return null;
        }
        pView.RPC("DoInteractDoor", RpcTarget.AllBuffered);
    }
}
