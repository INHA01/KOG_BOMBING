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
        ETeam winTeam;
        public int[] TeamScore { get { return teamScore; } }
        public int[] TeamKillScore { get { return teamkillScore; } }
        public int[] TeamMissionScore{ get { return teamMissionScore; } }
        public ETeam WinTeam
        { get 
            { 
                if(teamScore[(int)ETeam.REDTEAM] > teamScore[(int)ETeam.REDTEAM])
                {
                    return ETeam.REDTEAM;
                }
                return ETeam.BLUETEAM; 
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
        public void SetTeamScore(ETeam type, int score)
        {
            teamScore[(int)type] = score;
        }
    }

}
