using System.Collections;
using System.Collections.Generic;
using System.Linq;
using BAEK;
using Orpul1;
using Photon.Pun;
using UnityEngine;

public abstract class InteractObject : Subject, IInteractAble
{
    [SerializeField] 
    protected GameObject lookUiCamera;
    [SerializeField]
    GameObject showOutlineObj;
    [SerializeField] 
    protected Collider interactCollider;

    [SerializeField]
    protected int interactLayer;
    [SerializeField]
    protected int defualtLayer;
    [SerializeField]
    protected float interactTime = 0;
    protected Interacting interactUI;

    protected enum InteractState
    {
        NONE,
        INTERACTING,
        COMPLETE
    }
    protected InteractState interactState = InteractState.NONE;

    protected virtual void Start()
    {
        SetInteractUI();
    }
    protected void SetInteractUI()
    {
        interactUI = Managers.UI.GetPopupUI<Interacting>(UIKEY.Interacting);
    }
    public abstract bool ProcessInteract(PhotonView pView);
    public virtual void AbortInteract()
    {
        if (interactState == InteractState.COMPLETE) return;

        interactUI.Interact(0);
        interactState = InteractState.NONE;
    }
    protected void SetOutline(bool isAdd)
    {
        if (isAdd)
        {
            showOutlineObj.layer = interactLayer;
        }
        else
        {
            showOutlineObj.layer = defualtLayer;
        }
    }
    protected abstract IEnumerator CoInteractDelay();
    protected virtual void OnTriggerEnter(Collider other)
    {
        if (other.tag != "Player") return;
        if (interactUI == null) SetInteractUI();
        PhotonView pView = other.GetComponent<PhotonView>();
        if (!pView.IsMine) return;
        SetOutline(true);
        interactUI.gameObject.SetActive(true);
        interactUI.ActiveCanInteract(true, InteractUI.Interact);
    }
    protected virtual void OnTriggerExit(Collider other)
    {
        if (other.tag != "Player") return;
        PhotonView pView = other.GetComponent<PhotonView>();
        if (!pView.IsMine) return;
        SetOutline(false);
        interactUI.ActiveCanInteract(false, InteractUI.Interact);
    }
}
