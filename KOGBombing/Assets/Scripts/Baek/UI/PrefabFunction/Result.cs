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
    int[] teamScore = new int[2] { 0, 0 };
    int[] teamKillScore = new int[2] { 0, 0 };
    int[] teamDeathScore = new int[2] { 0, 0 };
    void Awake()
    {
        WinnerTeam myTeam = (WinnerTeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        type = GetWinTeam() == myTeam ? ResultType.Win : ResultType.Lose;
        for(int i = 0; i < (int)ResultType.Max; i++)
        {
            if(i==(int)type)
                resultText[i].gameObject.SetActive(true);
            else
                resultText[i].gameObject.SetActive(false);
        }
        GameObject resultAvatar = LocalManagers.Resource.Instantiate("UIPrefabs/Scene/PlayScene/EndGame/ResultAvatar");
        resultAvatar.GetComponent<ISetWinTypeable>().SetWinType((ResultTeam)type);
    }

    private WinnerTeam GetWinTeam()
    {
        if(Managers.RoundData.WinTeam == WinnerTeam.DRAW)
            return GetSameScoreWinTeam();
        return Managers.RoundData.WinTeam;
    }

    /// <summary>
    /// °ø°Ý ÆÀ ½Â¸®: 1,
    /// ¹æ¾î ÆÀ ½Â¸®: 0,
    /// µ¿Á¡: -1
    /// </summary>
    /// <returns>int</returns>
    private WinnerTeam GetSameScoreWinTeam()
    {
        int calcMissionScore = CalcMissionPoint();
        if(calcMissionScore == 1)
        {
            return WinnerTeam.REDTEAM;
        }
        else if(calcMissionScore == 0)
        {
            return WinnerTeam.BLUETEAM;
        }
        return CalcKillDeathScore();
    }
    private int CalcMissionPoint()
    {
        Player[] players = PhotonNetwork.PlayerList;
        
        for (int i = 0; i < players.Length; i++)
        {
            PlayerPointInfo pointInfo = Managers.PointData.GetPlayerInfo(players[i].NickName);
            if ((WinnerTeam)players[i].CustomProperties[EPropertyType.TEAM.ToString()] == WinnerTeam.REDTEAM)
            {
                teamScore[(int)WinnerTeam.REDTEAM] += pointInfo.MissionPoint;
                teamKillScore[(int)WinnerTeam.REDTEAM] += pointInfo.KillPoint;
                teamDeathScore[(int)WinnerTeam.REDTEAM] += pointInfo.DeathPoint;
            }
            else
            {
                teamScore[(int)WinnerTeam.BLUETEAM] += pointInfo.MissionPoint;
                teamKillScore[(int)WinnerTeam.BLUETEAM] += pointInfo.KillPoint;
                teamDeathScore[(int)WinnerTeam.BLUETEAM] += pointInfo.DeathPoint;
            }
        }
        int scoreResult = teamScore[(int)WinnerTeam.REDTEAM] - teamScore[(int)WinnerTeam.BLUETEAM];

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
    private WinnerTeam CalcKillDeathScore()
    {
        int redTeamScore = teamKillScore[(int)WinnerTeam.REDTEAM] / (teamDeathScore[(int)WinnerTeam.REDTEAM] + 1);
        int blueTeamScore = teamKillScore[(int)WinnerTeam.BLUETEAM] / (teamDeathScore[(int)WinnerTeam.BLUETEAM] + 1);
        if (redTeamScore > blueTeamScore)
            return WinnerTeam.REDTEAM;
        return WinnerTeam.BLUETEAM;
    }

    public void ReturnLobby()
    {
        PhotonNetwork.LeaveRoom();
        LocalManagers.PunData.Init();
        //Loading.LoadScene("LobbyScene");
        Managers.SceneLoad.LoadScene("LobbyScene");
    }
}
