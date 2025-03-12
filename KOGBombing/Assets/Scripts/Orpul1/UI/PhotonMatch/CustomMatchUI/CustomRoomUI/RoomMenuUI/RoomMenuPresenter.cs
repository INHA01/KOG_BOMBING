using Photon.Pun;
using UnityEngine;

namespace Orpul1
{
    public class RoomMenuPresenter : MonoBehaviour
    {
        [SerializeField]
        RoomMenuView view;
        RoomMenuModel model;
        private void Start()
        {
            model = new RoomMenuModel(UpdateUI);
        }
        private void OnEnable()
        {
            UIEventBus.Subscribe(UIEventBus.UIEventType.STARTGAME, SetStartStateUI);
            UIEventBus.Subscribe(UIEventBus.UIEventType.SETMASTER, SetRoomOwner);
            view.menuButtons[(int)ERoomMenuButton.STARTBUTTON].interactable = PhotonNetwork.IsMasterClient;
        }
        private void OnDisable()
        {
            UIEventBus.UnSubscribe(UIEventBus.UIEventType.STARTGAME, SetStartStateUI);
            UIEventBus.UnSubscribe(UIEventBus.UIEventType.SETMASTER, SetRoomOwner);
        }
        public void OnStartRoomBtn()
        {
            if (!PhotonNetwork.IsMasterClient) return;
            Managers.Sound.PlayUISound(EUiSoundType.MATCHSTART);
            model.SetStartRoomState();
        }

        public void OnSwapTeamBtn(int team)
        {
            model.SetOtherTeam(team);
        }
        public void UpdateUI()
        {
            SetStartStateUI();
        }
        public void SetStartStateUI()
        {
            for(int i=0; i<(int)ERoomMenuButton.END; i++)
                view.menuButtons[i].interactable = false;
        }
        public void SetRoomOwner()
        {
            view.menuButtons[(int)ERoomMenuButton.STARTBUTTON].interactable = PhotonNetwork.IsMasterClient;
        }
    }

}
