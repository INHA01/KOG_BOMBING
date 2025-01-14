using Photon.Pun;
using Photon.Realtime;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Unity.VisualScripting;
using UnityEngine;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public class CustomMatchDirector : PhotonMatch
    {
        [SerializeField]
        GameObject customRoomUIObj;

        [SerializeField]
        GameObject createRoomPanel;

        [SerializeField]
        PhotonUpdateController<List<RoomInfo>> roomUpdateController;

        [SerializeField]
        PhotonUpdateController<Player> playerUpdateController;
        [SerializeField]
        GameObject createRoomObj;
        Func<StringBuilder> GetRoomName;
        Func<int> GetMaxPlayer;

        TypedLobby customLobby = new TypedLobby("CustomLobby", LobbyType.Default);
        bool isCustomMatch = false;
        
        private void Start()
        {
            CreateRoomPresenter createRoomPresenter = createRoomObj.GetComponent<CreateRoomPresenter>();
            GetRoomName = createRoomPresenter.GetRoomName;
            GetMaxPlayer = createRoomPresenter.GetMaxPlayer;
            customRoomUIObj.SetActive(false);
            createRoomPanel.SetActive(false);
        }

        public override void Match()
        {
            isCustomMatch = true;
            customRoomUIObj.SetActive(isCustomMatch);
            PhotonNetwork.JoinLobby(customLobby);
        }
        public void OnExitLobby()
        {
            customRoomUIObj.SetActive(false);
            createRoomPanel.SetActive(false);
            PhotonNetwork.LeaveLobby();
        }
        public void OnActiveCreateRoom()
        {
            createRoomPanel.SetActive(true);
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

        public void OnCreateRoomBtn()
        {
            RoomOptions options = new RoomOptions()
            {
                MaxPlayers = GetMaxPlayer(),
                IsVisible = true,
                IsOpen = true,
                PublishUserId = true,
                CustomRoomProperties = new PhotonHashTable { { "RT", 0 }, { "BT", 0 }, { "RoomState", "Ready" } },
            };
            PhotonNetwork.CreateRoom(GetRoomName().ToString(), options);
            Debug.Log($"CreateRoom : {GetRoomName().ToString()}");
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
            // TODO >> : 룸 리스트 갱신
            if(isCustomMatch)
            {
                Debug.Log("CustomMatch RoomListUpdate");
                roomUpdateController.UpdateInfo(roomList);
                //SetRoomUpdate(roomList);
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
                //updatePlayer(targetPlayer);
            }
        }

        public override void OnPlayerLeftRoom(Player otherPlayer)
        {
            if (isCustomMatch)
            {
                playerUpdateController.UpdateInfo(otherPlayer);
                //setRemovePlayer(otherPlayer);
            }
        }
        public override void OnJoinedRoom()
        {
            if (isCustomMatch)
            {
                Debug.Log($"CustomMatch JoinRoom");
                base.OnJoinedRoom();
                playerUpdateController.UpdateInfo(PhotonNetwork.LocalPlayer);
                //setPlayerList();
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