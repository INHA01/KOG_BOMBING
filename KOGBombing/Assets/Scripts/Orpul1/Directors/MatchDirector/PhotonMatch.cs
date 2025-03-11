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
        [SerializeField] protected float updateDelay;
        [SerializeField] protected float delayTime = 5;
        protected bool isStopMatch = false;
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
            if ((string)properties[EPropertyType.ROOMSTATE.ToString()] != "Start") return;

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

        protected virtual IEnumerator CoStartDelay()
        {
            if (PhotonNetwork.IsMasterClient)
            {
                PhotonNetwork.CurrentRoom.IsOpen = false;
                PhotonNetwork.IsMessageQueueRunning = true;
            }
            float time = Time.time + delayTime;
            SoundManager.Instance.PlayUISound(EUiSoundType.MATCHFOUNDCOUNT);
            while (Time.time < time) yield return null;
            SoundManager.Instance.PlayUISound(EUiSoundType.MATCHFOUNDSET);
            //Loading.LoadScene(ESceneType.MainGame.ToString());
            Managers.SceneLoad.LoadScene(ESceneType.MainGame.ToString());
        }
    }
}
