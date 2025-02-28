using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public enum ResultType
{
    Win,
    Lose,
    Max
}
public class Result : MonoBehaviour
{
    [SerializeField] GameObject[] resultText = new GameObject[2];
    ResultType type;
    void Awake()
    {
        for(int i = 0; i < (int)ResultType.Max; i++)
        {
            if(i==(int)type)
                resultText[i].gameObject.SetActive(true);
            else
                resultText[i].gameObject.SetActive(false);
        }
        Managers.Resource.Instantiate("UIPrefabs/Scene/PlayScene/EndGame/ResultAvatar");
    }

    private bool IsWin()
    {
        ETeam myTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"];
        if (Managers.RoundData.WinTeam != myTeam) return false;
        if(isSameScore())
        {
            GetSameScoreWinTeam();
        }
        return true;
    }
    private bool isSameScore()
    {
        int redTeamScore = Managers.RoundData.TeamScore[(int)ETeam.REDTEAM];
        int blueTeamScore = Managers.RoundData.TeamScore[(int)ETeam.BLUETEAM];
        if (redTeamScore != blueTeamScore) return false;
        return true;
    }
    private ETeam GetSameScoreWinTeam()
    {
        int calcResult = CalcMissionPoint();
        if(calcResult == 1)
        {
            return ETeam.REDTEAM;
        }
        else if(calcResult == 0)
        {
            return ETeam.BLUETEAM;
        }
        return ETeam.REDTEAM;
    }
    private int CalcMissionPoint()
    {
        Player[] players = PhotonNetwork.PlayerList;
        int[] teamScore = new int[2] { 0, 0 };
        int[] teamKillScore = new int[2] { 0, 0 };
        int[] teamDeathScore = new int[2] { 0, 0 };
        for (int i = 0; i < players.Length; i++)
        {
            PlayerPointInfo pointInfo = Managers.PointData.GetPlayerInfo(players[i].NickName);
            if ((ETeam)players[i].CustomProperties["Team"] == ETeam.REDTEAM)
            {
                teamScore[(int)ETeam.REDTEAM] += pointInfo.MissionPoint;
                teamKillScore[(int)ETeam.REDTEAM] += pointInfo.KillPoint;
                teamDeathScore[(int)ETeam.REDTEAM] += pointInfo.DeathPoint;
            }
            else
            {
                teamScore[(int)ETeam.BLUETEAM] += pointInfo.MissionPoint;
                teamKillScore[(int)ETeam.BLUETEAM] += pointInfo.KillPoint;
                teamDeathScore[(int)ETeam.BLUETEAM] += pointInfo.DeathPoint;
            }
        }
        int scoreResult = teamScore[(int)ETeam.REDTEAM] - teamScore[(int)ETeam.BLUETEAM];
        if (scoreResult > 0)
        {
            return 1;
        }
        else if (scoreResult < 0)
        {
            return 0;
        }
        return -1;
    }

    public void ReturnLobby()
    {
        Managers.UI.DestroyAllPopupUI();
        PhotonNetwork.LeaveRoom();
        Managers.PunData.Init();
        LoadingSceneManager.LoadScene("LobbyScene");
    }
}
