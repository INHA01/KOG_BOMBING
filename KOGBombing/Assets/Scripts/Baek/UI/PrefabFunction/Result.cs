using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Result : MonoBehaviour
{
    void Awake()
    {
        Managers.Resource.Instantiate("UIPrefabs/Scene/PlayScene/EndGame/ResultAvatar");
    }
    public void ReturnLobby()
    {
        Managers.UI.DestroyAllPopupUI();
        PhotonNetwork.LeaveRoom();
        Managers.PunData.Init();
        LoadingSceneManager.LoadScene("LobbyScene");
    }
}
