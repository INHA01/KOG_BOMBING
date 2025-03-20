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
        private void OnEnable()
        {
            UIEventBus.Subscribe(UIEventBus.UIEventType.DEACTIVECREATEROOMPANEL, OnQuitBtn);
        }
        private void OnDisable()
        {
            UIEventBus.UnSubscribe(UIEventBus.UIEventType.DEACTIVECREATEROOMPANEL, OnQuitBtn);
        }
        public void OnCreateRoomBtn()
        {
            if (!PhotonNetwork.InLobby) return;
            int option = view.tmpDropDPlayerCnt.value;
            StringBuilder roomName = new StringBuilder(view.tmpInputRoomName.text);
            StringBuilder playerCount = new StringBuilder(view.tmpDropDPlayerCnt.options[option].text);
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
            Managers.Sound.PlayUISound(EUiSoundType.CLICK);
            view.createRoomPopupPanel.SetActive(false);
        }
    }
}