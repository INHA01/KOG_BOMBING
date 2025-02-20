using System;
using Orpul1;
using UnityEngine;

[Serializable]
public class GameRoundData
{
    public int[] teamScores = new int[2] { 0, 0 }; //private
    public int[] teamCounts = new int[2] { 0, 0 }; //private
    public int[] TeamScores { get { return teamScores; } }
    public int[] TeamCounts { get { return teamCounts; } }
    public int winRound = 3;
    public int processRoundCnt = 0; //private
    public int switchRound = 2;
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

    }
    public void Init()
    {
        isTimeOver = false;
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

        if (scoreGap > winRound) return true;
        if (teamScores[(int)ETeam.REDTEAM] > 9 && teamScores[(int)ETeam.BLUETEAM] > 9) return true;
        return false;
    }
    private bool IsNextRound()
    {
        if (processRoundCnt % switchRound == 0)
            return false;
        return true;
    }
}