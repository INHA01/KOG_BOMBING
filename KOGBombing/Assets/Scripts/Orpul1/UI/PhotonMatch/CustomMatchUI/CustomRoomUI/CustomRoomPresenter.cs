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
            ETeam curTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"];
            ETeam changeTeam = ETeam.REDTEAM;
            SetRoomTeamCount(curTeam, -1);
            if (curTeam == ETeam.REDTEAM)
                changeTeam = ETeam.BLUETEAM;
            SetRoomTeamCount(changeTeam, 1);
            SetTeamIndex(changeTeam);
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", changeTeam } });
        }

        private void SetTeamIndex(ETeam playerTeam)
        {
            int teamIndex = 0;
            if (playerTeam == ETeam.REDTEAM)
            {
                teamIndex = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"] + 1;
            }
            else
            {
                teamIndex = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"] + 1;
            }
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "TeamIndex", teamIndex } });
            Debug.Log($"TeamIndex {teamIndex}");

        }
        private void SetRoomTeamCount(ETeam teamType, int count)
        {
            int teamCnt = 0;
            StringBuilder stbTeam = new StringBuilder();
            if (teamType == ETeam.BLUETEAM)
            {
                teamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
                stbTeam.Append("BT");
            }
            else
            {
                teamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
                stbTeam.Append("RT");
            }

            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { stbTeam.ToString(), teamCnt + count } });

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
