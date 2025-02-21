using System.Collections;
using System.Collections.Generic;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using UnityEngine;

namespace Orpul1
{
    public class RoundController:IRunEventAble
    {
        LogicContext logicContext;
        EventUIController eventUIController;
        [SerializeField]
        bool isEndRound = false;

        public void Initialize(LogicContext logicContext)
        {
            this.logicContext = logicContext;
            eventUIController = new EventUIController(logicContext.teamUIController);
            int attackTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
            int defenceTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
            this.logicContext.roundData.SetTeamCount((int)ETeam.REDTEAM, attackTeamCnt);
            this.logicContext.roundData.SetTeamCount((int)ETeam.BLUETEAM, defenceTeamCnt);
            this.logicContext.roundData.Initialize();
            isEndRound = false;
        }

        private bool IsNextRound()
        {
            int attackTeamScore = logicContext.roundData.TeamScores[(int)ETeam.REDTEAM];
            int defenseTeamScore = logicContext.roundData.TeamScores[(int)ETeam.BLUETEAM];
            int switchRollScore = Mathf.Max(attackTeamScore, defenseTeamScore);
            if (switchRollScore == 3 && !logicContext.roundData.isAlreadySwitchRoll)
            {
                logicContext.roundData.isAlreadySwitchRoll = true;
                return false;
            }
            return true;
        }
        
        public bool IsEndRound()
        {
            return isEndRound;
        }

        private bool IsEndGame()
        {
            int attackTeamScore = logicContext.roundData.TeamScores[(int)ETeam.REDTEAM];
            int defenseTeamScore = logicContext.roundData.TeamScores[(int)ETeam.BLUETEAM];

            float scoreGap = Mathf.Abs(attackTeamScore - defenseTeamScore);

            if (scoreGap >= logicContext.roundData.winRound) return true;
            if (attackTeamScore > logicContext.roundData.maxRound && defenseTeamScore > logicContext.roundData.maxRound) return true;
            return false;
        }

        public EGameState GetGameState()
        {
            logicContext.roundData.SetTeamScore();
            if (IsEndGame())
            {
                return EGameState.GAMEEND;
            }

            if (IsNextRound())
            {
                logicContext.playerObj.GetComponent<IRespawnAble>().DoRespawn();
                return EGameState.GAMESTART;
            }
            logicContext.roundData.SwapTeam();
            return EGameState.SWITCHTEAMROLL;
        }

        public void OnSetTeamCount(EventData punEvent)
        {
            if ((int)punEvent.Code != (int)EGameRound.EXTERMINATETEAM) return;
            Debug.Log("Exterminate team");
            int teamType = (int)punEvent.CustomData;
            logicContext.roundData.SetDecreaseTeamCount(teamType);
            isEndRound = logicContext.roundData.IsExterminateTeam();
            Managers.UI.ClosePopupUI("DieCanvas");
            Debug.Log($"RT {logicContext.roundData.TeamScores[(int)ETeam.REDTEAM]} BT {logicContext.roundData.TeamScores[(int)ETeam.BLUETEAM]}");
        }

        public void RunEvent(EGameEvent eventType)
        {
            // >> TODO: 이벤트 처리 + 이벤트 UI 띄우기
        }
    }
}