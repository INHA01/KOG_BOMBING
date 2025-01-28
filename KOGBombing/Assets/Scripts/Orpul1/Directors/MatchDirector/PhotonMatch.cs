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

            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", stbTeam.ToString() } });

            int teamIndex = (int)PhotonNetwork.CurrentRoom.CustomProperties[stbTeam.ToString()] + 1;
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

            StringBuilder stbTeam = new StringBuilder((string)PhotonNetwork.LocalPlayer.CustomProperties["Team"]);

            int teamIndex = (int)PhotonNetwork.CurrentRoom.CustomProperties[stbTeam.ToString()] + 1;
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "TeamIndex", teamIndex } });
        }/*
        public override void OnPlayerPropertiesUpdate(Player targetPlayer, PhotonHashTable changedProps)
        {
            if(targetPlayer == PhotonNetwork.LocalPlayer)
            {
                StringBuilder stbTeam = new StringBuilder((string)PhotonNetwork.LocalPlayer.CustomProperties["Team"]);

                int teamIndex = (int)PhotonNetwork.CurrentRoom.CustomProperties[stbTeam.ToString()] + 1;
                PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "TeamIndex", teamIndex } });
            }
        }*/
        public override void OnRoomPropertiesUpdate(PhotonHashTable propertiesThatChanged)
        {
            Debug.Log("RoomUpdate");
            if (propertiesThatChanged.ContainsKey("RoomState"))
            {
                if ((string)propertiesThatChanged["RoomState"] == "Start")
                {
                    PhotonNetwork.CurrentRoom.IsOpen = false;
                    PhotonNetwork.IsMessageQueueRunning = true;
                    PhotonNetwork.CurrentRoom.IsOpen = false;
                    PhotonNetwork.LoadLevel(3);
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
        
    }
}