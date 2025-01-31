using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Text;
using UnityEngine;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public abstract class PhotonMatch : MonoBehaviourPunCallbacks, IMatchAble
    {
        [SerializeField]
        protected float updateDelay;
        public virtual void Match()
        {
            StartCoroutine(CoWaitMatch());
        }
        protected abstract IEnumerator CoWaitMatch();
        
        public override void OnJoinedRoom()
        {
            Debug.Log("JoinRoom!");
            StringBuilder stbTeam = SetTeam();
            int teamIndex = (int)PhotonNetwork.CurrentRoom.CustomProperties[stbTeam.ToString()] + 1;
            Debug.Log($"joinTeam {stbTeam.ToString()}");

            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", stbTeam.ToString() } });
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "TeamIndex", teamIndex } });
        }

        public override void OnJoinedLobby()
        {
            Debug.Log("JoinLobby");
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "UID", PhotonNetwork.LocalPlayer.UserId } });
        }
        public override void OnPlayerLeftRoom(Player otherPlayer)
        {
            Debug.Log("PlayerLeftRoom");
            if ((string)otherPlayer.CustomProperties["Team"]=="RT")
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
            Debug.Log("RoomUpdate");
            if (propertiesThatChanged.ContainsKey("RoomState"))
            {
                if ((string)propertiesThatChanged["RoomState"] == "Start")
                {
                    Player[] players = PhotonNetwork.PlayerList;
                    StringBuilder stbTeam = new StringBuilder((string)PhotonNetwork.LocalPlayer.CustomProperties["Team"]);
                    int playerTeamIndex = 0;
                    for (int i = 0; i < players.Length; i++)
                    {
                        if (stbTeam.ToString() != (string)players[i].CustomProperties["Team"]) continue;
                        playerTeamIndex++;
                        if (PhotonNetwork.LocalPlayer == players[i]) break;
                    }

                    Debug.Log($"teamIndex {playerTeamIndex}");
                    PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "TeamIndex", playerTeamIndex} });
                    StartCoroutine(CoStartDelay());
                   
                }
            }
        }
       
        protected StringBuilder SetTeam()
        {
            int redTeam = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
            int blueTeam = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
            if (redTeam > blueTeam)
            {
                PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { "BT", blueTeam + 1 } });
                return new StringBuilder("BT");
            }
            else
            {
                PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { "RT", redTeam + 1 } });
                return new StringBuilder("RT");
            }
        }
        protected virtual IEnumerator CoStartDelay()
        {
            float delayTime = Time.time + 3f;

            while (Time.time < delayTime) yield return null;
            PhotonNetwork.CurrentRoom.IsOpen = false;
            PhotonNetwork.IsMessageQueueRunning = true;
            PhotonNetwork.CurrentRoom.IsOpen = false;
            PhotonNetwork.LoadLevel(3);
        }
    }
}
