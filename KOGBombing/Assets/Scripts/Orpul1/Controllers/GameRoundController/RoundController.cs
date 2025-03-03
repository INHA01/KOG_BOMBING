using System;
using System.Collections;
using System.Collections.Generic;
using ExitGames.Client.Photon;
using Photon.Pun;
using TMPro;
using UnityEngine;
using UnityEngine.Playables;

namespace Orpul1
{
    public class RoundController:IRunGameEventAble
    {
        GameProcessData gameData;
        EventUIController eventUIController;
        GameRoundData roundData = new GameRoundData();
        TextMeshProUGUI timeTMP;
        float roundInterval = 0;
        float time = 0;
        bool isStopTime = false;
        public bool IsEndRound { get { return roundData.IsEndRound; } }

        public void Initialize(GameProcessData gameData, float roundTime)
        {
            roundInterval = roundTime;
            isStopTime = false;
            time = 0;
            timeTMP = Managers.UI.GetPopupUI<UIPopup>("PlayCanvas").GetComponent<PlayScene>().timer;
            this.gameData = gameData;
            eventUIController = new EventUIController(gameData.teamUIController);
            int attackTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[EPropertyType.REDTEAM.ToString()];
            int defenceTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[EPropertyType.BLUETEAM.ToString()];
            gameData.debugRoundData = roundData;
            this.roundData.Initialize(gameData.teamUIController);
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
            if (roundData.ProcessRoundCnt > roundData.maxRound) return true;
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
            roundData.SetEndRound((RoundEndType)datas[0], (bool)datas[1]);
            Managers.UI.ClosePopupUI("DieCanvas");
        }
        private void SetRoundTimeOver()
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
            gameData.playerSetGameState.SetGameState(gameState);
            return gameState;
        }

        public void DoRemoveEvents()
        {
            roundData.RemoveEvents();
        }
        public void DoRoundCountDown()
        {
            if (isStopTime) return;
            time += Time.deltaTime;
            timeTMP.text = string.Format("{0:00}:{1:00}", (int)(roundInterval - time) / 60, (int)(roundInterval - time) % 60);
            if (time > roundInterval)
            {
                SetRoundTimeOver();
                time = 0;
            }
        }
        public void RunEvent(RoundEndType eventType)
        {
            if(eventType == RoundEndType.BOMBSET)
            {
                //시간 정지
                isStopTime = true;
                roundData.SetBomb();
                return;
            }
            roundData.SetEndRound(eventType, true);
        }
    }
}