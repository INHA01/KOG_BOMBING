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
        ETeam myTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        type = GetWinTeam() == myTeam ? ResultType.Win : ResultType.Lose;
        for(int i = 0; i < (int)ResultType.Max; i++)
        {
            if(i==(int)type)
                resultText[i].gameObject.SetActive(true);
            else
                resultText[i].gameObject.SetActive(false);
        }
        GameObject resultAvatar = Managers.Resource.Instantiate("UIPrefabs/Scene/PlayScene/EndGame/ResultAvatar");
        resultAvatar.GetComponent<ISetWinTypeable>().SetWinType((ResultTeam)type);
    }

    private ETeam GetWinTeam()
    {
        int winResult = Managers.RoundData.WinTeam;
        switch(winResult)
        {
            case 1:
                return ETeam.REDTEAM;
                
            case -1:
                return ETeam.BLUETEAM;
        }
        return GetSameScoreWinTeam();
    }

    /// <summary>
    /// °ø°Ý ÆÀ ½Â¸®: 1,
    /// ¹æ¾î ÆÀ ½Â¸®: 0,
    /// µ¿Á¡: -1
    /// </summary>
    /// <returns>int</returns>
    private ETeam GetSameScoreWinTeam()
    {
        int calcMissionScore = CalcMissionPoint();
        if(calcMissionScore == 1)
        {
            return ETeam.REDTEAM;
        }
        else if(calcMissionScore == 0)
        {
            return ETeam.BLUETEAM;
        }
        return CalcKillDeathScore();
    }
    private int CalcMissionPoint()
    {
        Player[] players = PhotonNetwork.PlayerList;
        
        for (int i = 0; i < players.Length; i++)
        {
            PlayerPointInfo pointInfo = Managers.PointData.GetPlayerInfo(players[i].NickName);
            if ((ETeam)players[i].CustomProperties[EPropertyType.TEAM.ToString()] == ETeam.REDTEAM)
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
    private ETeam CalcKillDeathScore()
    {
        int redTeamScore = teamKillScore[(int)ETeam.REDTEAM] / (teamDeathScore[(int)ETeam.REDTEAM] + 1);
        int blueTeamScore = teamKillScore[(int)ETeam.BLUETEAM] / (teamDeathScore[(int)ETeam.BLUETEAM] + 1);
        if (redTeamScore > blueTeamScore)
            return ETeam.REDTEAM;
        return ETeam.BLUETEAM;
    }

    public void ReturnLobby()
    {
        Managers.UI.DestroyAllPopupUI();
        PhotonNetwork.LeaveRoom();
        Managers.PunData.Init();
        LoadingSceneManager.LoadScene("LobbyScene");
    }
}
