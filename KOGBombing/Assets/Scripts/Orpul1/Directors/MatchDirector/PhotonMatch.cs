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
        public override void OnPlayerLeftRoom(Player otherPlayer)
        {
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
            if (propertiesThatChanged.ContainsKey("RoomState"))
            {
                if ((string)propertiesThatChanged["RoomState"] == "Start")
                {
                    PhotonNetwork.CurrentRoom.IsOpen = false;
                    PhotonNetwork.IsMessageQueueRunning = true;
                    PhotonNetwork.CurrentRoom.IsOpen = false;
                    PhotonNetwork.LoadLevel(2);
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