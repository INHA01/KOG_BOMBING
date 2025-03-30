using System.Collections;
using System.Collections.Generic;
using BAEK;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using Unity.VisualScripting;
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
            gameData.options.Receivers = ReceiverGroup.All;

            Managers.UI.ShowPopupUI<ChatController>(UIKEY.ChatCanvas).SetCanvasOrderLayer(5);
            
            Managers.UI.GetPopupUI<BattleBoardUpdater>(BAEK.UIKEY.BattleBoard).Initialize();
            Managers.UI.ShowPopupUI<Interacting>(UIKEY.Interacting);
            Managers.UI.ClosePopupUI(UIKEY.Interacting);
            PhotonNetwork.NetworkingClient.EventReceived += OnWaitPlayer;
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashtable { { EPropertyType.STATE.ToString(), EPlayerState.READY } });
            Managers.RoundData.Initialize();
            Managers.PointData.Initialize();
            Managers.PointData.SetTeamPlayers();
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
            if (dicReadyPlayer[targetPlayer.NickName] == true) return;
            if (!targetPlayer.CustomProperties.ContainsKey(EPropertyType.STATE.ToString())) return;
            if ((int)targetPlayer.CustomProperties[EPropertyType.STATE.ToString()] != (int)EPlayerState.READY) return;

            readyPlayerCnt++;
            dicReadyPlayer[targetPlayer.NickName] = true;
        }
        private void OnWaitPlayer(EventData punEvent)
        {
            if ((int)punEvent.Code != (int)PunEventType.PLAYERREADY) return;
            isAllPlayerReady = true;
            Debug.Log("OnWaitPlayer Event");
        }

        protected override void SetCurReadyPlayer()
        {
            Player[] players = PhotonNetwork.PlayerList;
            for (int i = 0; i < players.Length; i++)
            {
                if (dicReadyPlayer[players[i].NickName] == true) continue;
                if ((int)players[i].CustomProperties[EPropertyType.STATE.ToString()] == (int)EPlayerState.READY)
                {
                    dicReadyPlayer[players[i].NickName] = true;
                    readyPlayerCnt++;
                }
            }
        }

        protected override IEnumerator CoWaitPlayer()
        {
            while (readyPlayerCnt != curPlayerCnt)
            {
                //Debug.Log("WaitPlayerReady");
                yield return null;
            }
            Debug.Log("End CoWaitPlayer");

            PhotonNetwork.RaiseEvent((int)PunEventType.PLAYERREADY, null, gameData.options, SendOptions.SendUnreliable);
        }
    }
}
