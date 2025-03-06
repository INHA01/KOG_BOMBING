using Orpul1;
using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class Lobby : MonoBehaviour
{
    [SerializeField] GameObject playButton;
    [SerializeField] GameObject selectMode;
    [SerializeField] GameObject gameStartButton;
    [SerializeField] NetworkDirector networkDirector;
    [SerializeField] TextMeshProUGUI userName;

    LobbyModeSelect _lobbyModeSelect;
    void Start()
    {
        //PhotonNetwork.LocalPlayer.NickName = Managers.UserData.userData.nickName;
        userName.text = PhotonNetwork.LocalPlayer.NickName;
    }
    public void OnPlayClick()
    {
        playButton.SetActive(false);
        selectMode.SetActive(true);
        SoundManager.Instance.PlayUISound(EUiSoundType.CLICK);
        OnSelectClick();
    }
    public void OnSelectClick()
    {
        UIPopup _uiScene = LocalManagers.UI.ShowPopupUI<UIPopup>("SelectModeCanvas");
        SoundManager.Instance.PlayUISound(EUiSoundType.CLICK);
        _lobbyModeSelect = _uiScene.GetComponent<LobbyModeSelect>();
    }
    public void OnGameStartClick()
    {
        SoundManager.Instance.PlayUISound(EUiSoundType.CLICK);
        selectMode.GetComponent<Button>().interactable = !selectMode.GetComponent<Button>().interactable;
        networkDirector.Match(_lobbyModeSelect.mode);
    }
}
