using Photon.Realtime;
using System.Text;
using UnityEngine;

namespace Orpul1
{
    public class CustomRoomPresenter : MonoBehaviour
    {
        [SerializeField]
        CustomRoomView view;
        CustomServerModel model = new CustomServerModel();
        public void SetServerInfo(RoomInfo roomInfo)
        {
            model.roomInfo = roomInfo;
            model.stbServerName.Append(roomInfo.Name);
            model.stbPlayerCount.Append(roomInfo.PlayerCount);
            view.tmpServerName.text = model.stbServerName.ToString();
            view.tmpPlayerCount.text = model.stbPlayerCount.ToString();
        }
        public void SetPlayerCount(StringBuilder playerCount)
        {
            model.stbPlayerCount = playerCount;
            view.tmpPlayerCount.text = model.stbPlayerCount.ToString();
        }
    }
}
