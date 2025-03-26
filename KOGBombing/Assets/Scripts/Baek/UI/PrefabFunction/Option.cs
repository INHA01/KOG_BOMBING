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
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        Managers.UI.ClosePopupUI(BAEK.UIKEY.Option);
    }
    public void ReturnLobby()
    {
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        reCheckLobby.SetActive(true);
    }
    public void ExitGame(bool yes)
    {
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        if (yes)
        {
            PhotonNetwork.LeaveRoom();
            Managers.PunData.Initialize();
            Managers.CamData.InitCamera();
            reCheckLobby.SetActive(false);
            Managers.UI.GetPopupUI<BattleBoardUpdater>(BAEK.UIKEY.BattleBoard).ResetScore();
            Managers.SceneLoad.LoadScene("LobbyScene");
        }
        else
            reCheckLobby.SetActive(false);
    }
}
