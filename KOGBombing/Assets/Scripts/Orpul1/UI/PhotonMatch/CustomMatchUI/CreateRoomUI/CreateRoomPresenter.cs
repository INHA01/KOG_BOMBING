using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;
namespace Orpul1
{
    public class CreateRoomPresenter : MonoBehaviour
    {
        [SerializeField]
        CreateRoomView view;
        CreateRoomModel model = new CreateRoomModel();
        public void InputFieldSetRoomName()
        {
            model.StbRoomName.Clear();
            model.StbRoomName.Append(view.tmpInputRoomName.text);
        }
        public void DropDownSetPlayerCnt()
        {
            model.StbPlayerCnt.Clear();
            model.StbPlayerCnt.Append(view.tmpDropDPlayerCnt.value);
        }

        public void OnCreateRoomBtn()
        {
            if (!PhotonNetwork.InLobby) return;
            int maxPlayer = 0;
            int.TryParse(view.tmpDropDPlayerCnt.ToString(), out maxPlayer);
            RoomOptions options = new RoomOptions()
            {
                MaxPlayers = maxPlayer,
                IsVisible = true,
                IsOpen = true,
                PublishUserId = true,
                CustomRoomProperties = new PhotonHashTable { { "RT", 0 }, { "BT", 0 }, { "RoomState", "Ready" } },
            };
            PhotonNetwork.CreateRoom(view.tmpInputRoomName.text.ToString(), options);
            view.tmpInputRoomName.text = "";
            view.createRoomPopupPanel.SetActive(false);
        }

        public void OnQuitBtn()
        {
            view.createRoomPopupPanel.SetActive(false);
        }
    }
}