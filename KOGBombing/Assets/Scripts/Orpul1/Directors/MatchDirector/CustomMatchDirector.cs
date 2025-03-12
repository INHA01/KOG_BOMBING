using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Orpul1
{
    public class CustomMatchDirector : PhotonMatch
    {
        TypedLobby customLobby;

        [SerializeField]
        MatchUIController matchUIController;
        bool isCustomMatch = false;
        private void Start()
        {
            customLobby = new TypedLobby(matchData.LobbyName.ToString(), matchData.LobbyType);
        }
        public override void Match()
        {
            isCustomMatch = true;
            base.Match();
            UIEventBus.Publish(UIEventBus.UIEventType.ACTIVEROOMLISTPANEL);
        }
        public void OnLeftLobbyBtn()
        {
            isStopMatch = true;
            isCustomMatch = false;
            if (PhotonNetwork.InLobby)
                PhotonNetwork.LeaveLobby();
        }
       
        public override void OnJoinedRoom()
        {
            if (isCustomMatch)
            {
                base.OnJoinedRoom();
                UIEventBus.Publish(UIEventBus.UIEventType.ACTIVECUSTOMROOMPANEL);
            }
        }

        public override void OnPlayerLeftRoom(Player otherPlayer)
        {
            if (!isCustomMatch) return;
            base.OnPlayerLeftRoom(otherPlayer);
            UIEventBus.Publish(UIEventBus.UIEventType.SETMASTER);
        }

        protected override IEnumerator CoWaitMatch()
        {
            float span = Time.time + matchData.UpdateDelay;
            while (span > Time.time)
            {
                if (isStopMatch) yield break;
                yield return null;
            }
            PhotonNetwork.JoinLobby(customLobby);
        }

        protected override IEnumerator CoStartDelay()
        {
            UIEventBus.Publish(UIEventBus.UIEventType.DEACTIVECUSTOMROOMPANEL);
            UIEventBus.Publish(UIEventBus.UIEventType.ACTIVEMATCHINGPANEL);
            UIEventBus.Publish(UIEventBus.UIEventType.STARTGAME);
            float time = Time.time + matchData.StartDelay;
            SoundManager.Instance.PlayUISound(EUiSoundType.MATCHFOUNDCOUNT);
            while (Time.time < time) yield return null;
            SoundManager.Instance.PlayUISound(EUiSoundType.MATCHFOUNDSET);
            for(int i=0; i<2; i++)
                yield return waitOneSec;
            PhotonNetwork.CurrentRoom.IsOpen = false;
            PhotonNetwork.IsMessageQueueRunning = true;
            PhotonNetwork.CurrentRoom.IsOpen = false;
            //Loading.LoadScene("MainGame");
            Managers.SceneLoad.LoadScene("MainGame");
        }
    }
}