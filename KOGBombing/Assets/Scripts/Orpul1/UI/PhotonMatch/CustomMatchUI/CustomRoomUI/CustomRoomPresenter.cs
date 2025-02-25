using Photon.Pun;
using System.Text;
using UnityEngine;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;
using System.Collections;
using static Orpul1.PlayerListController;

namespace Orpul1
{
    public class CustomRoomPresenter : MonoBehaviour
    {
        [SerializeField]
        CustomRoomView view;

        private void Start()
        {
            view.customRoomPanel.SetActive(false);
        }
        private void OnEnable()
        {
            UIEventBus.Subscribe(UIEventBus.UIEventType.ACTIVECUSTOMROOMPANEL, ActiveUIPanel);
        }
        private void OnDisable()
        {
            UIEventBus.UnSubscribe(UIEventBus.UIEventType.ACTIVECUSTOMROOMPANEL, ActiveUIPanel);
        }
        public void ActiveUIPanel()
        {
            view.customRoomPanel.SetActive(true);
        }
        public void OnLeaveRoomBtn()
        {
            view.customRoomPanel.SetActive(false);
            view.customRoomListPanel.SetActive(false);
            view.background.SetActive(false);
            PhotonNetwork.LeaveRoom();
        }
    }
    

}
