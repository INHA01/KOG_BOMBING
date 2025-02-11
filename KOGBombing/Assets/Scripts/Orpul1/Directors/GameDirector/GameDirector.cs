using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;
using Photon.Realtime;

namespace Orpul1
{
    public class GameDirector : MonoBehaviour
    {
        [SerializeField]
        GameObject playerCamera;
        [SerializeField]
        GameObject minimapCamera;
        [SerializeField]
        Transform[] teamSpawnPoints;

        [Header("Photon")]
        [SerializeField] public PhotonView pv;

        UIPopup _uiScene;

        public float time = 180;
        public static int blueScore = 0;
        public static int redScore = 0;

        void Start()
        {
            SpawnPlayer();
            StartCoroutine(TimeCount());
        }
        [PunRPC]
        public void UpdateScores(int newBlueScore, int newRedScore)
        {
            blueScore = newBlueScore;
            redScore = newRedScore;
        }
        IEnumerator TimeCount()
        {
            while (true)
            {
                if ((time < 0 || blueScore > 9 || redScore > 9))
                    break;
                yield return null;
                time -= Time.deltaTime;
            }
            Debug.Log("Time Over");
            Managers.UI.ShowPopupUI<UIPopup>("WinnerCanvas");
        }
        void SpawnPlayer()
        {
            int spawnIndex = 0;
            int teamSpawnSpot = (int)PhotonNetwork.LocalPlayer.CustomProperties["TeamIndex"];
            if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"] == ETeam.BLUETEAM)
                spawnIndex = 1;
            Vector3 spawnPosi = teamSpawnPoints[spawnIndex].position;
            spawnPosi.x += (teamSpawnSpot % 2) * 0.5f - 1 * 2;
            spawnPosi.z += teamSpawnSpot * 0.5f * 2;

            Debug.Log($"teamSpawnSpot : {teamSpawnSpot}");
            Debug.Log($"spawnPosi : {spawnPosi}");
            GameObject playerObj = PhotonNetwork.Instantiate("Prefabs/PlayerPrefabs/Player", spawnPosi, Quaternion.Euler(0, 45, 0));
            GameObject cameraObj = Instantiate(playerCamera, new Vector3(-3, 7.5f, -3), Quaternion.Euler(50, 45, 0));
            GameObject minCamaraObj = Instantiate(minimapCamera, spawnPosi + new Vector3(0, 50f, 0), Quaternion.Euler(90, 0, 0));
            minCamaraObj.GetComponent<MinimapCamera>().target = playerObj;
            cameraObj.GetComponent<PlayerCamera>().target = playerObj;
            cameraObj.GetComponent<PlayerCamera>().minimapCamera = minCamaraObj;
            cameraObj.transform.SetParent(playerObj.transform);
            playerObj.GetComponent<PlayerController>().SetCamera(cameraObj.GetComponent<Camera>());
            _uiScene = Managers.UI.ShowPopupUI<UIPopup>("PlayCanvas");
            //_uiScene.GetComponent<PlayScene>().gameDirector = this;
            _uiScene.GetComponent<PlayScene>().weapon = playerObj.GetComponent<PlayerShooting>();
        }
    }
}
