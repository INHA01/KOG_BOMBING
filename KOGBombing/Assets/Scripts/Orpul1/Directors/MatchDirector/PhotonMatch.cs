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
        protected float delayTime = 5;
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
            ETeam playerTeam = SetTeam();

            Debug.Log($"SetTeam  {(ETeam)playerTeam}");
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { EPropertyType.TEAM.ToString(), playerTeam } });
        }

       
        public override void OnJoinedLobby()
        {
            Debug.Log("JoinLobby");
        }
        
        public override void OnPlayerLeftRoom(Player otherPlayer)
        {
            Debug.Log("PlayerLeftRoom");
            if ((int)otherPlayer.CustomProperties[EPropertyType.TEAM.ToString()] == (int)ETeam.REDTEAM) 
            {
                int redTeam = (int)PhotonNetwork.CurrentRoom.CustomProperties[EPropertyType.REDTEAM.ToString()];
                PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { EPropertyType.REDTEAM.ToString(), redTeam - 1 } });
            }
            else
            {
                int blueTeam = (int)PhotonNetwork.CurrentRoom.CustomProperties[EPropertyType.BLUETEAM.ToString()];
                PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { EPropertyType.BLUETEAM.ToString(), blueTeam - 1 } });
            }
        }
        public override void OnRoomPropertiesUpdate(PhotonHashTable propertiesThatChanged)
        {
            if (!propertiesThatChanged.ContainsKey(EPropertyType.ROOMSTATE.ToString())) return;
            if ((string)propertiesThatChanged[EPropertyType.ROOMSTATE.ToString()] != "Start") return;

            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { EPropertyType.STATE.ToString(), EPlayerState.WAIT } });
            SetPlayerTeamIndex();
            btnMatch.interactable = false;
            StartCoroutine(CoStartDelay());
        }
       private void SetPlayerTeamIndex()
        {
            if (!PhotonNetwork.IsMasterClient) return;
            Player[] players = PhotonNetwork.PlayerList;
            int redTeamIndex = 0, blueTeamIndex = 0;

            for(int i=0; i<players.Length; i++)
            {
                ETeam team = (ETeam)players[i].CustomProperties[EPropertyType.TEAM.ToString()];
                if(team== ETeam.REDTEAM)
                {
                    players[i].SetCustomProperties(new PhotonHashTable { { EPropertyType.TEAMINDEX.ToString(), redTeamIndex } });
                    Debug.Log($"{players[i].NickName} index {redTeamIndex}");
                    redTeamIndex++;

                }
                else if(team == ETeam.BLUETEAM)
                {
                    players[i].SetCustomProperties(new PhotonHashTable { { EPropertyType.TEAMINDEX.ToString(), blueTeamIndex } });
                    Debug.Log($"{players[i].NickName} index {blueTeamIndex}");
                    blueTeamIndex++;
                }
            }
        }
        protected ETeam SetTeam()
        {
            int redTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[EPropertyType.REDTEAM.ToString()];
            int blueTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[EPropertyType.BLUETEAM.ToString()];
            ETeam team = ETeam.REDTEAM;// Set RedTeam
            int playerCount = redTeamCnt + 1;
            EPropertyType type = EPropertyType.REDTEAM;

            if (redTeamCnt > blueTeamCnt) // Set BlueTeam 
            {
                team = ETeam.BLUETEAM;
                playerCount = blueTeamCnt + 1;
                type = EPropertyType.BLUETEAM;
            }
            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { type.ToString(), playerCount} });
            return team;
        }
        protected virtual IEnumerator CoStartDelay()
        {
            float time = Time.time + delayTime;
            Debug.Log($"Prev Delay {Time.time}");
            while (Time.time < time) yield return null;
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
