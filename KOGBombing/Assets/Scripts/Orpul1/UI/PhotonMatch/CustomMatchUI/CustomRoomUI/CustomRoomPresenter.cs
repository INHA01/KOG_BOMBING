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
        public void ActiveUIPanel()
        {
            view.customRoomPanel.SetActive(true);
        }
        public void DeactiveBtn()
        {
            StartCoroutine(CoStartCounting());
            view.btnStartGame.interactable = false;
            view.btnQuitRoom.interactable = false;
            view.btnSwapTeam.interactable = false;
            
        }
        public void OnLeaveRoomBtn()
        {
            view.customRoomPanel.SetActive(false);
            view.customRoomListPanel.SetActive(false);
            view.background.SetActive(false);
            PhotonNetwork.LeaveRoom();
        }
        public void OnStartRoomBtn()
        {
            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { "RoomState", "Start" } });
        }
        public void OnSwapTeamBtn()
        {
            StringBuilder curTeam = new StringBuilder((string)PhotonNetwork.LocalPlayer.CustomProperties["Team"]);
            StringBuilder changeTeam = new StringBuilder();
            SetRoomTeamCount(curTeam, -1);
            if (curTeam.ToString() == "RT")
                changeTeam.Append("BT");
            else
                changeTeam.Append("RT");

            SetRoomTeamCount(changeTeam, 1);
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", changeTeam.ToString() } });
        }
        private void SetRoomTeamCount(StringBuilder teamType, int count)
        {
            int teamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[teamType.ToString()];
            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { teamType.ToString(), teamCnt + count } });

        }
        public void SetRoomOwner()
        {
            if (PhotonNetwork.IsMasterClient)
            {
                view.btnStartGame.interactable = true;
            }
            else
            {
                view.btnStartGame.interactable = false;
            }
        }
        private IEnumerator CoStartCounting()
        {
            int delayCnt = 3;
            
            view.btnStartGame.interactable = false;
            for (int count = delayCnt;  count > 0; count--)
            {
                view.tmpStartBtnText.text = "Waiting for " + count.ToString();
                yield return new WaitForSeconds(1);
            }
            view.tmpStartBtnText.text = "Starting...";
        }
    }
    

}
