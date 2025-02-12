using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.IO;
using System.Text;
using UnityEngine;
using UnityEngine.UI;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public abstract class PhotonMatch : MonoBehaviourPunCallbacks
    {
        [SerializeField]
        protected float updateDelay;
        protected bool isStopMatch = false;
        [SerializeField]
        Button btnMatch;
        private void Start()
        {
            btnMatch.interactable = true;
        }
        public virtual void Match()
        {
            isStopMatch = false;
            StartCoroutine(CoWaitMatch());
        }
        protected abstract IEnumerator CoWaitMatch();
        
        public override void OnJoinedRoom()
        {
            Debug.Log("JoinRoom!");
            int playerTeam = SetTeam();
            int teamIndex = 0;
            if (playerTeam == (int)ETeam.REDTEAM)
            {
                teamIndex = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"] + 1;
            }
            else
            {
                teamIndex = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"] + 1;
            }
            
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", (ETeam)playerTeam } });
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "TeamIndex", teamIndex } });
        }

        public override void OnJoinedLobby()
        {
            Debug.Log("JoinLobby");
        }
        public override void OnPlayerLeftRoom(Player otherPlayer)
        {
            Debug.Log("PlayerLeftRoom");
            if ((int)otherPlayer.CustomProperties["Team"] == (int)ETeam.REDTEAM) 
            {
                int redTeam = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
                PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { "RT", redTeam - 1 } });
            }
            else
            {
                int blueTeam = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
                PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { "BT", blueTeam - 1 } });
            }
        }

        public override void OnRoomPropertiesUpdate(PhotonHashTable propertiesThatChanged)
        {
            if (propertiesThatChanged.ContainsKey("RoomState"))
            {
                if ((string)propertiesThatChanged["RoomState"] == "Start")
                {
                    PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "State", EPlayerState.Ready } });
                    btnMatch.interactable = false;
                    
                    StartCoroutine(CoStartDelay());
                   
                }
            }
        }
       
        protected int SetTeam()
        {
            int redTeam = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
            int blueTeam = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
            if (redTeam > blueTeam)
            {
                PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { "BT", blueTeam + 1 } });
                Debug.Log("SetTeam BT");
                return (int)ETeam.BLUETEAM;
            }
            else
            {
                PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { "RT", redTeam + 1 } });
                Debug.Log("SetTeam RT");
                return (int)ETeam.REDTEAM;
            }
        }
        private void SetPlayerIndex()
        {
            Player[] players = PhotonNetwork.PlayerList;
            ETeam playerTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"];
            Debug.Log($"team : {playerTeam}");
            int playerTeamIndex = 0;
            for (int i = 0; i < players.Length; i++)
            {
                if (playerTeam != (ETeam)players[i].CustomProperties["Team"]) continue;
                playerTeamIndex++;
                if (PhotonNetwork.LocalPlayer == players[i]) break;
            }

            Debug.Log($"teamIndex {playerTeamIndex}");
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "TeamIndex", playerTeamIndex } });
        }
        protected virtual IEnumerator CoStartDelay()
        {
            float delayTime = Time.time + 3f;
            Debug.Log($"Prev Delay {Time.time}");
            while (Time.time < delayTime) yield return null;
            SetPlayerIndex();
            Debug.Log($"After delay {Time.time}");
            if(PhotonNetwork.IsMasterClient)
            {
                PhotonNetwork.CurrentRoom.IsOpen = false;
                PhotonNetwork.IsMessageQueueRunning = true;
                PhotonNetwork.CurrentRoom.IsOpen = false;
            }
            LoadingSceneManager.LoadScene("MainGame");
        }
    }
}
