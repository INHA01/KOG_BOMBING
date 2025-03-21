using System.Collections;
using System.Collections.Generic;
using Orpul1;
using Photon.Pun;
using UnityEngine;
using static UnityEditor.Rendering.InspectorCurveEditor;

public class CheatController : MonoBehaviour
{
    [SerializeField] RoundData roundData;
    [SerializeField] GameProcess gameProcess;
    [SerializeField] GameDirector gameDirector;
    bool isGameEnd = false;
    private void Awake()
    {
        roundData = gameProcess.RoundData;
    }
    private void OnGUI()
    {
        if (!PhotonNetwork.IsMasterClient) return;
        GUI.Label(new Rect(Screen.width * 0.25f, 100, 200, 100), "GameState " + gameDirector.CurState.ToString());
        RoundCheat();
    }
    private void RoundCheat()
    {
        for (int i = 0; i < (int)ETeam.END; i++)
        {
            ETeam team = (ETeam)i;
            string labelStr = team.ToString() + " " + Managers.RoundData.TeamScore[i].ToString();
            GUI.Label(new Rect(Screen.width * 0.25f, 10 * (i + 1), 200, 100), labelStr);
        }
        GUI.Label(new Rect(Screen.width * 0.25f, 60, 200, 100), "isSetBomb " + (roundData.isSetBomb == true ? "True" : "False"));
        GUI.Label(new Rect(Screen.width * 0.25f, 80, 200, 100), "isEndRound " + (roundData.isEndRound == true ? "True" : "False"));
        bool isRedTeamWin = GUI.Button(new Rect(Screen.width * 0.25f, 150, 100, 20), "RedTeamWin");
        bool isBlueTeamWin = GUI.Button(new Rect(Screen.width * 0.25f, 180, 100, 20), "BlueTeamWin");

        isGameEnd = GUI.Toggle(new Rect(Screen.width * 0.25f, 200, 100, 20), isGameEnd, "IsGameEnd");
        if (isRedTeamWin)
        {
            if (isGameEnd)
            {
                roundData.teamScores[(int)ETeam.REDTEAM] = roundData.maxRoundScore;
                roundData.teamScores[(int)ETeam.BLUETEAM] = 0;
            }
            gameProcess.DoCheatGameEnd(ETeam.REDTEAM);
        }
        else if (isBlueTeamWin)
        {
            if (isGameEnd)
            {
                roundData.teamScores[(int)ETeam.REDTEAM] = 0;
                roundData.teamScores[(int)ETeam.BLUETEAM] = roundData.maxRoundScore;
            }
            gameProcess.DoCheatGameEnd(ETeam.BLUETEAM);
        }
    }
}
