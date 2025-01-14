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
        DisplayRoomModel model = new DisplayRoomModel();

        public void SetServerInfo(RoomInfo roomInfo)
        {
            model.roomInfo = roomInfo;
            model.stbServerName.Append(roomInfo.Name);
            model.stbPlayerCount.Append(roomInfo.PlayerCount);
            view.tmpServerName.text = model.stbServerName.ToString();
            view.tmpPlayerCount.text = model.stbPlayerCount.ToString();
        }

        public void OnEnterRoom()
        {
            if (!model.roomInfo.IsOpen) return;
            if (model.roomInfo.PlayerCount > model.roomInfo.MaxPlayers) return;
            PhotonNetwork.JoinRoom(model.roomInfo.Name);
        }
    }
}
