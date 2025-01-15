using Photon.Pun;
using Photon.Realtime;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Unity.VisualScripting;
using UnityEngine;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public class CustomMatchDirector : PhotonMatch
    {
        [SerializeField]
        GameObject customRoomPopupPanel;

        [SerializeField]
        PhotonUpdateController<List<RoomInfo>> roomUpdateController;

        [SerializeField]
        PhotonUpdateController<Player> playerUpdateController;

        TypedLobby customLobby = new TypedLobby("CustomLobby", LobbyType.Default);
        bool isCustomMatch = false;
        
        public override void Match()
        {
            isCustomMatch = true;
            PhotonNetwork.JoinLobby(customLobby);
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
                Debug.Log("CustomMatch JoinLobby");
                base.OnJoinedLobby();
            }
        }
        public override void OnRoomListUpdate(List<RoomInfo> roomList)
        {
            if(isCustomMatch)
            {
                Debug.Log("CustomMatch RoomListUpdate");
                roomUpdateController.UpdateInfo(roomList);
            }
        }
        public override void OnRoomPropertiesUpdate(PhotonHashTable propertiesThatChanged)
        {
            if (isCustomMatch)
            {
                Debug.Log("CustomMatch RoomPropertiesUpdate");
                base.OnRoomPropertiesUpdate(propertiesThatChanged);
            }
        }
        public override void OnPlayerPropertiesUpdate(Player targetPlayer, PhotonHashTable changedProps)
        {
            if (isCustomMatch && targetPlayer.CustomProperties.ContainsKey("Team"))
            {
                playerUpdateController.UpdateInfo(targetPlayer);
            }
        }

        public override void OnPlayerLeftRoom(Player otherPlayer)
        {
            if (isCustomMatch)
            {
                playerUpdateController.UpdateInfo(otherPlayer, true);
            }
        }
        public override void OnJoinedRoom()
        {
            if (isCustomMatch)
            {
                Debug.Log($"CustomMatch JoinRoom");
                base.OnJoinedRoom();
                customRoomPopupPanel.SetActive(true);
                Player[] playerList = PhotonNetwork.PlayerList;

                for (int i=0; i< playerList.Length; i++)
                {
                    playerUpdateController.UpdateInfo(playerList[i]);
                }
            }
        }
        public override void OnCreateRoomFailed(short returnCode, string message)
        {
            if (isCustomMatch)
            {
                Debug.Log("CustomMatch CreateRoomFailed!");
            }
        }
        public override void OnJoinRoomFailed(short returnCode, string message)
        {
            if (isCustomMatch)
            {
                Debug.Log("CustomMatch JoinRoom Fail");
            }
        }
    }
}