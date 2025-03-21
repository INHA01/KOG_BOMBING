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
using UnityEngine.AI;

namespace Orpul1
{
    [Serializable]
    public class RoundData
    {
        private int[] roomTeamCounts;
        public int[] teamScores;
        public int[] teamCounts;
        public int[] secondHalfScores = new int[2];
        public int processRoundCnt;
        public int maxRoundScore;
        public int winScoreGap;
        public int switchRoundScore;
        public bool isAlreadySwitchRoll;
        public bool isSetBomb;
        public bool isEndRound;
        int[] canGetScore = new int[2] { 3, 3 }; 
        public void Init()
        {
            teamScores = new int[2];
            teamCounts = new int[2];
            roomTeamCounts = new int[2];
            isAlreadySwitchRoll = false;
            for (int i=0; i<(int)ETeam.END; i++)
            {
                EPropertyType teamType = (EPropertyType)i;
                roomTeamCounts[i] = (int)PhotonNetwork.CurrentRoom.CustomProperties[teamType.ToString()];
                teamScores[i] = 0;
                teamCounts[i] = roomTeamCounts[i];
            }
        }
        private void SwapTeam()
        {
            int tempScore = teamScores[(int)ETeam.REDTEAM];
            teamScores[(int)ETeam.REDTEAM] = teamScores[(int)ETeam.BLUETEAM];
            teamScores[(int)ETeam.BLUETEAM] = tempScore;

            Managers.RoundData.SetTeamScore(ETeam.REDTEAM, teamScores[(int)ETeam.REDTEAM]);
            Managers.RoundData.SetTeamScore(ETeam.BLUETEAM, teamScores[(int)ETeam.BLUETEAM]);

            int teamCount = roomTeamCounts[(int)ETeam.REDTEAM];
            roomTeamCounts[(int)ETeam.REDTEAM] = roomTeamCounts[(int)ETeam.BLUETEAM];
            roomTeamCounts[(int)ETeam.BLUETEAM] = teamCount;

        }
        public void Reset()
        {
            for (int i = 0; i < (int)ETeam.END; i++)
            {
                ETeam team = (ETeam)i;
                teamCounts[(int)team] = (int)PhotonNetwork.CurrentRoom.CustomProperties[team.ToString()];
            }
        }
        public bool IsSwitchRoll()
        {
            for (int i = 0; i < (int)ETeam.END; i++)
            {
                if (isAlreadySwitchRoll) continue;
                if (teamScores[i] < switchRoundScore) continue;
                SwapTeam();
                isAlreadySwitchRoll = true;
                return true;
            }
            return false;
        }
        public bool IsGameEnd()
        {
            for (int i = 0; i < (int)ETeam.END; i++)
            {
                if (teamScores[i] < maxRoundScore) continue;
                return true;
            }
            if (!isAlreadySwitchRoll) return false;
            for (int i = 0; i < (int)ETeam.END; i++)
            {
                if (secondHalfScores[i] == 3) return true;
            }
            int teamScoreGap = Mathf.Abs(teamScores[(int)ETeam.REDTEAM] - teamScores[(int)ETeam.BLUETEAM]);
            ETeam loseTeam = teamScores[(int)ETeam.REDTEAM] > teamScores[(int)ETeam.BLUETEAM] ? ETeam.BLUETEAM : ETeam.REDTEAM;
            if (teamScoreGap > canGetScore[(int)loseTeam]) return true;
            canGetScore[ETeam.BLUETEAM - loseTeam]--;


            return false;
        }
    }
    public class GameProcess : GameProcessLogic,IBombStateAble,ISetTeamCountAble
    {
        [SerializeField] RoundData roundData = new RoundData();
        [SerializeField] float roundInterval;
        ISetDataAble<EGameState> setNextEndRoundGameState;
        ETeam winnerTeam;
        EGameState nextRoundState;
        SendOptions sendOptions = new SendOptions();
        public RoundData RoundData { get { return roundData; } set { roundData = value; } }
        public void DoCheatGameEnd(ETeam winnerTeam)
        {
            RaiseEventRoundEnd(winnerTeam);
        }
        private void Start()
        {
            setNextEndRoundGameState = GetComponent<RoundEndWaiter>();
            roundData.Init();
            sendOptions.Reliability = true;
            sendOptions.DeliveryMode = DeliveryMode.Reliable;
        }
        public override void EnterState()
        {
            Managers.Sound.PlayUISound(EUiSoundType.ROUNDSTART);
            roundData.isEndRound = false;
            roundData.isSetBomb = false;
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
            if (!roundData.isEndRound) return;
            Debug.Log($"nextRound {nextRoundState.ToString()}");
            setNextEndRoundGameState.SetData(nextRoundState); 
            transitionState((int)EGameState.ROUNDENDWAIT);
        }

        public override void ExitState()
        {
            PhotonNetwork.NetworkingClient.EventReceived -= OnRoundEnd;
            PhotonNetwork.NetworkingClient.EventReceived -= OnDecreaseTeamCount;
            PhotonNetwork.NetworkingClient.EventReceived -= OnBombEvent;
            roundData.isEndRound = true;
            roundData.isSetBomb = false;
        }

        private IEnumerator CoStartCountDown()
        {
            float timeCount = 0;
            TextMeshProUGUI timeTMP = Managers.UI.GetPopupUI<PlayScene>(BAEK.UIKEY.Play).timer;
            
            while (timeCount < roundInterval) 
            {
                if (roundData.isEndRound) yield break;
                if (roundData.isSetBomb) yield break;
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
            if (roundData.teamCounts[(int)ETeam.REDTEAM] == 0 && roundData.isSetBomb) return;
            IncreaseTeamScore(winnerTeam);
            EGameState nextRound = GetNextRoundState();
            object[] customDatas = new object[] { nextRound, winnerTeam, roundData.teamScores };
            PhotonNetwork.RaiseEvent((int)PunEventType.ENDROUND, customDatas, gameData.options, sendOptions);
        }
        private void RaiseEventDecreaseTeamCount(ETeam teamType)
        {
            PhotonNetwork.RaiseEvent((int)PunEventType.PLAYERDIE, teamType, gameData.options, sendOptions);
        }
        private void RaiseEventBombEvent(EBombState bombState, int playerIndex)
        {
            PhotonNetwork.RaiseEvent((int)PunEventType.BOMBEVENT, new object[]{ bombState, playerIndex }, gameData.options, sendOptions);
        }

        private void OnRoundEnd(EventData punData)
        {
            if (punData.Code != (int)PunEventType.ENDROUND) return;
            Managers.RoundData.roundCount++;
            object[] datas = (object[])punData.CustomData;
            nextRoundState = (EGameState)datas[0];
            winnerTeam = (ETeam)datas[1];
            roundData.teamScores = (int[])datas[2];
            Managers.RoundData.SetRoundWinTeam((WinnerTeam)winnerTeam);
            Managers.RoundData.SetTeamScore(winnerTeam, roundData.teamScores[(int)winnerTeam]);
            if(roundData.isAlreadySwitchRoll)
            {
                roundData.secondHalfScores[(int)winnerTeam]++;
            }
            for (int i = 0; i < (int)ETeam.END; i++)
            {
                gameData.teamUIController.UpdateTeamScore((ETeam)i, roundData.teamScores[i]);
            }

            roundData.isEndRound = true;
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
            object[] datas = (object[])punData.CustomData;
            EBombState bombState = (EBombState)datas[0];
            Debug.Log($"bombState {bombState.ToString()}");
            int playerIndex = (int)datas[1];

            if (bombState == EBombState.SET)
            {
                roundData.isSetBomb = true;
                return;
            }
            Managers.RoundData.IncreaseTeamMissionScore((ETeam)bombState);
            roundData.isSetBomb = false;
            if (!PhotonNetwork.IsMasterClient) return;
            gameData.playerObj.GetComponent<ISetPointable>().SetMissionPoint((ETeam)bombState, playerIndex);
            RaiseEventRoundEnd((ETeam)bombState);
        }
        public void BombEvent(EBombState bombState, int playerIndex)
        {
           RaiseEventBombEvent(bombState, playerIndex);
        }
        public void DecreaseTeamCount(int teamType)
        {
            RaiseEventDecreaseTeamCount((ETeam)teamType);        
        }
        private void IncreaseTeamScore(ETeam teamType)
        {
            //TODO: ÆÀ Á¡¼ö ¼³Á¤
            roundData.teamScores[(int)teamType] += 1;
        }
        bool isGameEnd = false;
        private void OnGUI()
        {
            /*for (int i = 0; i < (int)ETeam.END; i++)
            {
                ETeam team = (ETeam)i;
                string labelStr = team.ToString()+" " + Managers.RoundData.TeamScore[i].ToString();
                GUI.Label(new Rect(Screen.width * 0.25f, 10 * (i + 1), 200, 100), labelStr);
            }
            GUI.Label(new Rect(Screen.width * 0.25f, 60, 200, 100), "isSetBomb " + (roundData.isSetBomb == true ? "True" : "False"));
            GUI.Label(new Rect(Screen.width * 0.25f, 80, 200, 100), "isEndRound " + (roundData.isEndRound == true ? "True" : "False"));
            bool isRedTeamWin = GUI.Button(new Rect(Screen.width * 0.25f, 150, 100, 20), "RedTeamWin");
            bool isBlueTeamWin = GUI.Button(new Rect(Screen.width * 0.25f, 180, 100, 20), "BlueTeamWin");
            
            isGameEnd = GUI.Toggle(new Rect(Screen.width * 0.25f, 200, 100, 20), isGameEnd, "IsGameEnd");
            if(isRedTeamWin)
            {
                if(isGameEnd)
                {
                    roundData.teamScores[(int)ETeam.REDTEAM] = roundData.maxRoundScore;
                    roundData.teamScores[(int)ETeam.BLUETEAM] = 0;
                }
                RaiseEventRoundEnd(ETeam.REDTEAM);
            }
            else if(isBlueTeamWin)
            {
                if (isGameEnd)
                {
                    roundData.teamScores[(int)ETeam.REDTEAM] = 0;
                    roundData.teamScores[(int)ETeam.BLUETEAM] = roundData.maxRoundScore;
                }
                RaiseEventRoundEnd(ETeam.BLUETEAM);
            }*/
        }
    }
}
