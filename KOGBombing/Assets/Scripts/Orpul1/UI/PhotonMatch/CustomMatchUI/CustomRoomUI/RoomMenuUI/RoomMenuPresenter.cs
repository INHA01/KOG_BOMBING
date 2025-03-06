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
            if (!PhotonNetwork.IsMasterClient)
                view.btnStartGame.interactable = false;
        }
        private void OnDisable()
        {
            UIEventBus.UnSubscribe(UIEventBus.UIEventType.STARTGAME, SetStartStateUI);
            UIEventBus.UnSubscribe(UIEventBus.UIEventType.SETMASTER, SetRoomOwner);
        }
        public void OnStartRoomBtn()
        {
            if (!PhotonNetwork.IsMasterClient) return;
            SoundManager.Instance.PlayUISound(EUiSoundType.MATCHSTART);
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
        public void SetStartStateUI() //이벤트 버스 등록할 메소드
        {
            view.btnQuitRoom.interactable = false;
            view.btnStartGame.interactable = false;
            view.btnSwapBlueTeam.interactable = false;
            view.btnSwapRedTeam.interactable = false;
        }
        public void SetRoomOwner()
        {
            view.btnStartGame.interactable = PhotonNetwork.IsMasterClient;
        }
    }

}
