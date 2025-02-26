using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Orpul1;
using Photon.Pun;
using UnityEngine;

public abstract class InteractObject : Subject, IInteractAble
{
    [SerializeField]
    protected InteractPresenter interactUI;
    [SerializeField]
    GameObject showOutlineObj;
    [SerializeField] 
    protected Collider interactCollider;

    [SerializeField]
    LayerMask interactLayer;
    [SerializeField]
    LayerMask defualtLayer;
    [SerializeField]
    protected float interactTime = 0;

    protected enum InteractState
    {
        NONE,
        INTERACTING,
        COMPLETE
    }
    protected InteractState interactState = InteractState.NONE;
    public abstract bool ProcessInteract(PhotonView pView);
    public virtual void AbortInteract()
    {
        interactUI.AbortInteract();

        if (interactState == InteractState.COMPLETE) return;

        interactUI.AbortInteract();
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
        if(other.tag == "Player")
        {
            PhotonView pView = other.GetComponent<PhotonView>();
            if (!pView.IsMine) return;
            SetOutline(true);
            interactUI.ActivePanel();
        }
    }
    protected virtual void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            PhotonView pView = other.GetComponent<PhotonView>();
            if (!pView.IsMine) return;
            SetOutline(false);
            interactUI.DeactivePanel();
        }
       
    }

}
