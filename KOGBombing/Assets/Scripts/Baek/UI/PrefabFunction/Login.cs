using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

public class Login : MonoBehaviourPunCallbacks
{
    [SerializeField] GameObject _login;
    [SerializeField] GameObject _serverSelect;
    public void OnLoginClick()
    {
        _login.SetActive(false);
        PhotonNetwork.ConnectUsingSettings();
    }
    public override void OnConnectedToMaster()
    {
        _serverSelect.SetActive(true);
    }
    public void OnStartClick()
    { 
        LoadingSceneManager.LoadScene("LobbyScene");
    }

}
