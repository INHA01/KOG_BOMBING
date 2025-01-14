using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using System.Collections;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;
using System.Text;
using System;

namespace Orpul1
{
    public class RandomMatchDirector : PhotonMatch
    {
        TypedLobby randomMatchLobby = new TypedLobby("randomMatch", LobbyType.Default);

        [SerializeField]
        int maxPlayer = 2;

        bool isMatching = false;
        bool isRandomMatch = false;
        public void SetMaxPlayer(int value)
        {
            maxPlayer = value;
        }

        public override void Match()
        {
            if (isMatching)
            {
                isMatching = false;
                isRandomMatch = false;
                if (PhotonNetwork.InRoom) PhotonNetwork.LeaveRoom();
                if (PhotonNetwork.InLobby) PhotonNetwork.LeaveLobby();
            }
            else
            {
                isMatching = true;
                isRandomMatch = true;
                PhotonNetwork.JoinLobby(randomMatchLobby);
            }
        }

        public override void OnRoomPropertiesUpdate(PhotonHashTable propertiesThatChanged)
        {
            if (isRandomMatch)
                base.OnRoomPropertiesUpdate(propertiesThatChanged);
        }
        public override void OnPlayerEnteredRoom(Player newPlayer)
        {
            if (isRandomMatch)
                base.OnPlayerEnteredRoom(newPlayer);
        }
        public override void OnJoinedLobby()
        {
            if (isRandomMatch)
            {
                Debug.Log($"randomMatch {isRandomMatch}");
                base.OnJoinedLobby();
                PhotonNetwork.JoinRandomOrCreateRoom(null,0,MatchmakingMode.FillRoom,null,null,null, SetRoomOption());
            }
        }

        public override void OnJoinedRoom()
        {
            if (isRandomMatch && PhotonNetwork.IsMasterClient)
            {
                Debug.Log("RadnomJoinRoom");
                base.OnJoinedRoom();
                StartCoroutine("CoWaitPlayers");
            }
        }

        public override void OnLeftRoom()
        {
            if (isRandomMatch)
            {
                PhotonNetwork.LeaveRoom();
            }
        }
        public override void OnLeftLobby()
        {
            if (isRandomMatch)
            {
                Debug.Log("RandomMatch LeftLobby");
                isMatching = false;
            }
        }
        public override void OnJoinRandomFailed(short returnCode, string message)
        {
            if (isRandomMatch)
            {
                Debug.Log("joinFail");
            }
        }
       
        public override void OnCreateRoomFailed(short returnCode, string message)
        {
            if (isRandomMatch)
                Debug.Log("CreateRoomFailed!");
        }

        private RoomOptions SetRoomOption()
        {
            StringBuilder roomName = new StringBuilder();
            roomName.Append("RandomRoom" + PhotonNetwork.LocalPlayer.NickName);
            Debug.Log($"{PhotonNetwork.LocalPlayer.NickName}");
            RoomOptions roomOpt = new RoomOptions()
            {
                IsVisible = true,
                IsOpen = true,
                MaxPlayers = maxPlayer,
                PublishUserId = true,
                CustomRoomProperties = new PhotonHashTable { { "RT", 0 }, { "BT", 0 }, { "RoomState", "Ready" } },
            };

            Debug.Log($"CreateRoom {roomName.ToString()}");

            return roomOpt;
        }

        IEnumerator CoWaitPlayers()
        {
            Debug.Log($"PlayerCnt: {PhotonNetwork.CurrentRoom.PlayerCount}");

            while (true)
            {
                if (!isMatching) yield break;
                if (PhotonNetwork.CurrentRoom.PlayerCount >= maxPlayer) break;
                yield return null;
            }

            if (PhotonNetwork.IsMasterClient)
            {
                PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { "RoomState", "Start" } });
            }
        }
    }
}