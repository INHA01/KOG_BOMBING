using Orpul1;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DebugRoundData : MonoBehaviour
{
    public int roundCount = 1;
    public byte[] teamScore = new byte[2];
    public byte[] teamkillScore = new byte[2];
    public byte[] teamMissionScore = new byte[2];

    public WinnerTeam RoundWinTeam;

    public WinnerTeam WinTeam;
    void Update()
    {
#if UNITY_EDITOR
        roundCount = Managers.RoundData.roundCount;
        teamScore = Managers.RoundData.TeamScore;
        teamkillScore = Managers.RoundData.TeamKillScore;
        teamMissionScore = Managers.RoundData.TeamMissionScore;
        RoundWinTeam = Managers.RoundData.RoundWinTeam;
#endif
    }
}
