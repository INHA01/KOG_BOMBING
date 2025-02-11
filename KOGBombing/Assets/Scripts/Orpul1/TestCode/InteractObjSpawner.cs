using System.Collections;
using System.Collections.Generic;
using ExitGames.Client.Photon;
using Photon.Pun;
using UnityEngine;

public class InteractObjSpawner : MonoBehaviourPunCallbacks
{
    [SerializeField]
    string path = "Prefabs/InteractPrefabs/InteractObject";
    private void Awake()
    {
        PhotonNetwork.NetworkingClient.EventReceived += SpawnEvent;
    }
    private void Start()
    {
    }
    public override void OnJoinedRoom()
    {
        PhotonNetwork.Instantiate(path, Vector3.zero, Quaternion.identity);
    }
    private void SpawnEvent(EventData photonEvent)
    {
        if(photonEvent.Code == 3)
        {
        }
    }
}
