using System;
using Orpul1;
using UnityEngine;

public class GameRoundData
{
    int[] teamScores = new int[2] { 0, 0 };
    int[] teamCounts = new int[2] { 0, 0 };
    public int[] TeamScores { get { return teamScores; } }
    public int[] TeamCounts { get { return teamCounts; } }
    bool isTimeOver = false;
    bool isExplosion = false;
    public GameRoundData()
    {
        isTimeOver = false;
        isExplosion = false;
        for (int i=0; i<2; i++)
        {
            teamScores[i] = 0;
            teamCounts[i] = 0;
        }
    }
    public void Init()
    {
        isTimeOver = false;
    }
    public void SetTeamCount(int teamType, int count)
    {
        teamCounts[teamType] += count;
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
        else if(isTimeOver)
        {
            teamScores[(int)ETeam.BLUETEAM]++;
            return;
        }

        if (teamCounts[(int)ETeam.REDTEAM]==0)
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
        if (JudgementNextRound())
            return EGameState.GAMEEND;
        return EGameState.ROUNDWAIT;
    }
    private bool JudgementNextRound()
    {
        return true;
        float scoreGap = Mathf.Abs(teamScores[(int)ETeam.REDTEAM] - teamScores[(int)ETeam.BLUETEAM]);

        if (scoreGap < 3) return false;
        if (teamScores[(int)ETeam.REDTEAM] < 9 && teamScores[(int)ETeam.BLUETEAM] < 9) return false;

        return true;
    }
}