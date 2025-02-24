using System;
using System.Collections;
using System.Collections.Generic;
using ExitGames.Client.Photon;
using Photon.Pun;
using UnityEngine;

namespace Orpul1
{
    public class RoundController:IRunEventAble
    {
        LogicContext logicContext;
        EventUIController eventUIController;
        GameRoundData roundData = new GameRoundData();
        [SerializeField]
        public bool IsEndRound { get { return roundData.IsEndRound; } }

        public void Initialize(LogicContext logicContext)
        {
            this.logicContext = logicContext;
            eventUIController = new EventUIController(logicContext.teamUIController);
            int attackTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
            int defenceTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
            logicContext.debugRoundData = roundData;
            this.roundData.Initialize(logicContext.teamUIController);
            this.roundData.SetTeamCount((int)ETeam.REDTEAM, attackTeamCnt);
            this.roundData.SetTeamCount((int)ETeam.BLUETEAM, defenceTeamCnt);
            roundData.SetTeamScore();
        }

       

        private bool IsNextRound()
        {
            int attackTeamScore = roundData.TeamScores[(int)ETeam.REDTEAM];
            int defenseTeamScore = roundData.TeamScores[(int)ETeam.BLUETEAM];
            int switchRollScore = Mathf.Max(attackTeamScore, defenseTeamScore);
            if (switchRollScore == 3 && !roundData.isAlreadySwitchRoll)
            {
                roundData.isAlreadySwitchRoll = true;
                return false;
            }
            return true;
        }
        private bool IsEndGame()
        {
            int attackTeamScore = roundData.TeamScores[(int)ETeam.REDTEAM];
            int defenseTeamScore = roundData.TeamScores[(int)ETeam.BLUETEAM];

            float scoreGap = Mathf.Abs(attackTeamScore - defenseTeamScore);

            if (scoreGap >= roundData.winRound) return true;
            if (roundData.processRoundCnt > roundData.maxRound) return true;
            return false;
        }
        public void OnSetTeamCount(EventData punEvent)
        {
            if (punEvent.Code != (int)PunEventType.PLAYERDIE) return;
            Debug.Log("On PlayerDie Event");
            int teamType = (int)punEvent.CustomData;
            roundData.SetDecreaseTeamCount(teamType);
            Managers.UI.ClosePopupUI("DieCanvas");
        }
        public void OnEndRound(EventData punEvent)
        {
            if (punEvent.Code != (int)PunEventType.ENDROUND) return;
            Debug.Log("On ENDROUND Event");
            object[] datas = (object[])punEvent.CustomData;
            roundData.SetEndRound((GameRoundData.RoundEndType)datas[0], (bool)datas[1]);
            Managers.UI.ClosePopupUI("DieCanvas");
        }
        public void SetRoundTimeOver()
        {
            roundData.RoundTimeOver();
        }
        
        public object[] GetEndEvnetDatas()
        {
            Debug.Log($"---endType {roundData.EndRoundType.ToString()}");
            return new object[] { roundData.EndRoundType,roundData.IsEndRound};
        }

        public void SetTeamScore()
        {
            roundData.SetTeamScore();
        }
        public EGameState GetGameState()
        {
            EGameState gameState = roundData.GetNextState();
            if(gameState == EGameState.ROUNDWAIT)
            {
                logicContext.playerObj.GetComponent<IRespawnAble>().DoRespawn();
            }
            return gameState;
            /*if (IsEndGame())
            {
                return EGameState.GAMEEND;
            }
            roundData.processRoundCnt++;
            if (IsNextRound())
            {
                Debug.Log($"Player Respawn : {logicContext.playerObj.name}");
                logicContext.playerObj.GetComponent<IRespawnAble>().DoRespawn();
                return EGameState.GAMESTART;
            }
            roundData.SwapTeam();
            return EGameState.SWITCHTEAMROLL;*/
        }

       

        public void RunEvent(EGameEvent eventType)
        {
            // >> TODO: 이벤트 처리 + 이벤트 UI 띄우기
        }
    }
}