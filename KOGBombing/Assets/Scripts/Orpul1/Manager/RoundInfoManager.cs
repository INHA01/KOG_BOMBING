using System.Collections;
using System.Collections.Generic;
using Orpul1;
using UnityEngine;

namespace Orpul1
{
    public class RoundInfoManager
    {
        int[] teamScore = new int[2];
        int processRoundCnt = 0;
        ETeam winTeam;
        public int[] TeamScore { get { return teamScore; } }
        public ETeam WinTeam { get { return winTeam; } }

        public int ProcessRoundCnt { get { return processRoundCnt; } }
        ERoundState roundState = ERoundState.FIRSTHALF;
        public ERoundState RoundState { get { return roundState; } }
        public void SetProcessRoundCount(int count)
        {
            processRoundCnt = count;
        }
        public void SetRoundState(ERoundState state)
        {
            roundState = state;
        }
        public void SetTeamScore(ETeam type, int score)
        {
            teamScore[0] = score;
        }

    }

}
