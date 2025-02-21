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
            view.btnSwapRedTeam.interactable = false;
            view.btnSwapBlueTeam.interactable = false;
            
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
        public void OnSwapTeamBtn(int select)
        {
            ETeam changeTeam = (ETeam)select;
            ETeam curTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"];
            if (changeTeam == curTeam) return;
            SetRoomTeamCount(curTeam, -1);
            if (curTeam == ETeam.REDTEAM) changeTeam = ETeam.BLUETEAM;
            SetRoomTeamCount(changeTeam, 1);
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", changeTeam } });
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
            float elapsedTime = 0f;
            float finishTime = 3f;
            float k = 5f; 

            view.btnStartGame.interactable = false;
            view.startCounting.SetActive(true);
            view.startCountingCircle.fillAmount = 0;

            while (true)
            {
                float t = elapsedTime / finishTime;
                view.startCountingCircle.fillAmount = 1 - Mathf.Exp(-k * t);
                elapsedTime += Time.deltaTime;

                if(view.startCountingCircle.fillAmount >= 0.99f)
                {
                    view.startCountingCircle.fillAmount = 0;
                    elapsedTime = 0f;
                }
                yield return null;
            }

        }
    }
    

}
