using Photon.Pun;
using Photon.Realtime;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public class CreateRoomModel
    {
        Action updateUI;
        private StringBuilder stbRoomName = new StringBuilder();
        private StringBuilder stbPlayerCount = new StringBuilder();
        public StringBuilder RoomName { get { return stbRoomName; } }
        public StringBuilder PlayerCount { get { return stbPlayerCount; } }
        public CreateRoomModel(Action updateUI)
        {
            this.updateUI = updateUI;
        }
        public void SetRoomInfo(StringBuilder roomName, StringBuilder playerCount)
        {
            stbRoomName = roomName;
            stbPlayerCount = playerCount;
            int maxPlayer = 0;
            int.TryParse(stbPlayerCount.ToString(), out maxPlayer);
            RoomOptions options = new RoomOptions()
            {
                MaxPlayers = maxPlayer,
                IsVisible = true,
                IsOpen = true,
                PublishUserId = true,
                CustomRoomProperties = new PhotonHashTable 
                {
                    { EPropertyType.REDTEAM.ToString(), 0 },
                    { EPropertyType.BLUETEAM.ToString(), 0 },
                    { EPropertyType.ROOMSTATE.ToString(), (int)ERoomState.WAIT} 
                },
            };
            PhotonNetwork.CreateRoom(stbRoomName.ToString(), options);
            updateUI();
        }
    }
}