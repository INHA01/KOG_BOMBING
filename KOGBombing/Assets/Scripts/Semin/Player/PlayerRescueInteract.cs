using System.Collections;
using System.Collections.Generic;
using BAEK;
using Orpul1;
using Photon.Pun;
using Unity.VisualScripting;
using UnityEngine;

public class PlayerRescueInteract : MonoBehaviour
{
    [SerializeField] GameObject player;
    [SerializeField] PlayerBlackBoard blackBoard;
    [SerializeField] PlayerData playerData;
    Interacting interactUI;
    private void Awake()
    {
        SetInteractUI();
    }
    protected void SetInteractUI()
    {
        interactUI = Managers.UI.GetPopupUI<Interacting>(UIKEY.Interacting);
    }
    protected void OnTriggerEnter(Collider other)
    {
        PlayerBlackBoard blackBoardInfo = other.GetComponent<PlayerBlackBoard>();
        if (blackBoardInfo == null) return;
        if (!blackBoardInfo.playerStatus.isGroggy) return;
        if (interactUI == null) SetInteractUI();
        if (!playerData.pv.IsMine) return;
        ETeam otherTeam = other.GetComponent<IGetTeamTypeable>().GetTeamType();
        if (otherTeam != playerData.playerTeam) return;
        Debug.Log("Active Interact Trigger");
        interactUI.gameObject.SetActive(true);
        interactUI.ActiveCanInteract(true, InteractUI.Interact);
    }
    protected void OnTriggerExit(Collider other)
    {
        PlayerBlackBoard blackBoardInfo = other.GetComponent<PlayerBlackBoard>();
        if (blackBoardInfo == null) return;
        if (!blackBoardInfo.playerStatus.isGroggy) return;
        ETeam otherTeam = other.GetComponent<IGetTeamTypeable>().GetTeamType();
        if (otherTeam != playerData.playerTeam) return;
        interactUI.ActiveCanInteract(false, InteractUI.Interact);
    }
}
