using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;

public class PhotonOfflineMode : MonoBehaviourPunCallbacks
{
    [SerializeField]
    Transform spawnPosi;
    [SerializeField]
    GameObject playerCamera;
    private void Awake()
    {
        PhotonNetwork.OfflineMode = true;
        PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", "RT" } });
        PhotonNetwork.ConnectUsingSettings();
        Debug.Log("OfflineMode On");
    }
    public override void OnConnectedToMaster()
    {

        Debug.Log("Call back Master");
        CreateRoom();
        
    }
    public override void OnJoinedRoom()
    {
        SpawnPlayer();
    }
    void CreateRoom()
    {
        PhotonNetwork.CreateRoom("OfflineModeRoom");
        RoomOptions roomOptions = new RoomOptions();
        
    }
    void SpawnPlayer()
    {
        GameObject playerObj = PhotonNetwork.Instantiate("Prefabs/PlayerPrefabs/SinglePlayer", spawnPosi.position, Quaternion.Euler(0, 45, 0));
        GameObject cameraObj = Instantiate(playerCamera, new Vector3(-3, 7.5f, -3), Quaternion.Euler(50, 45, 0));
        cameraObj.GetComponent<PlayerCamera>().target = playerObj;
        playerObj.GetComponent<PlayerController>().SetCamera(cameraObj.GetComponent<Camera>());
    }
}
