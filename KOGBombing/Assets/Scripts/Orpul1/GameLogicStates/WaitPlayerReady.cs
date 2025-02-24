using System.Collections;
using System.Collections.Generic;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using PhotonHashtable = ExitGames.Client.Photon.Hashtable;


namespace Orpul1
{
    public class WaitPlayerReady : PhotonPlayerWaitLogic
    {

        int curPlayerCnt = 0;
        bool isAllPlayerReady = false;
        public override void EnterState()
        {
            readyPlayerCnt = 0;
            isAllPlayerReady = false;
            curPlayerCnt = PhotonNetwork.CurrentRoom.PlayerCount;
            logicContext.options.Receivers = ReceiverGroup.All;
            PhotonNetwork.NetworkingClient.EventReceived += OnWaitPlayer;
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashtable { { "State", EPlayerState.READY } });
            base.EnterState();
        }

        public override void ExitState()
        {
            PhotonNetwork.NetworkingClient.EventReceived -= OnWaitPlayer;
        }

        public override void UpdateState()
        {
            if (isAllPlayerReady)
                transitionState((int)EGameState.SELECT);
        }

        public override void OnPlayerPropertiesUpdate(Player targetPlayer, PhotonHashtable changedProps)
        {
            if (!PhotonNetwork.IsMasterClient) return;
            if (!targetPlayer.CustomProperties.ContainsKey("State")) return;
            if ((int)targetPlayer.CustomProperties["State"] != (int)EPlayerState.READY) return;

            readyPlayerCnt++;
            SendAllPlayerReady();
        }
        private void SendAllPlayerReady()
        {
            if (!(curPlayerCnt == readyPlayerCnt)) return;
            PhotonNetwork.RaiseEvent((int)PunEventType.PLAYERREADY, null, logicContext.options, SendOptions.SendReliable);
        }
        private void OnWaitPlayer(EventData punEvent)
        {
            if (punEvent.Code == (byte)PunEventType.PLAYERREADY)
            {
                isAllPlayerReady = true;
            }
        }

        protected override void SetCurReadyPlayer()
        {
            Player[] player = PhotonNetwork.PlayerList;
            for (int i = 0; i < player.Length; i++)
            {
                if ((int)player[i].CustomProperties["State"] == (int)EPlayerState.READY)
                    readyPlayerCnt++;
            }
        }

        protected override IEnumerator CoWaitPlayer()
        {
            while (readyPlayerCnt != PhotonNetwork.CurrentRoom.PlayerCount)
            {
                Debug.Log("WaitPlayerReady");
                yield return null;
            }
            PhotonNetwork.RaiseEvent((int)EGameRound.PLAYERREADY, null, logicContext.options, SendOptions.SendUnreliable);
        }
    }
}
