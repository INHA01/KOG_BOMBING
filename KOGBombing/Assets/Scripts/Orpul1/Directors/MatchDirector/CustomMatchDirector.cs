using Photon.Pun;
using Photon.Realtime;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public class CustomMatchDirector : PhotonMatch
    {
        [SerializeField]
        GameObject customRoomPopupPanel;
        [SerializeField]
        GameObject customRoomPanel;
        Action SetRoomOwner;

        [SerializeField]
        PhotonUpdateController<List<RoomInfo>> roomUpdateController;

        [SerializeField]
        PhotonUpdateController<Player> playerUpdateController;

        TypedLobby customLobby = new TypedLobby("CustomLobby", LobbyType.Default);
        bool isCustomMatch = false;
        
        private void Start()
        {
            SetRoomOwner = customRoomPanel.GetComponent<CustomRoomPresenter>().SetRoomOwner;
        }
        public override void Match()
        {
            isCustomMatch = true;
            base.Match();
        }

        protected override IEnumerator CoWaitMatch()
        {
            float span = Time.time + updateDelay;
            while (span>Time.time) yield return null;
            PhotonNetwork.JoinLobby(customLobby);
        }
        public override void OnPlayerEnteredRoom(Player newPlayer)
        {
            if (isCustomMatch)
            {
                base.OnPlayerEnteredRoom(newPlayer);
            }
        }
        public override void OnLeftLobby()
        {
            if(isCustomMatch)
            {
                Debug.Log("DeleteInfos OnLeftLobby");
                roomUpdateController.RemoveAllInfo();
                isCustomMatch = false;
            }
        }
        public override void OnLeftRoom()
        {
            if(isCustomMatch)
            {
                Debug.Log("DeleteInfos OnLeftRoom");
                roomUpdateController.RemoveAllInfo();
                playerUpdateController.RemoveAllInfo();
                isCustomMatch = false;
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
                int redTeam = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
                int blueTeam = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
                Debug.Log($"RED : {redTeam}\n BLUE : {blueTeam}");
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
                base.OnPlayerLeftRoom(otherPlayer);
                playerUpdateController.UpdateInfo(otherPlayer, true);
                SetRoomOwner();
            }
        }
        public override void OnJoinedRoom()
        {
            if (isCustomMatch)
            {
                int debugRedTeam = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
                int debugBlueTeam = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
                Debug.Log($"RoomTeam -> RT: {debugRedTeam} :: BT{debugBlueTeam}");
                Debug.Log($"CustomMatch JoinRoom");
                base.OnJoinedRoom();
                customRoomPopupPanel.SetActive(true);
                Player[] playerList = PhotonNetwork.PlayerList;
                SetRoomOwner();

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