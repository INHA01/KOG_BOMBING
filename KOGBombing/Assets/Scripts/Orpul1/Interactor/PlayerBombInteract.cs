using System.Collections;
using System.Collections.Generic;
using BAEK;
using Photon.Pun;
using UnityEngine;

namespace Orpul1
{
    public class PlayerBombInteract : MonoBehaviour
    {
        [SerializeField] GameObject player;
        [SerializeField] PlayerBlackBoard blackBoard;
        [SerializeField] PlayerData playerData;
        ISetAble<bool> setCanActiveUI;
        Interacting bombNotify;
        bool canBombInteract = false;
        
        IEnumerator Start()
        {
            yield return null;
            bombNotify = Managers.UI.GetPopupUI<Interacting>(UIKEY.Interacting);
            setCanActiveUI = player.GetComponent<ISetAble<bool>>();
            bombNotify.ActiveCanInteract(false, InteractUI.Interact);
        }
        private void Update()
        {
            ConfirmBombInteract();
        }
        void ConfirmBombInteract()
        {
            bool isActive = (canBombInteract && blackBoard.inputs[EKey.NUM_2]);
            if (isActive == false) return;
            SetBombInteract(isActive);
        }
        private void SetBombInteract(bool isActive)
        {
            bombNotify.ActiveCanInteract(isActive, InteractUI.InteractBomb);
            playerData.isInteract = isActive;
        }

        private bool IsAttackTeamInteractBomb(string tag)
        {
            if (playerData.playerTeam != ETeam.REDTEAM) return false;
            if (tag != "BombInteract") return false;
            return true;
        }
        private bool IsDefenceTeamInteractBomb(string tag)
        {
            if (playerData.playerTeam != ETeam.BLUETEAM) return false;
            if (tag != "Bomb") return false;
            return true;
        }
        private void OnTriggerEnter(Collider other)
        {
            string tag = other.tag;

            if (IsAttackTeamInteractBomb(tag) || IsDefenceTeamInteractBomb(tag))
                canBombInteract = true;
        }
        private void OnTriggerExit(Collider other)
        {
            string tag = other.tag;
            if (tag != "BombInteract" & tag != "Bomb") return;
            canBombInteract = false;
            SetBombInteract(false);
        }
        /*private void SetCanActiveUI(string tag, bool value)
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
        private bool IsGorrgyPlayer(Collider other)
        {
            ETeam mTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
            ETeam otherTeam = other.GetComponent<PlayerBlackBoard>().playerTeam;
            if (mTeam != otherTeam) return false;
            return true;
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
        }*/
    }
}
