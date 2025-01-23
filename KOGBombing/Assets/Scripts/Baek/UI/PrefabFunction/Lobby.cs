using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Lobby : MonoBehaviour
{
    [SerializeField] GameObject playButton;
    [SerializeField] GameObject selectMode;
    [SerializeField] GameObject gameStartButton;

    //UIScene _uiScene;
    public void OnPlayClick()
    {
        playButton.SetActive(false);
        selectMode.SetActive(true);
        OnSelectClick();
    }
    public void OnSelectClick()
    {
        //if(_uiScene == null)
        //    _uiScene = Managers.UI.ShowSceneUI<UIScene>("SelectModeCanvas");
        Managers.UI.ShowSceneUI<UIScene>("SelectModeCanvas");
    }
    public void OnGameStartClick()
    {
        //LoadingSceneManager.LoadScene("AttackTest");
        LoadingSceneManager.LoadScene("PhotonLoginScene");
    }
}
