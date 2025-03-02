using Photon.Pun;
using Photon.Realtime;
using System.Text;
using UnityEngine;

namespace Orpul1
{
    public class DisplayRoomPresenter : MonoBehaviour
    {
        [SerializeField]
        DisplayRoomView view;
        DisplayRoomModel model;
        bool isJoinRoom = false;

        public void Init(RoomInfo roomInfo)
        {
            model = new DisplayRoomModel(UpdateUI);
            model.SetRoomInfo(roomInfo);
            isJoinRoom = false;
        }

        public void OnEnterRoom()
        {
            if (!model.RoomInfo.IsOpen) return;
            if (model.RoomInfo.PlayerCount > model.RoomInfo.MaxPlayers) return;
            if (isJoinRoom) return;
            isJoinRoom = true;
            PhotonNetwork.JoinRoom(model.RoomInfo.Name);
        }
        public void UpdateUI()
        {
            view.tmpServerName.text = model.RoomInfo.Name;
            view.tmpPlayerCount.text = model.RoomInfo.PlayerCount.ToString();
        }
    }
}
