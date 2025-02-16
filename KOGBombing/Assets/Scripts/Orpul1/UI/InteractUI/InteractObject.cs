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

    public abstract bool ProcessInteract(PhotonView pView);
    public virtual void AbortInteract()
    {
        interactUI.AbortInteract();
    }
    protected void SetOutline(bool isAdd)
    {
        if (isAdd)
        {
            showOutlineObj.layer = LayerMask.NameToLayer("InteractObj");
        }
        else
        {
            showOutlineObj.layer = LayerMask.NameToLayer("Default");
        }
    }
    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            PhotonView pView = other.GetComponent<PhotonView>();
            if (!pView.IsMine) return;
            SetOutline(true);
            interactUI.ActivePanel();
        }
    }
    private void OnTriggerExit(Collider other)
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
