using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Option : UIPopup
{
    [SerializeField] GameObject reCheckLobby;
    [HideInInspector] public PlayerBlackBoard playerBlackBoard;
    private void Awake()
    {
        playerBlackBoard = null;
    }
    public void Cancel()
    {
        playerBlackBoard.inputs[EKey.ESC] = false;
        LocalManagers.UI.ClosePopupUI(this.gameObject.name);
    }
    public void ReturnLobby()
    { 
        reCheckLobby.SetActive(true);
    }
    public void ExitGame(bool yes)
    {
        if (yes)
        {
            PhotonNetwork.LeaveRoom();
            LocalManagers.PunData.Init();
            LocalManagers.CamData.InitCamera();
            LoadingSceneManager.LoadScene("LobbyScene");
        }
        else
            reCheckLobby.SetActive(false);
    }
}
