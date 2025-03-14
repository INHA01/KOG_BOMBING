using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using System.Collections;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;
using System.Text;

namespace Orpul1
{
    public class RandomMatchDirector : PhotonMatch
    {
        [SerializeField] GameObject countDownImg;
        TypedLobby randomMatchLobby;
        WaitForSeconds gameStartDelay = new WaitForSeconds(2);

        bool isMatching = false;
        bool isRandomMatch = false;
        private void Start()
        {
            randomMatchLobby = new TypedLobby(matchData.LobbyName.ToString(), matchData.LobbyType);
        }
        public override void Match()
        {
            if (isMatching)
            {
                UIEventBus.Publish(UIEventBus.UIEventType.DEACTIVEWAITMATCHPAENL);
                if (PhotonNetwork.InRoom) PhotonNetwork.LeaveRoom();
                if (PhotonNetwork.InLobby) PhotonNetwork.LeaveLobby();
            }
            else
            {
                UIEventBus.Publish(UIEventBus.UIEventType.ACTIVEWAITMATCHPANEL);
                base.Match();
            }
            isMatching = !isMatching;
            isRandomMatch = !isRandomMatch;
        }
       
        public override void OnRoomPropertiesUpdate(PhotonHashTable propertiesThatChanged)
        {
            if (!isRandomMatch) return;
            base.OnRoomPropertiesUpdate(propertiesThatChanged);
        }
        public override void OnPlayerEnteredRoom(Player newPlayer)
        {
            if (!isRandomMatch) return;
            base.OnPlayerEnteredRoom(newPlayer);
        }
        public override void OnJoinedLobby()
        {
            if (!isRandomMatch) return;
            base.OnJoinedLobby();
            PhotonNetwork.JoinRandomRoom();
        }

        public override void OnJoinedRoom()
        {
            if (!isRandomMatch) return;

            base.OnJoinedRoom();
            if(PhotonNetwork.IsMasterClient)
                StartCoroutine(CoWaitPlayers());

        }

        public override void OnJoinRandomFailed(short returnCode, string message)
        {
            if (!isRandomMatch) return;
            StringBuilder roomName = new StringBuilder("RandomRoom" + PhotonNetwork.LocalPlayer.NickName);
            PhotonNetwork.CreateRoom(roomName.ToString(), SetRoomOption());

        }
       

        private RoomOptions SetRoomOption()
        {
            Debug.Log($"{PhotonNetwork.LocalPlayer.NickName}");
            RoomOptions roomOpt = new RoomOptions()
            {
                IsVisible = true,
                IsOpen = true,
                MaxPlayers = matchData.MaxPlayer,
                PublishUserId = true,
                CustomRoomProperties = new PhotonHashTable { { EPropertyType.REDTEAM.ToString(), 0 }, { EPropertyType.BLUETEAM.ToString(), 0 }, { EPropertyType.ROOMSTATE.ToString(), "Ready" } },
            };
            return roomOpt;
        }
        protected override IEnumerator CoWaitMatch()
        {
            float span = Time.time + matchData.UpdateDelay;
            while (span > Time.time) yield return null;
            PhotonNetwork.JoinLobby(randomMatchLobby);
        }

        IEnumerator CoWaitPlayers()
        {
            while (true)
            {
                if (!isMatching) yield break;
                if (PhotonNetwork.CurrentRoom.PlayerCount >= matchData.MaxPlayer) break;
                yield return null;
            }
            
            if (PhotonNetwork.IsMasterClient)
            {
                yield return gameStartDelay;
                PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { EPropertyType.ROOMSTATE.ToString(), "Start" } });
            }
        }
        protected override IEnumerator CoStartDelay()
        {
            yield return null;
            countDownImg.SetActive(true);
            base.CoStartDelay();
        }
    }
}