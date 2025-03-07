using ExitGames.Client.Photon.StructWrapping;
using Photon.Realtime;
using System;
using System.Text;

namespace Orpul1
{
    public class DisplayRoomModel
    {
        Action updateUI;
        private RoomInfo roomInfo;
        public RoomInfo RoomInfo { get { return roomInfo; } }
        public DisplayRoomModel(Action updateUI)
        {
            this.updateUI = updateUI;
        }
        public void SetRoomInfo(RoomInfo roomInfo)
        {
            this.roomInfo = roomInfo;
            updateUI();
        }
    }
}