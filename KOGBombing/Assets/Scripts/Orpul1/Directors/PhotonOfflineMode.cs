using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using Unity.VisualScripting;
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
        PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", ETeam.REDTEAM } });
        PhotonNetwork.ConnectUsingSettings();
        Debug.Log("OfflineMode On");
        StartCoroutine(TimeCount());
        EventBusSystem.Subscribe(SpawnPlayer);
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
        InitEvent();
        //SpawnPlayer();
        SelectPlayer();
    }
    public override void OnJoinRoomFailed(short returnCode, string message)
    {
        InitEvent();
        SpawnPlayer();
    }
    public override void OnCreateRoomFailed(short returnCode, string message)
    {
        Debug.Log("FailRoom");
    }
    private void InitEvent()
    {
        RaiseEventOptions options = new RaiseEventOptions();
        options.Receivers = ReceiverGroup.All;
        PhotonNetwork.RaiseEvent(3, null, options, SendOptions.SendReliable);
    }
    void CreateRoom()
    {
        Debug.Log("CreteRoom");
        PhotonNetwork.CreateRoom("OfflineModeRoom"+Time.time.ToString());
    }
    void SelectPlayer()
    {
        _uiScene = Managers.UI.ShowPopupUI<UIPopup>("CharacterChooseCanvas");
    }
    void SpawnPlayer()
    {
        GameObject playerObj = PhotonNetwork.Instantiate("Prefabs/PlayerPrefabs/" + _uiScene.GetComponent<ChoosePlayer>().type.ToString(), spawnPosi.position, Quaternion.Euler(0, 45, 0));
        GameObject cameraObj = Instantiate(playerCamera, new Vector3(-3, 7.5f, -3), Quaternion.Euler(50, 45, 0));
        GameObject minCamaraObj = Instantiate(minimapCamera, spawnPosi.position + new Vector3(0, 50f, 0), Quaternion.Euler(90, 0, 0));
        minCamaraObj.GetComponent<MinimapCamera>().target = playerObj;
		cameraObj.GetComponent<PlayerCamera>().target = playerObj;
        cameraObj.GetComponent<PlayerCamera>().minimapCamera = minCamaraObj;
        cameraObj.transform.SetParent(playerObj.transform);
        playerObj.GetComponent<PlayerController>().Init(cameraObj.GetComponent<Camera>(),spawnPosi.position);
        _uiScene = Managers.UI.ShowPopupUI<UIPopup>("PlayCanvas");
        //_uiScene.GetComponent<PlayScene>().gameDirector = this;
        _uiScene.GetComponent<PlayScene>().weapon = playerObj.GetComponent<PlayerShooting>();
        EventBusSystem.Unsubscribe(SpawnPlayer);
    }
}
