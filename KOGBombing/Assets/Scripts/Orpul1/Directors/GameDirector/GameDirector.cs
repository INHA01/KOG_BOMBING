using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

namespace Orpul1
{
    public class GameDirector : MonoBehaviour
    {
        [SerializeField]
        GameObject playerCamera;
        [SerializeField]
        Transform[] teamSpawnPoints;
        private void Awake()
        {
            Application.targetFrameRate = 60;
        }
        void Start()
        {
            SpawnPlayer();
        }
        void SpawnPlayer()
        {
            int spawnIndex = 0;
            int teamSpawnSpot = (int)PhotonNetwork.LocalPlayer.CustomProperties["TeamIndex"];
            if ((string)PhotonNetwork.LocalPlayer.CustomProperties["Team"] == "BT")
                spawnIndex = 1;
            Vector3 spawnPosi = teamSpawnPoints[spawnIndex].position;
            Debug.Log($"teamSpawnSpot : {teamSpawnSpot}");
            spawnPosi.x += 1 - (teamSpawnSpot % 2) * 0.5f;
            spawnPosi.y += teamSpawnSpot * 0.5f;

            GameObject playerObj = PhotonNetwork.Instantiate("Prefabs/PlayerPrefabs/Player", spawnPosi, Quaternion.Euler(0, 45, 0));
            GameObject cameraObj = Instantiate(playerCamera, new Vector3(-3, 7.5f, -3), Quaternion.Euler(50, 45, 0));
            cameraObj.GetComponent<PlayerCamera>().target = playerObj;
            playerObj.GetComponent<PlayerController>().SetCamera(cameraObj.GetComponent<Camera>());

            /* 
            1
                  *
            
            2
                *   *

            3
                  *
                *   *      
               
            4
                *   *
                *   *

            5.
                  *
                *   *
                *   *
            
            6
                *   *
                *   *
                *   *
             */
        }
    }
}
