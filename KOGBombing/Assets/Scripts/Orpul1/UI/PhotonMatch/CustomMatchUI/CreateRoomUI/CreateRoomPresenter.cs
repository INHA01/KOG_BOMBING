using Photon.Pun;
using Photon.Realtime;
using System.Text;
using UnityEngine;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;
namespace Orpul1
{
    public class CreateRoomPresenter : MonoBehaviour
    {
        [SerializeField]
        CreateRoomView view;
        CreateRoomModel model;
        private void Start()
        {
            model = new CreateRoomModel(UpdateUI);
        }
        public void OnCreateRoomBtn()
        {
            if (!PhotonNetwork.InLobby) return;
            StringBuilder roomName = new StringBuilder(view.tmpInputRoomName.text);
            StringBuilder playerCount = new StringBuilder(view.tmpDropDPlayerCnt.value);
            model.SetRoomInfo(roomName, playerCount);
        }
        public void UpdateUI()
        {
            view.tmpInputRoomName.text = "";
            view.tmpDropDPlayerCnt.value = 0;
            view.createRoomPopupPanel.SetActive(false);
        }
        public void OnQuitBtn()
        {
            view.createRoomPopupPanel.SetActive(false);
        }
    }
}