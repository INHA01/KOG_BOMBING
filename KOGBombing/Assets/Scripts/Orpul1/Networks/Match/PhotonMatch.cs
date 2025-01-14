using Photon.Pun;
using Photon.Realtime;
using System.Text;
using UnityEngine;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public abstract class PhotonMatch : MonoBehaviourPunCallbacks, IMatchAble
    {
        public override void OnPlayerEnteredRoom(Player newPlayer)
        {
            if (PhotonNetwork.IsMasterClient)
            {
                newPlayer.SetCustomProperties(new PhotonHashTable { { "Team", SetTeam().ToString() } });
            }
        }

        public override void OnJoinedRoom()
        {
            if (PhotonNetwork.IsMasterClient)
            {
                Debug.Log("masterJoin!");
                PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", SetTeam().ToString() } });
            }
        }
        public override void OnJoinedLobby()
        {
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "UID", PhotonNetwork.LocalPlayer.UserId } });
        }

        public override void OnRoomPropertiesUpdate(PhotonHashTable propertiesThatChanged)
        {
            if (propertiesThatChanged.ContainsKey("RoomState"))
            {
                if ((string)propertiesThatChanged["RoomState"] == "Start")
                {
                    PhotonNetwork.CurrentRoom.IsOpen = false;
                    PhotonNetwork.IsMessageQueueRunning = true;
                    PhotonNetwork.CurrentRoom.IsOpen = false;
                    PhotonNetwork.LoadLevel(1);
                }
            }
        }
        protected StringBuilder SetTeam()
        {
            int redTeam = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
            int blueTeam = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
            if (redTeam > blueTeam)
            {
                int blueTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
                PhotonNetwork.CurrentRoom.CustomProperties["BT"] = blueTeamCnt + 1;
                Debug.Log($"bt {(int)PhotonNetwork.CurrentRoom.CustomProperties["BT"]}");
                return new StringBuilder("BT");
            }
            else
            {
                int redTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
                PhotonNetwork.CurrentRoom.CustomProperties["RT"] = redTeamCnt + 1;
                Debug.Log($"rt {(int)PhotonNetwork.CurrentRoom.CustomProperties["RT"]}");
                return new StringBuilder("RT");
            }
        }
        public abstract void Match();
    }
}