using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using TMPro;
using UnityEngine;
using UnityEngine.Playables;
using PhotonHashtable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public class RoundWaiter : PhotonPlayerWaitLogic
    {
        bool canCountDown = false;
        [SerializeField]
        GameObject bombIconUI;
        [SerializeField]
        RoundDoorController[] roundDoorController;

        [SerializeField]
        float gamestartInterval = 5;
        [SerializeField]
        float time = 0;
        IResetAble resetBombIconUI;
        private void Start()
        {
            resetBombIconUI = bombIconUI.GetComponent<IResetAble>();
        }

        public override void EnterState()
        {
            gameData.playerSetGameState.SetGameState(EGameState.ROUNDWAIT);
            for (int i = 0; i < roundDoorController.Length; i++)
            {
                roundDoorController[i].CloseDoor();
            }
            resetBombIconUI.DoReset();
            readyPlayerCnt = 0;
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashtable { { EPropertyType.STATE.ToString(), (int)EPlayerState.WAITROUND } });
            PhotonNetwork.NetworkingClient.EventReceived += OoCountDown;
            canCountDown = false;
            GameEventBus.Publish(GameEventBus.EGameEvent.DOORCLOSE);
            SetPlayerPosi();
            gameData.teamUIController.UpdateTeamScore(ETeam.REDTEAM, Managers.RoundData.TeamScore[(int)ETeam.REDTEAM]);
            gameData.teamUIController.UpdateTeamScore(ETeam.BLUETEAM, Managers.RoundData.TeamScore[(int)ETeam.BLUETEAM]);
            time = 0;
            base.EnterState();
        }
        public override void UpdateState()
        {
            if (canCountDown)
                DoCountDown();
        }
        public override void ExitState()
        {
            PhotonNetwork.NetworkingClient.EventReceived -= OoCountDown;
            for(int i=0; i< roundDoorController.Length; i++)
            {
                roundDoorController[i].OpenDoor();
            }
        }

        public override void OnPlayerPropertiesUpdate(Player targetPlayer, PhotonHashtable hashtable)
        {
            if (!PhotonNetwork.IsMasterClient) return;
            if (dicReadyPlayer[targetPlayer.NickName] == true) return;
            if (!targetPlayer.CustomProperties.ContainsKey(EPropertyType.STATE.ToString())) return;
            if ((int)targetPlayer.CustomProperties[EPropertyType.STATE.ToString()] != (int)EPlayerState.WAITROUND) return;
            
            readyPlayerCnt++;
        }

        void SetPlayerPosi()
        {
            if (!LocalManagers.PunData.IsContainKey(PhotonNetwork.LocalPlayer.NickName)) return;
            
            Vector3 spawnPoint = LocalManagers.PunData.GetPlayerBlackBoard(PhotonNetwork.LocalPlayer.NickName).spawnPoint;
            LocalManagers.PunData.GetPlayerBlackBoard(PhotonNetwork.LocalPlayer.NickName).transform.position = spawnPoint;
        }
        void OoCountDown(EventData punEvent)
        {
            if ((int)punEvent.Code != (int)PunEventType.ROUNDREADY) return;
            canCountDown = true;
        }
        void DoCountDown()
        {
            time += Time.deltaTime;
            TextMeshProUGUI timeTMP = LocalManagers.UI.GetPopupUI<PlayScene>("PlayCanvas").timer;
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
                if ((int)players[i].CustomProperties[EPropertyType.STATE.ToString()] == (int)EPlayerState.WAITROUND)
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
