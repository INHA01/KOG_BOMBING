using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Option : MonoBehaviour
{
    [SerializeField] GameObject reCheckLobby;
    [HideInInspector] public PlayerBlackBoard playerBlackBoard;
    private void Awake()
    {
        playerBlackBoard = null;
    }
    public void Cancel()
    {
        playerBlackBoard.inputs[EKey.Escape] = false;
        Managers.UI.CloseSceneUI();
    }
    public void ReturnLobby()
    { 
        reCheckLobby.SetActive(true);
    }
    public void ExitGame(bool yes)
    {
        if (yes)
            LoadingSceneManager.LoadScene("LobbyScene");
        else
            reCheckLobby.SetActive(false);
    }
}
