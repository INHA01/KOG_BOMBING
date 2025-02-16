using System.Collections;
using System.Collections.Generic;
using Orpul1;
using Photon.Pun;
using UnityEngine;

public abstract class InteractObject : Subject, IInteractAble
{
    [SerializeField]
    protected InteractPresenter interactUI;

    public abstract bool ProcessInteract(PhotonView pView);
    public virtual void AbortInteract()
    {
        interactUI.AbortInteract();
    }
    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            interactUI.ActivePanel();
        }
    }
    private void OnTriggerExit(Collider other)
    {
        interactUI.DeactivePanel();
    }

}
