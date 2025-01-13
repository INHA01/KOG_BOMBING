using Photon.Pun;
using Photon.Realtime;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public class CustomMatch : PhotonMatch
    {
        [SerializeField]
        GameObject customRoomUIObj;
        TypedLobby customLobby = new TypedLobby("CustomLobby", LobbyType.Default);
        bool isCustomMatch = false;
        Action setPlayerList;
        Action<Player> updatePlayer;
        Action<Player> setRemovePlayer;
        private void Start()
        {
            /*setPlayerList = customRoomUIObj.GetComponent<CustomRoomPresenter>().SetPlayerList;
            updatePlayer = customRoomUIObj.GetComponent<CustomRoomPresenter>().UpdatePlayer;
            setRemovePlayer = customRoomUIObj.GetComponent<CustomRoomPresenter>().SetRemovePlayer;*/
        }

        public override void Match()
        {
            isCustomMatch = true;
            PhotonNetwork.JoinLobby(customLobby);
        }

        public void OnGameStartButton()
        {
            if (isCustomMatch && PhotonNetwork.IsMasterClient)
            {
                PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { "RoomState", "Start" } });
            }
        }
        public void OnLeftCustomMatch()
        {
            if (isCustomMatch)
            {
                PhotonNetwork.LeaveLobby();
                isCustomMatch = false;
            }
        }
        public override void OnPlayerEnteredRoom(Player newPlayer)
        {
            if (isCustomMatch)
            {
                base.OnPlayerEnteredRoom(newPlayer);
            }
        }
        public override void OnJoinedLobby()
        {
            if (isCustomMatch)
            {
                base.OnJoinedLobby();
            }
        }
        public override void OnRoomPropertiesUpdate(PhotonHashTable propertiesThatChanged)
        {
            if (isCustomMatch)
            {
                base.OnRoomPropertiesUpdate(propertiesThatChanged);
            }
        }
        public override void OnPlayerPropertiesUpdate(Player targetPlayer, PhotonHashTable changedProps)
        {
            if (isCustomMatch && targetPlayer.CustomProperties.ContainsKey("Team"))
            {
                updatePlayer(targetPlayer);
            }
        }

        public override void OnPlayerLeftRoom(Player otherPlayer)
        {
            if (isCustomMatch)
            {
                setRemovePlayer(otherPlayer);
            }
        }
        public override void OnJoinedRoom()
        {
            if (isCustomMatch)
            {
                Debug.Log($"isCustomMatch {isCustomMatch}");
                base.OnJoinedRoom();
                setPlayerList();
            }
        }
        public override void OnCreateRoomFailed(short returnCode, string message)
        {
            if (isCustomMatch)
            {
                Debug.Log("CreateRoomFailed!");
            }
        }
        public override void OnJoinRoomFailed(short returnCode, string message)
        {
            if (isCustomMatch)
            {
                Debug.Log("JoinRoom Fail");
            }
        }
    }
}