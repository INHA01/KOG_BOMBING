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
    [SerializeField]
    GameObject uiCanvas;

    UIScene _uiScene;

    private void Awake()
    {
        PhotonNetwork.OfflineMode = true;
        PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", "BT" } });
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
        Debug.Log("JoinRoom");
        SpawnPlayer();
    }
    public override void OnJoinRoomFailed(short returnCode, string message)
    {
        SpawnPlayer();
    }
    public override void OnCreateRoomFailed(short returnCode, string message)
    {
        Debug.Log("FailRoom");
    }
    void CreateRoom()
    {
        Debug.Log("CreteRoom");
        PhotonNetwork.CreateRoom("OfflineModeRoom"+Time.time.ToString());
    }
    void SpawnPlayer()
    {
        GameObject playerObj = PhotonNetwork.Instantiate("Prefabs/PlayerPrefabs/SinglePlayer", spawnPosi.position, Quaternion.Euler(0, 45, 0));
        GameObject cameraObj = Instantiate(playerCamera, new Vector3(-3, 7.5f, -3), Quaternion.Euler(50, 45, 0));
		GameObject canvasObj = Instantiate(uiCanvas);
		cameraObj.GetComponent<PlayerCamera>().target = playerObj;
        playerObj.GetComponent<PlayerController>().SetCamera(cameraObj.GetComponent<Camera>());
        _uiScene = Managers.UI.ShowSceneUI<UIScene>("PlayCanvas");
        _uiScene.GetComponent<PlayScene>().weapon = playerObj.GetComponent<PlayerShooting>();

        canvasObj.GetComponent<HpBarDirector>().SetCamera(cameraObj.GetComponent<Camera>());  
    }
}
