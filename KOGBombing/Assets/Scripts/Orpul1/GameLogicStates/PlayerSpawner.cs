using System;
using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;
using static Photon.Pun.UtilityScripts.PunTeams;

namespace Orpul1
{
    public class PlayerSpawner : GameProcessLogic
    {
        [SerializeField]
        Transform[] teamSpawnPoints;
        [SerializeField]
        GameObject playerCamera;
        [SerializeField]
        GameObject minimapCamera;

        [SerializeField] int DebugSpawnPlayerCount = 5;
        bool isSpawnPlayer = false;

        public override void EnterState()
        {
            isSpawnPlayer = false;
            Debug.Log($"SpawnEnterState");
            SpawnPlayer();
        }
        public override void UpdateState()
        {
            if (isSpawnPlayer)
                transitionState((int)EGameState.ROUNDWAIT);
        }
        public override void ExitState()
        {
        }


        void SpawnPlayer()
        {
            Debug.Log($"SpawnPlayer()");
            Vector3 spawnPosi = SetSpawnPoint();
            DoSpawnPlayer(spawnPosi);
            isSpawnPlayer = true;
        }
        Vector3 SetSpawnPoint()
        {
            int spawnIndex = 0;
            int teamSpawnSpot = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
            if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()] == ETeam.BLUETEAM)
                spawnIndex = 1;
            Vector3 spawnPosi = teamSpawnPoints[spawnIndex].position;
            spawnPosi.x += (teamSpawnSpot % 2) * 0.5f - 1 * 2;
            spawnPosi.z += teamSpawnSpot * 0.5f * 2;

            return spawnPosi;
        }
        void DoSpawnPlayer(Vector3 spawnPosi)
        {
            GameObject playerObj = PhotonNetwork.Instantiate("Prefabs/PlayerPrefabs/" + gameData.selectCharacterPath.ToString(), spawnPosi, Quaternion.Euler(0, 45, 0));
            GameObject cameraObj = Instantiate(playerCamera, new Vector3(-3, 7.5f, -3), Quaternion.Euler(50, 45, 0));
            GameObject minCamaraObj = Instantiate(minimapCamera, spawnPosi + new Vector3(0, 50f, 0), Quaternion.Euler(90, 0, 0));
            minCamaraObj.GetComponent<MinimapCamera>().target = playerObj;
            cameraObj.GetComponent<PlayerCamera>().target = playerObj;
            cameraObj.GetComponent<PlayerCamera>().minimapCamera = minCamaraObj;
            cameraObj.GetComponent<PlayerCamera>().SettingTargetPos(playerObj.transform);
            Managers.CamData.AddCamera(cameraObj, ECameraType.MAINCAMERA);
            Managers.CamData.AddCamera(minCamaraObj, ECameraType.MINIMAPCAMERA);
            Managers.CamData.AddCamera(cameraObj.transform.GetChild(0).gameObject, ECameraType.EFFECTCAMERA);
            playerObj.GetComponent<PlayerController>().Initialize(cameraObj.GetComponent<Camera>(), spawnPosi, gameObject);
            playerObj.GetComponent<ITeamUIInitAble>().SetTeamUI(gameData.teamUIController);
            gameData.playerSetGameState = playerObj.GetComponent<ISetGameStateAble>();
            gameData.playerObj = playerObj;
        }
        private void OnDrawGizmos()
        {
            Gizmos.color = Color.green;
            for (int teamType = 0; teamType < (int)ETeam.END; teamType++)
            {
                for (int index = 0; index < DebugSpawnPlayerCount; index++)
                {
                    DebugDrawSpawnPosi(index, teamType);
                }
            }
        }
        private void DebugDrawSpawnPosi(int index, int teamType)
        {
            Vector3 spawnPosi = teamSpawnPoints[teamType].position;
            spawnPosi.x += index * 0.5f * 2;
            spawnPosi.z += (index % 2) * 0.5f - 1 * 2; 
            Gizmos.DrawWireSphere(spawnPosi, 0.8f);
        }
    }
}
