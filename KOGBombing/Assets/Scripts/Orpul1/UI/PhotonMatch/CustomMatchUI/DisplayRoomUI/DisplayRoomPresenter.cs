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

        public void Init(RoomInfo roomInfo)
        {
            model.roomInfo = roomInfo;
            view.tmpServerName.text = roomInfo.Name;
            view.tmpPlayerCount.text = roomInfo.PlayerCount.ToString();
        }

        public void OnEnterRoom()
        {
            if (!model.roomInfo.IsOpen) return;
            if (model.roomInfo.PlayerCount > model.roomInfo.MaxPlayers) return;
            PhotonNetwork.JoinRoom(model.roomInfo.Name);
        }
    }
}
