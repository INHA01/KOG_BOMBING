using System.Collections;
using System.Collections.Generic;
using System.Text;
using Orpul1;
using Photon.Pun;
using UnityEngine;
using PhotonHashtable = ExitGames.Client.Photon.Hashtable;

public class PlayerSpawner : GameProcessLogic
{
    [SerializeField]
    Transform[] teamSpawnPoints;
    [SerializeField]
    GameObject playerCamera;
    [SerializeField]
    GameObject minimapCamera;

    StringBuilder characterPath;
    
    public override void EnterState()
    {
        SpawnPlayer();
    }
    public override void UpdateState()
    {
        transitionState((int)EGameState.ROUNDWAIT);
    }
    public override void ExitState()
    {
    }

    
    public void SetPlayerCharacter(StringBuilder path)
    {
        characterPath = path;
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
        GameObject playerObj = PhotonNetwork.Instantiate("Prefabs/PlayerPrefabs/" + characterPath.ToString(), spawnPosi, Quaternion.Euler(0, 45, 0));
        GameObject cameraObj = Instantiate(playerCamera, new Vector3(-3, 7.5f, -3), Quaternion.Euler(50, 45, 0));
        GameObject minCamaraObj = Instantiate(minimapCamera, spawnPosi + new Vector3(0, 50f, 0), Quaternion.Euler(90, 0, 0));
        minCamaraObj.GetComponent<MinimapCamera>().target = playerObj;
        cameraObj.GetComponent<PlayerCamera>().target = playerObj;
        cameraObj.GetComponent<PlayerCamera>().minimapCamera = minCamaraObj;
        cameraObj.transform.SetParent(playerObj.transform);
        playerObj.GetComponent<PlayerController>().Init(cameraObj.GetComponent<Camera>(), spawnPosi);

        Managers.camData.AddCamera(cameraObj, ECameraType.MAINCAMERA);
        Managers.camData.AddCamera(minimapCamera, ECameraType.MINIMAPCAMERA);

        //_uiScene.GetComponent<PlayScene>().gameDirector = this;
        //_uiScene.GetComponent<PlayScene>().weapon = playerObj.GetComponent<PlayerShooting>();
    }
}
