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
    MeshRenderer meshRenderer;
    [SerializeField]
    protected Material outline;

    public abstract bool ProcessInteract(PhotonView pView);
    public virtual void AbortInteract()
    {
        interactUI.AbortInteract();
    }
    protected void SetOutline(bool isAdd)
    {
        List<Material> materialList = meshRenderer.materials.ToList();
        if (isAdd)
        {
            materialList.Add(outline);
            meshRenderer.materials = materialList.ToArray();
        }
        else
        {
            if (materialList[1]!=null)
                materialList.RemoveAt(1);
            meshRenderer.materials = materialList.ToArray();
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
