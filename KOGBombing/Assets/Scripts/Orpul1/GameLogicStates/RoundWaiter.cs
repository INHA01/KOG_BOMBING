using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using TMPro;
using UnityEngine;
using PhotonHashtable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public class RoundWaiter : PhotonPlayerWaitLogic
    {
        bool canCountDown = false;
        [SerializeField]
        float gamestartInterval = 5;
        [SerializeField]
        float time = 0;
        
        public override void EnterState()
        {
            readyPlayerCnt = 0;
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashtable { { "State", (int)EPlayerState.WAITROUND } });
            PhotonNetwork.NetworkingClient.EventReceived += OoCountDown;
            canCountDown = false;
            GameEventBus.Publish(GameEventBus.EGameEvent.DOORCLOSE);
            SetPlayerPosi();
            time = 0;
            base.EnterState();
        }
        public override void UpdateState()
        {
            Debug.Log("RoundWait!");
            if (canCountDown)
                DoCountDown();
        }
        public override void ExitState()
        {
            PhotonNetwork.NetworkingClient.EventReceived -= OoCountDown;
        }

        public override void OnPlayerPropertiesUpdate(Player targetPlayer, PhotonHashtable hashtable)
        {
            if (!PhotonNetwork.IsMasterClient) return;
            if (dicReadyPlayer[targetPlayer.NickName] == true) return;
            if (!targetPlayer.CustomProperties.ContainsKey("State")) return;
            if ((int)targetPlayer.CustomProperties["State"] != (int)EPlayerState.WAITROUND) return;
            
            readyPlayerCnt++;
            Debug.Log($"player {targetPlayer.NickName} change WAITROUND state!");
        }

        void SetPlayerPosi()
        {
            if (!Managers.PunData.IsContainKey(PhotonNetwork.LocalPlayer.NickName)) return;
            
            Vector3 spawnPoint = Managers.PunData.GetPlayerBlackBoard(PhotonNetwork.LocalPlayer.NickName).spawnPoint;
            Managers.PunData.GetPlayerBlackBoard(PhotonNetwork.LocalPlayer.NickName).transform.position = spawnPoint;
        }
        void OoCountDown(EventData punEvent)
        {
            if ((int)punEvent.Code != (int)PunEventType.ROUNDREADY) return;
            canCountDown = true;
        }
        void DoCountDown()
        {
            time += Time.deltaTime;
            TextMeshProUGUI timeTMP = Managers.UI.GetPopupUI<UIPopup>("PlayCanvas").GetComponent<PlayScene>().timer;
            timeTMP.text = string.Format("{0:00}:{1:00}", (int)(gamestartInterval - time) / 60, (int)(gamestartInterval - time) % 60);
            if (time > gamestartInterval)
            {
                Debug.Log($"Round Start");
                transitionState((int)EGameState.GAMESTART);
            }
        }

        protected override void SetCurReadyPlayer()
        {
            Player[] players = PhotonNetwork.PlayerList;
            for (int i = 0; i < players.Length; i++)
            {
                if (dicReadyPlayer[players[i].NickName] == true) continue;
                if ((int)players[i].CustomProperties["State"] == (int)EPlayerState.WAITROUND)
                {
                    dicReadyPlayer[players[i].NickName] = true;
                    readyPlayerCnt++;
                }
            }
        }

        protected override IEnumerator CoWaitPlayer()
        {
            Debug.Log("RoundWait");
            while (readyPlayerCnt != PhotonNetwork.CurrentRoom.PlayerCount) yield return null;
            PhotonNetwork.RaiseEvent((int)PunEventType.ROUNDREADY, null, gameData.options, SendOptions.SendUnreliable);
        }
    }
}
