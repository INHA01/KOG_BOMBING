using System.Collections;
using System.Collections.Generic;
using BAEK;
using UnityEngine;
using static UnityEngine.Rendering.DebugUI;

namespace Orpul1
{
    public class PlayerInteractUIUpdater : MonoBehaviour
    {
        [SerializeField] GameObject player;
        ISetAble<bool> setCanActiveUI;
        Interacting interactUI;
        
        IEnumerator Start()
        {
            yield return null;
            interactUI = Managers.UI.GetPopupUI<Interacting>(UIKEY.Interacting);
            setCanActiveUI = player.GetComponent<ISetAble<bool>>();
            interactUI.ActiveCanInteract(false, InteractUI.Interact);
        }
        private void SetCanActiveUI(string tag, bool value)
        {
            if (tag != "BombInteract" && tag != "Bomb") return;
            setCanActiveUI.SetValue(value);
        }
        private void SetActiveInteractUI(Collider other,bool value)
        {
            IInteractAble interactObj = other.GetComponent<IInteractAble>();
            if (interactObj == null) return;
            if (interactUI == null) return;
            Debug.Log("Active interact UI!");
            interactUI.ActiveCanInteract(value, InteractUI.Interact);
        }
        private void OnTriggerEnter(Collider other)
        {
            SetCanActiveUI(other.tag, true);
            SetActiveInteractUI(other, true);
        }
        private void OnTriggerExit(Collider other)
        {
            SetCanActiveUI(other.tag, false);
            SetActiveInteractUI(other, false);
        }
    }
}
