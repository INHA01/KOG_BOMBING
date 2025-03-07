using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Orpul1
{
    public class CustomMatchDirector : PhotonMatch
    {
        TypedLobby customLobby = new TypedLobby("CustomLobby", LobbyType.Default);

        [SerializeField]
        MatchUIController matchUIController;
        bool isCustomMatch = false;
        
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
            float span = Time.time + updateDelay;
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
            float time = Time.time + delayTime;

            while (Time.time < time) yield return null;
            PhotonNetwork.CurrentRoom.IsOpen = false;
            PhotonNetwork.IsMessageQueueRunning = true;
            PhotonNetwork.CurrentRoom.IsOpen = false;
            LoadingSceneManager.LoadScene("MainGame");
        }
    }
}