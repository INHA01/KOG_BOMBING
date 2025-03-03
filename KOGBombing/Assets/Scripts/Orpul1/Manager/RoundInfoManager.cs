using System.Collections;
using System.Collections.Generic;
using Orpul1;
using UnityEngine;

namespace Orpul1
{
    public class RoundInfoManager
    {
        int[] teamScore = new int[2];
        int[] teamkillScore = new int[2];
        int[] teamMissionScore = new int[2];
        private ETeam roundWinTeam;
        public ETeam RoundWinTeam
        {
            get
            {
                return roundWinTeam;
            }
        }
        public int[] TeamScore { get { return teamScore; } }
        public int[] TeamKillScore { get { return teamkillScore; } }
        public int[] TeamMissionScore{ get { return teamMissionScore; } }
        
        public int WinTeam
        { 
            get 
            {
                int result = teamScore[(int)ETeam.REDTEAM] - teamScore[(int)ETeam.BLUETEAM];
                return result;
            } 
        }

        public void SetTeamKillScore(ETeam type, int score)
        {
            teamkillScore[(int)type] = score;
        }
        public void SetTeamMissionScore(ETeam type, int score)
        {
            teamMissionScore[(int)type] = score;
        }
        public void SetRoundWinTeam(ETeam type)
        {
            roundWinTeam = type;
        }
        public void SetTeamScore(ETeam type, int score)
        {
            teamScore[(int)type] = score;
        }
    }

}
