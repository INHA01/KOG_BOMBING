using System.Collections;
using System.Collections.Generic;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

public class CheatController : MonoBehaviour
{
    RaiseEventOptions options = new RaiseEventOptions();
    /* [SerializeField] RoundData roundData;
     [SerializeField] GameProcess gameProcess;
     [SerializeField] GameDirector gameDirector;
     bool isGameEnd = false;
     bool isSwitchRoll = false;
     private void Awake()
     {
         roundData = gameProcess.RoundData;
     }*/
    private void Start()
    {
        options.Receivers = ReceiverGroup.All;
    }
    private void OnGUI()
    {
        //GUI.Label(new Rect(Screen.width * 0.25f, 100, 200, 100), "GameState " + gameDirector.CurState.ToString());
        if (!PhotonNetwork.IsMasterClient) return;
        bool isExplosionEvent = GUI.Button(new Rect(Screen.width * 0.25f, 200, 200, 100), "BombExplosion");
        if(isExplosionEvent)
        {
            object[] datas = new object[] { EBombState.EXPLOSION ,0};
            PhotonNetwork.RaiseEvent((int)PunEventType.BOMBEVENT, datas, options, SendOptions.SendReliable);
        }
        //RoundCheat();
    }
    /*private void RoundCheat()
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
        isSwitchRoll = GUI.Toggle(new Rect(Screen.width * 0.25f, 230, 100, 20), isSwitchRoll, "IsSwitchRoll");
        if (isRedTeamWin)
        {
            if (isGameEnd)
            {
                roundData.teamScores[(int)ETeam.REDTEAM] = roundData.maxRoundScore;
                roundData.teamScores[(int)ETeam.BLUETEAM] = 0;
            }
            else if(isSwitchRoll)
            {
                roundData.teamScores[(int)ETeam.REDTEAM] = 3;
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
            else if (isSwitchRoll)
            {
                roundData.teamScores[(int)ETeam.REDTEAM] = 0;
                roundData.teamScores[(int)ETeam.BLUETEAM] = 3;
            }
            gameProcess.DoCheatGameEnd(ETeam.BLUETEAM);
        }
    }*/
}
