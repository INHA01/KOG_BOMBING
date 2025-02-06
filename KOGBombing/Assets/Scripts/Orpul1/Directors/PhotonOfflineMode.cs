using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using UnityEngine.UIElements;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;

public class PhotonOfflineMode : MonoBehaviourPunCallbacks
{
    [SerializeField]
    Transform spawnPosi;
    [SerializeField]
    GameObject playerCamera;
    [SerializeField]
    GameObject minimapCamera;

    UIPopup _uiScene;
    
    public float time = 180;
    public int blueScore = 0;
    public int redScore = 0;

    private void Awake()
    {
        PhotonNetwork.OfflineMode = true;
        PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", "RT" } });
        PhotonNetwork.ConnectUsingSettings();
        Debug.Log("OfflineMode On");
        StartCoroutine(TimeCount());
    }
    IEnumerator TimeCount()
    {
        while (time > 0)
        {
            yield return null;
            time -= Time.deltaTime;
        }
        Debug.Log("Time Over");
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
        GameObject minCamaraObj = Instantiate(minimapCamera, spawnPosi.position + new Vector3(0, 50f, 0), Quaternion.Euler(90, 0, 0));
        minCamaraObj.GetComponent<MinimapCamera>().target = playerObj;
		cameraObj.GetComponent<PlayerCamera>().target = playerObj;
        playerObj.GetComponent<PlayerController>().SetCamera(cameraObj.GetComponent<Camera>());
        _uiScene = Managers.UI.ShowPopupUI<UIPopup>("PlayCanvas");
        //_uiScene.GetComponent<PlayScene>().gameDirector = this;
        _uiScene.GetComponent<PlayScene>().weapon = playerObj.GetComponent<PlayerShooting>();
    }
}
