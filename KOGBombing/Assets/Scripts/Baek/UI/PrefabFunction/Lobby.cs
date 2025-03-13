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
        userName.text = Managers.UserData.userData.nickName;
    }
    public void OnPlayClick()
    {
        playButton.SetActive(false);
        selectMode.SetActive(true);
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        OnSelectClick();
    }
    public void OnSelectClick()
    {
        _lobbyModeSelect = Managers.UI.ShowPopupUI<LobbyModeSelect>("SelectModeCanvas");
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
    }
    public void OnGameStartClick()
    {
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        selectMode.GetComponent<Button>().interactable = !selectMode.GetComponent<Button>().interactable;
        networkDirector.Match((EMatchType)_lobbyModeSelect.mode);
    }
}
