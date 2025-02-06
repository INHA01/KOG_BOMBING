using Orpul1;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Photon.Pun;
public class Winner : MonoBehaviour
{
    [SerializeField] GameObject redWin;
    [SerializeField] GameObject blueWin;
    private void Awake()
    {
        if (GameDirector.redScore > GameDirector.blueScore)
        {
            redWin.SetActive(true);
            blueWin.SetActive(false);
        }
        else
        {
            blueWin.SetActive(true);
            redWin.SetActive(false);
        }
    }
    public void ReturnLobby()
    {
        PhotonNetwork.LeaveRoom();
        Managers.PunData.Init();
        LoadingSceneManager.LoadScene("LobbyScene");
    }
}
