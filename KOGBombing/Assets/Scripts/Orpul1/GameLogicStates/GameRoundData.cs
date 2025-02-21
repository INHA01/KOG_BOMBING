using System;
using Orpul1;
using UnityEngine;


namespace Orpul1
{
    [Serializable]
    public class GameRoundData
    {
        public int[] teamScores = new int[2] { 0, 0 }; //private
        public int[] teamCounts = new int[2] { 0, 0 }; //private
        public int[] TeamScores { get { return teamScores; } }
        public int[] TeamCounts { get { return teamCounts; } }
        public int maxRound = 10;
        public int winRound = 4;
        public int processRoundCnt = 0; //private
        public int switchRound = 2;
        public bool isAlreadySwitchRoll = false;
        bool isTimeOver = false;
        bool isExplosion = false;
        public GameRoundData()
        {
            isTimeOver = false;
            isExplosion = false;
            for (int i = 0; i < 2; i++)
            {
                teamScores[i] = 0;
                teamCounts[i] = 0;
            }
        }
        public void Initialize()
        {
            isTimeOver = false;
            isExplosion = false;
        }
        public void SetTeamCount(int teamType, int count)
        {
            teamCounts[teamType] = count;
        }
        public void SetDecreaseTeamCount(int teamType)
        {
            teamCounts[teamType]--;
        }

        public bool IsExterminateTeam()
        {
            if (teamCounts[(int)ETeam.REDTEAM] != 0 && teamCounts[(int)ETeam.BLUETEAM] != 0) return false;

            return true;
        }
        public void SetTeamScore()
        {
            if (isExplosion)
            {
                teamScores[(int)ETeam.REDTEAM]++;
                return;
            }
            else if (isTimeOver)
            {
                teamScores[(int)ETeam.BLUETEAM]++;
                return;
            }

            if (teamCounts[(int)ETeam.REDTEAM] == 0)
            {
                teamScores[(int)ETeam.BLUETEAM]++;
            }
            else
            {
                teamScores[(int)ETeam.REDTEAM]++;
            }
        }
        public void SwapTeam()
        {
            int score = teamScores[(int)ETeam.REDTEAM];
            teamScores[(int)ETeam.REDTEAM] = teamScores[(int)ETeam.BLUETEAM];
            teamScores[(int)ETeam.BLUETEAM] = score;
            Debug.Log("Swap Team Score");
        }
        public void RoundTimeOver()
        {
            isTimeOver = true;
        }
        public void ExplosionBomb()
        {
            isExplosion = true;
        }
        public EGameState GetNextState()
        {
            if (IsEndGame())
                return EGameState.GAMEEND;

            processRoundCnt++;
            if (IsNextRound())
                return EGameState.ROUNDWAIT;
            else
                return EGameState.SWITCHTEAMROLL;
        }

        private bool IsEndGame()
        {
            float scoreGap = Mathf.Abs(teamScores[(int)ETeam.REDTEAM] - teamScores[(int)ETeam.BLUETEAM]);

            if (scoreGap >= winRound) return true;
            if (teamScores[(int)ETeam.REDTEAM] > maxRound && teamScores[(int)ETeam.BLUETEAM] > maxRound) return true;
            return false;
        }
        private bool IsNextRound()
        {
            //processRoundCnt % switchRound == 0
            int switchRollScore = Mathf.Max(teamScores[(int)ETeam.REDTEAM], teamScores[(int)ETeam.BLUETEAM]);
            if (switchRollScore == 3)
                return false;
            return true;
        }
    }
}