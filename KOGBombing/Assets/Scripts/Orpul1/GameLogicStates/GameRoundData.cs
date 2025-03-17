using System;
using Orpul1;
using Photon.Pun;
using UnityEngine;


namespace Orpul1
{
    public enum RoundEndType
    {
        NONE,
        BOMBEXPLOSION,
        BOMBCLEAR,
        BOMBSET,

        TIMEOVER,
        GAMEEND,
        ALLDIEATTACK,
        ALLDIEDEFENCE,
    }
    [Serializable]
    public class GameRoundData
    {
        public int[] teamScores = new int[2] { 0, 0 }; 
        public int[] teamCounts = new int[2] { 0, 0 };
        public int[] switchRoundScores = new int[2] { 0, 0 };
        public int processRoundCnt = 0; 
        public int maxRound = 6;
        public int winGap = 4;
        public int switchRound = 2;
        public bool isAlreadySwitchRoll = false;
        public bool isSetBomb = false;
        public bool isEndRound = false;
        
        RoundEndType roundEndType = RoundEndType.NONE;
        IUpdateScore updateScore;
        public bool IsEndRound { get { return isEndRound; } }
        
        
        public GameRoundData()
        {
            for (int i = 0; i < 2; i++)
            {
                teamScores[i] = 0;
                teamCounts[i] = 0;
            }
            
        }
        
        public void SetTeamScore()
        {
            switch(roundEndType)
            {
                //Defence team win condition
                case RoundEndType.TIMEOVER:
                case RoundEndType.BOMBCLEAR:
                case RoundEndType.ALLDIEATTACK:
                    Managers.RoundData.SetRoundWinTeam(WinnerTeam.BLUETEAM);
                    switchRoundScores[(int)ETeam.BLUETEAM]++;
                    teamScores[(int)ETeam.BLUETEAM]++;
                    updateScore.UpdateTeamScore(ETeam.BLUETEAM, ETeamScore.WINSCORE);
                    break;

                //Attack team win condition
                case RoundEndType.BOMBEXPLOSION:
                case RoundEndType.ALLDIEDEFENCE:
                    Managers.RoundData.SetRoundWinTeam(WinnerTeam.REDTEAM);
                    switchRoundScores[(int)ETeam.REDTEAM]++;
                    teamScores[(int)ETeam.REDTEAM]++;
                    updateScore.UpdateTeamScore(ETeam.REDTEAM, ETeamScore.WINSCORE);
                    break;
            }
        }
    }
}