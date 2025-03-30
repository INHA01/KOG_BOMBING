using BAEK;
using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public abstract class PhotonMatch : MonoBehaviourPunCallbacks
    {
        [SerializeField] Button btnMatch;
        [SerializeField] protected MatchData matchData;
        protected bool isStopMatch = false;
        protected WaitForSeconds waitOneSec = new WaitForSeconds(1);
        private void Start()
        {
            btnMatch.interactable = true;
        }
        public virtual void Match()
        {
            isStopMatch = false;
            StartCoroutine(CoWaitMatch());
        }
        protected abstract IEnumerator CoWaitMatch();

        public override void OnJoinedRoom()
        {
            SetTeam();
            Managers.UI.ShowPopupUI<ChatController>(UIKEY.ChatCanvas);
        }
        public override void OnLeftRoom()
        {
            Managers.UI.ClosePopupUI(UIKEY.ChatCanvas);
        }

        public override void OnJoinedLobby()
        {
        }
        
        public override void OnPlayerLeftRoom(Player otherPlayer)
        {
            if(!PhotonNetwork.IsMasterClient)return;
            EPropertyType playerTeam = (EPropertyType)otherPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
            int teamCount = (int)PhotonNetwork.CurrentRoom.CustomProperties[playerTeam.ToString()];
            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { playerTeam.ToString(), teamCount - 1 } });
        }
        public override void OnRoomPropertiesUpdate(PhotonHashTable properties)
        {
            if (!properties.ContainsKey(EPropertyType.ROOMSTATE.ToString())) return;
            if ((int)properties[EPropertyType.ROOMSTATE.ToString()] != (int)ERoomState.START) return;
            UIEventBus.Publish(UIEventBus.UIEventType.DEACTIVEWAITMATCHPAENL);

            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { EPropertyType.STATE.ToString(), EPlayerState.WAIT } });
            SetPlayerTeamIndex();
            btnMatch.interactable = false;
            StartCoroutine(CoStartDelay());
        }
       private void SetPlayerTeamIndex()
        {
            if (!PhotonNetwork.IsMasterClient) return;
            Player[] players = PhotonNetwork.PlayerList;
            int[] teamIndexs = new int[2] { 0, 0 };
            for(int i=0; i<players.Length; i++)
            {
                int team = (int)players[i].CustomProperties[EPropertyType.TEAM.ToString()];
                players[i].SetCustomProperties(new PhotonHashTable { { EPropertyType.TEAMINDEX.ToString(), teamIndexs[team]++ } });
            }
        }
        protected void SetTeam()
        {
            int redTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[EPropertyType.REDTEAM.ToString()];
            int blueTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[EPropertyType.BLUETEAM.ToString()];
            int[] teamCounts = new int[2] { redTeamCnt, blueTeamCnt };
            ETeam team = redTeamCnt <= blueTeamCnt ? ETeam.REDTEAM : ETeam.BLUETEAM; ;

            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { EPropertyType.TEAM.ToString(), team } });
            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { team.ToString(), teamCounts[(int)team] + 1 } });
        }
        protected void InitRoundData()
        {
            Managers.RoundData.Initialize();
            Managers.PunData.Initialize();
            Managers.CamData.InitCamera();
            Managers.PointData.Initialize();
        }
        protected virtual IEnumerator CoStartDelay()
        {
            if (PhotonNetwork.IsMasterClient)
            {
                PhotonNetwork.CurrentRoom.IsOpen = false;
                PhotonNetwork.IsMessageQueueRunning = true;
            }
            InitRoundData();
            float time = Time.time + matchData.StartDelay;
            int count = 0;
            Managers.Sound.PlayUISound(EUiSoundType.MATCHFOUNDCOUNT);

            while (count < time)
            {
                count++;
                yield return waitOneSec;
            }
            Managers.Sound.PlayUISound(EUiSoundType.MATCHFOUNDSET);
            for (int i = 0; i < 2; i++)
                yield return waitOneSec;
            Managers.UI.ClosePopupUI(UIKEY.ChatCanvas);
            Managers.SceneLoad.LoadScene(ESceneType.MainGame.ToString());
        }
    }
}
