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

        UIScene _uiScene;

        void Start()
        {
            SpawnPlayer();

        }
        void SpawnPlayer()
        {

            int spawnIndex = 0;
            int teamIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties["TeamIndex"];

            if ((string)PhotonNetwork.LocalPlayer.CustomProperties["Team"] == "BT")
                spawnIndex = 1;
            Vector3 spawnPosi = teamSpawnPoints[spawnIndex].position;
            spawnPosi.x += (teamIndex % 2) * 0.5f - 1 * 2;
            spawnPosi.z += teamIndex * 0.5f * 2;

            GameObject playerObj = PhotonNetwork.Instantiate("Prefabs/PlayerPrefabs/Player", spawnPosi, Quaternion.Euler(0, 45, 0));
            GameObject cameraObj = Instantiate(playerCamera, new Vector3(-3, 7.5f, -3), Quaternion.Euler(50, 45, 0));
            cameraObj.GetComponent<PlayerCamera>().target = playerObj;
            playerObj.GetComponent<PlayerController>().SetCamera(cameraObj.GetComponent<Camera>());
            playerObj.GetComponent<PlayerController>().SpawnPoint = spawnPosi;
        }
       
    }
}
