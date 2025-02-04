using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Option : MonoBehaviour
{
    [SerializeField] GameObject reCheckLobby;
    public void Cancel()
    {
        this.gameObject.SetActive(false);
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
