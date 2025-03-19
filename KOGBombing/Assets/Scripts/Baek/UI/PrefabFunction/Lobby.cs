using Orpul1;
using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class Lobby : MonoBehaviour
{
    enum LobbyButtonType
    {
        PLAY,
        SELECTMODE,
        Max
    }
    enum ProfileType
    {
        USERNAME,
        WINNINGRATE,
        KILL,
        DEATH,
        Max
    }
    [SerializeField] GameObject[] lobbyButton = new GameObject[(int)LobbyButtonType.Max];
    [SerializeField] NetworkDirector networkDirector;
    [SerializeField] TextMeshProUGUI[] profile = new TextMeshProUGUI[(int)ProfileType.Max];
    public Image profileImage;

    LobbyModeSelect _lobbyModeSelect;
    void Start()
    {
        profile[(int)ProfileType.USERNAME].text = Managers.UserData.userData.nickName;
        float allGame = Managers.UserData.userData.win + Managers.UserData.userData.lose;
        float winRate = allGame == 0 ? 0 : (float)Managers.UserData.userData.win / allGame * 100;
        profile[(int)ProfileType.WINNINGRATE].text = winRate.ToString("F2") + "%";
        profile[(int)ProfileType.KILL].text = Managers.UserData.userData.kill.ToString();
        profile[(int)ProfileType.DEATH].text = Managers.UserData.userData.death.ToString();
        profileImage.sprite = Resources.Load<Sprite>("UISettings/Lobby/Profile_" + (CharacterType)Managers.UserData.userData.profileType);
    }
    public void OnPlayClick()
    {
        lobbyButton[(int)LobbyButtonType.PLAY].SetActive(false);
        lobbyButton[(int)LobbyButtonType.SELECTMODE].SetActive(true);
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        OnSelectClick();
    }
    public void OnSelectClick()
    {
        _lobbyModeSelect = Managers.UI.ShowPopupUI<LobbyModeSelect>(BAEK.UIKEY.SelectMode);
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
    }
    public void OnGameStartClick()
    {
        Managers.Sound.PlayUISound(EUiSoundType.CLICK);
        GameObject selectMode = lobbyButton[(int)LobbyButtonType.SELECTMODE];
        selectMode.GetComponent<Button>().interactable = !selectMode.GetComponent<Button>().interactable;
        networkDirector.Match((EMatchType)_lobbyModeSelect.mode);
    }
}
