using System.Collections;
using System.Collections.Generic;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using PhotnHashtable = ExitGames.Client.Photon.Hashtable;
using UnityEngine;
using TMPro;
using System;

namespace Orpul1
{
    [Serializable]
    struct RoundData
    {
        private int[] roomTeamCounts;
        public int[] teamScores;
        public int[] teamCounts;
        public int[] switchRoundScores;
        public int processRoundCnt;
        public int maxRoundScore;
        public int winScoreGap;
        public int switchRoundScore;
        public bool[] isAlreadySwitchRoll;
        public bool isSetBomb;
        public bool isEndRound;
        public void Init()
        {
            teamScores = new int[2];
            teamCounts = new int[2];
            roomTeamCounts = new int[2];
            switchRoundScores = new int[2];
            isAlreadySwitchRoll = new bool[2];
            for (int i=0; i<(int)ETeam.END; i++)
            {
                EPropertyType teamType = (EPropertyType)i;
                roomTeamCounts[i] = (int)PhotonNetwork.CurrentRoom.CustomProperties[teamType.ToString()];
                teamScores[i] = 0;
                teamCounts[i] = roomTeamCounts[i];
                switchRoundScores[i] = 0;
                isAlreadySwitchRoll[i] = false;
            }
        }
        private void SwapTeam()
        {
            int tempScore = teamScores[(int)ETeam.REDTEAM];
            teamScores[(int)ETeam.REDTEAM] = teamScores[(int)ETeam.BLUETEAM];
            teamScores[(int)ETeam.BLUETEAM] = tempScore;

            int teamCount = teamCounts[(int)ETeam.REDTEAM];
            teamCounts[(int)ETeam.REDTEAM] = teamCounts[(int)ETeam.BLUETEAM];
            teamCounts[(int)ETeam.BLUETEAM] = teamCount;

            bool isSwitchRoll = isAlreadySwitchRoll[(int)ETeam.REDTEAM];
            isAlreadySwitchRoll[(int)ETeam.REDTEAM] = isAlreadySwitchRoll[(int)ETeam.BLUETEAM];
            isAlreadySwitchRoll[(int)ETeam.BLUETEAM] = isSwitchRoll;
        }
        public void Reset()
        {
            for (int i = 0; i < (int)ETeam.END; i++)
                teamCounts[i] = roomTeamCounts[i];
        }
        public bool IsSwitchRoll()
        {
            bool isSwitchRoll = false;
            for (int i = 0; i < (int)ETeam.END; i++)
            {
                if (switchRoundScores[i] < switchRoundScore) continue;
                if (isAlreadySwitchRoll[i]) continue;
                SwapTeam();
                isSwitchRoll = true;
                switchRoundScores[(int)ETeam.REDTEAM] = 0;
                switchRoundScores[(int)ETeam.BLUETEAM] = 0;
                isAlreadySwitchRoll[i] = true;
                Managers.RoundData.SetTeamScore(ETeam.REDTEAM, teamScores[(int)ETeam.REDTEAM]);
                Managers.RoundData.SetTeamScore(ETeam.BLUETEAM, teamScores[(int)ETeam.BLUETEAM]);
                return true;
            }
            return false;
        }
        public bool IsGameEnd()
        {
            int teamScoreGap = Mathf.Abs(teamScores[(int)ETeam.REDTEAM] - teamScores[(int)ETeam.BLUETEAM]);
            if (teamScoreGap == winScoreGap) return true;

            bool isGameEnd = false;
            for (int i = 0; i < (int)ETeam.END; i++)
            {
                if (teamScores[i] < maxRoundScore) continue;
                isGameEnd = true;
            }
            return isGameEnd;
        }
    }
    public class GameProcess : GameProcessLogic,IBombStateAble,ISetTeamCountAble
    {
        [SerializeField] RoundData roundData = new RoundData();
        [SerializeField] float roundInterval;

        ISetDataAble<EGameState> setNextEndRoundGameState;
        ETeam winnerTeam;
        EGameState nextRoundState;
        bool isEndRound = false;
        bool isStopCount = false;
        private void Start()
        {
            setNextEndRoundGameState = GetComponent<RoundEndWaiter>();
            roundData.Init();
        }
        public override void EnterState()
        {
            isEndRound = false;
            isStopCount = false;
            gameData.playerSetGameState.SetGameState(EGameState.GAMESTART);
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotnHashtable { { EPropertyType.STATE.ToString(), EPlayerState.START} });
            roundData.Reset();
            for (int i = 0; i < (int)ETeam.END; i++)
                gameData.teamUIController.UpdateTeamScore((ETeam)i, roundData.teamScores[i]);
            
            PhotonNetwork.NetworkingClient.EventReceived -= OnRoundEnd;
            PhotonNetwork.NetworkingClient.EventReceived -= OnDecreaseTeamCount;
            PhotonNetwork.NetworkingClient.EventReceived -= OnBombEvent;
            PhotonNetwork.NetworkingClient.EventReceived += OnRoundEnd;
            PhotonNetwork.NetworkingClient.EventReceived += OnDecreaseTeamCount;
            PhotonNetwork.NetworkingClient.EventReceived += OnBombEvent;
            StartCoroutine("CoStartCountDown");
        }

        public override void UpdateState()
        {
            if (!isEndRound) return;
            Debug.Log($"nextRound {nextRoundState.ToString()}");
            setNextEndRoundGameState.SetData(nextRoundState); 
            transitionState((int)EGameState.ROUNDENDWAIT);
        }

        public override void ExitState()
        {
            PhotonNetwork.NetworkingClient.EventReceived -= OnRoundEnd;
            PhotonNetwork.NetworkingClient.EventReceived -= OnDecreaseTeamCount;
            PhotonNetwork.NetworkingClient.EventReceived -= OnBombEvent;
            isEndRound = true;
        }

        private IEnumerator CoStartCountDown()
        {
            float timeCount = 0;
            TextMeshProUGUI timeTMP = LocalManagers.UI.GetPopupUI<PlayScene>("PlayCanvas").timer;
            
            while (timeCount < roundInterval) 
            {
                if (isEndRound) yield break;
                if (isStopCount) yield break;
                timeCount += Time.deltaTime;
                timeTMP.text = string.Format("{0:00}:{1:00}", (int)(roundInterval - timeCount) / 60, (int)(roundInterval - timeCount) % 60);
                yield return null;
            }
            RaiseEventRoundEnd(ETeam.BLUETEAM);
        }
        private EGameState GetNextRoundState()
        {
            if (roundData.IsGameEnd()) return EGameState.GAMEEND;
            if (roundData.IsSwitchRoll()) return EGameState.SWITCHTEAMROLL;
            return EGameState.ROUNDWAIT;
        }
       
        private void RaiseEventRoundEnd(ETeam winnerTeam)
        {
            if (!PhotonNetwork.IsMasterClient) return;
            IncreaseTeamScore(winnerTeam);
            EGameState nextRound = GetNextRoundState();
            object[] customDatas = new object[] { nextRound, winnerTeam, roundData.teamScores };
            PhotonNetwork.RaiseEvent((int)PunEventType.ENDROUND, customDatas, gameData.options, SendOptions.SendUnreliable);
        }
        private void RaiseEventDecreaseTeamCount(ETeam teamType)
        {
            PhotonNetwork.RaiseEvent((int)PunEventType.PLAYERDIE, teamType, gameData.options, SendOptions.SendUnreliable);
        }
        private void RaiseEventBombEvent(EBombState bombState)
        {
            if (!PhotonNetwork.IsMasterClient) return;
            PhotonNetwork.RaiseEvent((int)PunEventType.BOMBEVENT, bombState, gameData.options, SendOptions.SendUnreliable);
        }

        private void OnRoundEnd(EventData punData)
        {
            if (punData.Code != (int)PunEventType.ENDROUND) return;
            object[] datas = (object[])punData.CustomData;
            nextRoundState = (EGameState)datas[0];
            winnerTeam = (ETeam)datas[1];
            roundData.teamScores = (int[])datas[2];
            Managers.RoundData.SetRoundWinTeam((WinnerTeam)winnerTeam);
            Managers.RoundData.SetTeamScore(winnerTeam, roundData.teamScores[(int)winnerTeam]);
            for (int i = 0; i < (int)ETeam.END; i++)
            {
                Debug.Log($"{(ETeam)i} Score: {roundData.teamScores[i]}");
                
                gameData.teamUIController.UpdateTeamScore((ETeam)i, roundData.teamScores[i]);
            }

            isEndRound = true;
        }
        private void OnDecreaseTeamCount(EventData punData)
        {
            if (punData.Code != (int)PunEventType.PLAYERDIE) return;
            Debug.Log("DecreaseTeamCount");
            ETeam teamType = (ETeam)punData.CustomData;
            ETeam otherTeamType = ETeam.BLUETEAM - (int)teamType;
            Managers.RoundData.IncreaseTeamKillScore(otherTeamType);

            if (!PhotonNetwork.IsMasterClient) return;
            roundData.teamCounts[(int)teamType] -= 1;

            if (roundData.teamCounts[(int)teamType] > 0) return;
            RaiseEventRoundEnd(otherTeamType);
        }
        private void OnBombEvent(EventData punData)
        {
            if (punData.Code != (int)PunEventType.BOMBEVENT) return;
            EBombState bombState = (EBombState)punData.CustomData;
            if (bombState == EBombState.SET)
            {
                isStopCount = true;
                return;
            }
            Managers.RoundData.IncreaseTeamMissionScore((ETeam)bombState);
            if (!PhotonNetwork.IsMasterClient) return;
            RaiseEventRoundEnd((ETeam)bombState);
        }
        public void BombEvent(EBombState bombState)
        {
           RaiseEventBombEvent(bombState);
        }
        public void DecreaseTeamCount(int teamType)
        {
            RaiseEventDecreaseTeamCount((ETeam)teamType);        
        }
        private void IncreaseTeamScore(ETeam teamType)
        {
            //TODO: ÆÀ Á¡¼ö ¼³Á¤
            roundData.teamScores[(int)teamType] += 1;
            roundData.switchRoundScores[(int)teamType] += 1;
        }
    }
}
