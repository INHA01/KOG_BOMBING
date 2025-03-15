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
        [SerializeField]
        CustomRoomModel model;
        private void Start()
        {
            model.Init(UpdateUI);
            view.panels[(int)ECustomRoomPanel.CUSTOMROOM].SetActive(false);
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
            view.panels[(int)ECustomRoomPanel.CUSTOMROOM].SetActive(true);
        }
        void UpdateUI()
        {
            for (int i = 0; i < (int)ECustomRoomPanel.END; i++)
                 view.panels[i].SetActive(false);
        }
        public void OnLeaveRoomBtn()
        {
            model.TurnBackScreen();
            Managers.Sound.PlayUISound(EUiSoundType.CLICK);
            PhotonNetwork.LeaveRoom();
        }
    }
    

}
