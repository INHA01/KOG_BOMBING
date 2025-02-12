using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

namespace Orpul1
{
    public interface IInteractAble
    {
        public bool ProcessInteract(PhotonView pView);
        public void AbortInteract();
    }
}