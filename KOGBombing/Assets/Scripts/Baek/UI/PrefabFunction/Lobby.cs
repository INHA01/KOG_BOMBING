using Orpul1;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;

public class Lobby : MonoBehaviour
{
    [SerializeField] GameObject playButton;
    [SerializeField] GameObject selectMode;
    [SerializeField] GameObject gameStartButton;
    [SerializeField] NetworkDirector networkDirector;

    UIPopup _uiScene;
    LobbyModeSelect _lobbyModeSelect;
    public void OnPlayClick()
    {
        playButton.SetActive(false);
        selectMode.SetActive(true);
        OnSelectClick();
    }
    public void OnSelectClick()
    {
        _uiScene = Managers.UI.ShowPopupUI<UIPopup>("SelectModeCanvas");
        _lobbyModeSelect = _uiScene.GetComponent<LobbyModeSelect>();
    }
    public void OnGameStartClick()
    {
        selectMode.GetComponent<Button>().interactable = !selectMode.GetComponent<Button>().interactable;
        networkDirector.Match(_lobbyModeSelect.mode);
    }
}
