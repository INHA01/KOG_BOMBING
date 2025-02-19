using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;
using Photon.Realtime;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;
using ExitGames.Client.Photon;
namespace Orpul1
{
    public enum EGameEvent
    {
        PLAYERREADY,
        ROUNDREADY,
        EXTERMINATETEAM,
        PLAYERDIE
    }
    public enum EGameState
    {
        STARTSTATE,
        SELECT = 20,
        ROUNDWAIT,
        GAMESTART,
        GAMEEND,
        SWITCHTEAMROLL,
        SPAWNPLAYER,
        WAITPLAYERS,
        STARTEND,
    }

    public class GameDirector : MonoBehaviourPunCallbacks
    {
        public static int blueScore = 0;
        public static int redScore = 0;
        Dictionary<EGameEvent, IState> dicGameState = new Dictionary<EGameEvent, IState>();
        private void Awake()
        {
            
        }
        private void OnServerInitialized()
        {
        }

        /*
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
        int readyPlayerCnt = 0;
        RaiseEventOptions options = new RaiseEventOptions();
        bool isAllPlayerReady = false;
        private void Awake()
        {
            options.Receivers = ReceiverGroup.All;
        }
        void Start()
        {
            EventBusSystem.Subscribe(StartGame);
            PhotonNetwork.NetworkingClient.EventReceived += PhotonEvent;
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "State", EPlayerState.START } });
            StartCoroutine(CoWaitPlayer());
            //SpawnPlayer();
        }
          private void PhotonEvent(EventData punEvent)
        {
            if(punEvent.Code == (int)EGameState.GAMESTART)
            {
                isAllPlayerReady = true;
            }
        }
        public override void OnPlayerPropertiesUpdate(Player targetPlayer, PhotonHashTable changedProps)
        {
            if (!PhotonNetwork.IsMasterClient) return;

            EPlayerState playerState = (EPlayerState)targetPlayer.CustomProperties["State"];
            if (playerState == EPlayerState.START)
            {
                readyPlayerCnt++;
                if (readyPlayerCnt != PhotonNetwork.CurrentRoom.PlayerCount) return;
                PhotonNetwork.RaiseEvent((int)EGameState.GAMESTART, null, options, SendOptions.SendReliable);
            }
        }
        
        private IEnumerator CoWaitPlayer()
        {
            while(!isAllPlayerReady) yield return null;
            SelectPlayer();
        }
        void SelectPlayer()
        {
            _uiScene = Managers.UI.ShowPopupUI<UIPopup>("CharacterChooseCanvas");
        }
        void StartGame()
        {
            if(!PhotonNetwork.IsMasterClient) return;
            if (!pv.IsMine) return;
            pv.RPC("StartTimeCount", RpcTarget.AllBuffered);
            pv.RPC("SpawnPlayer", RpcTarget.AllBuffered);
        }
        [PunRPC]
        public void UpdateScores(int newBlueScore, int newRedScore)
        {
            blueScore = newBlueScore;
            redScore = newRedScore;
        }
        [PunRPC]
        private void StartTimeCount()
        {
            StartCoroutine(TimeCount());

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
        [PunRPC]
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
            GameObject playerObj = PhotonNetwork.Instantiate("Prefabs/PlayerPrefabs/" + _uiScene.GetComponent<ChoosePlayer>().type.ToString(), spawnPosi, Quaternion.Euler(0, 45, 0));
            GameObject cameraObj = Instantiate(playerCamera, new Vector3(-3, 7.5f, -3), Quaternion.Euler(50, 45, 0));
            GameObject minCamaraObj = Instantiate(minimapCamera, spawnPosi + new Vector3(0, 50f, 0), Quaternion.Euler(90, 0, 0));
            minCamaraObj.GetComponent<MinimapCamera>().target = playerObj;
            cameraObj.GetComponent<PlayerCamera>().target = playerObj;
            cameraObj.GetComponent<PlayerCamera>().minimapCamera = minCamaraObj;
            cameraObj.transform.SetParent(playerObj.transform);
            playerObj.GetComponent<PlayerController>().Init(cameraObj.GetComponent<Camera>(),spawnPosi);

            Managers.camData.AddCamera(cameraObj, ECameraType.MAINCAMERA);
            Managers.camData.AddCamera(minimapCamera, ECameraType.MINIMAPCAMERA);
            //_uiScene.GetComponent<PlayScene>().gameDirector = this;
            //_uiScene.GetComponent<PlayScene>().weapon = playerObj.GetComponent<PlayerShooting>();
        }*/
    }
}
