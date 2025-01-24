using Orpul1;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Lobby : MonoBehaviour
{
    [SerializeField] GameObject playButton;
    [SerializeField] GameObject selectMode;
    [SerializeField] GameObject gameStartButton;
    [SerializeField] NetworkDirector networkDirector;

    UIScene _uiScene;
    LobbyModeSelect _lobbyModeSelect;
    public void OnPlayClick()
    {
        playButton.SetActive(false);
        selectMode.SetActive(true);
        OnSelectClick();
    }
    public void OnSelectClick()
    {
        _uiScene = Managers.UI.ShowSceneUI<UIScene>("SelectModeCanvas");
        _lobbyModeSelect = _uiScene.GetComponent<LobbyModeSelect>();
    }
    public void OnGameStartClick()
    {
        networkDirector.Match(_lobbyModeSelect.mode);
    }
}
