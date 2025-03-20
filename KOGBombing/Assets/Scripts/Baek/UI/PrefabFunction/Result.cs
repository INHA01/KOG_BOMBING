using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;

public enum ResultType
{
    Win,
    Lose,
    Max
}
public class Result : MonoBehaviour
{
    enum ButtonPos
    {
        Left,
        Right,
        Max
    }
    enum ResultButton
    {
        MoveMVP,
        MoveLobby,
        MoveTeamRecord,
        MoveResult,
        Max
    }
    [SerializeField] Transform[] buttonPos = new Transform[(int)ButtonPos.Max];
    [SerializeField] GameObject[] resultButton = new GameObject[(int)ResultButton.Max];
    [Header("MVP")]
    [SerializeField] GameObject[] resultText = new GameObject[2];
    ResultType type;
    int[] teamScore = new int[2] { 0, 0 };
    int[] teamKillScore = new int[2] { 0, 0 };
    int[] teamDeathScore = new int[2] { 0, 0 };
    [Header("Record")]
    [SerializeField] GameObject resultRecord;
    [SerializeField] TextMeshProUGUI[] levelText = new TextMeshProUGUI[2];
    [SerializeField] Image recordBar;
    Coroutine fillBar;
    bool isFillFinish = false;
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
        GameObject resultAvatar = Managers.Resource.Instantiate("UIPrefabs/Scene/PlayScene/EndGame/ResultAvatar");
        resultAvatar.GetComponent<ISetWinTypeable>().SetWinType((ResultTeam)type);
    }

    private WinnerTeam GetWinTeam()
    {
        if(Managers.RoundData.WinTeam == WinnerTeam.DRAW)
            return GetSameScoreWinTeam();
        return Managers.RoundData.WinTeam;
    }

    /// <summary>
    /// 공격 팀 승리: 1,
    /// 방어 팀 승리: 0,
    /// 동점: -1
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
    public void OpenMVP()
    {
        if (fillBar != null) return;
        // 왼쪽 : 없음 , 오른쪽 : 팀기록
        resultButton[(int)ResultButton.MoveMVP].SetActive(false);
        resultButton[(int)ResultButton.MoveTeamRecord].transform.SetParent(buttonPos[(int)ButtonPos.Right]);
        resultButton[(int)ResultButton.MoveTeamRecord].transform.localPosition = Vector3.zero;
        resultButton[(int)ResultButton.MoveTeamRecord].SetActive(true);
        resultButton[(int)ResultButton.MoveResult].SetActive(false);
        Managers.UI.ClosePopupUI(BAEK.UIKEY.BattleBoard);
    }
    public void OpenTeamRecord()
    {
        if (fillBar != null) return;
        Managers.UI.ShowPopupUI<BattleBoardUpdater>(BAEK.UIKEY.BattleBoard);
        resultRecord.SetActive(false);
        // 왼쪽 : MVP , 오른쪽 : 결과창
        resultButton[(int)ResultButton.MoveMVP].SetActive(true);
        resultButton[(int)ResultButton.MoveResult].SetActive(true);
        resultButton[(int)ResultButton.MoveTeamRecord].SetActive(false);
    }
    public void OpenResult()
    {
        Managers.UI.ClosePopupUI(BAEK.UIKEY.BattleBoard);
        resultRecord.SetActive(true);
        // 왼쪽 : 팀기록 , 오른쪽 : 로비
        resultButton[(int)ResultButton.MoveMVP].SetActive(false);
        resultButton[(int)ResultButton.MoveTeamRecord].transform.SetParent(buttonPos[(int)ButtonPos.Left]);
        resultButton[(int)ResultButton.MoveTeamRecord].transform.localPosition = Vector3.zero;
        resultButton[(int)ResultButton.MoveTeamRecord].SetActive(true);
        resultButton[(int)ResultButton.MoveLobby].SetActive(true);
        resultButton[(int)ResultButton.MoveResult].SetActive(false);
        if(fillBar == null && !isFillFinish)
        {
            fillBar = StartCoroutine(FillBar());
        }
    }
    IEnumerator FillBar()
    { 
        // 이기면 경험치 500, 지면 200
        // 경험치 총량은 level * 300
        int level = Managers.UserData.userData.level;
        int nextLevel = level + 1;
        levelText[0].text = level.ToString();
        levelText[1].text = nextLevel.ToString();
        float currentExp = Managers.UserData.userData.exp;
        float maxExp = level * 300;
        float increaseExp = type == ResultType.Win ? 500 : 200;
        float amount = 0;
        while (amount < increaseExp)
        {
            currentExp += 1;
            amount += 1;
            recordBar.fillAmount = currentExp / maxExp;
            if(currentExp >= maxExp)
            {
                level++;
                nextLevel++;
                currentExp = 0;
                maxExp = level * 300;
                levelText[0].text = level.ToString();
                levelText[1].text = nextLevel.ToString();
            }
            yield return new WaitForSeconds(0.01f);
        }
        Managers.UserData.userData.exp = currentExp;
        Managers.UserData.userData.level = level;
        Managers.UserData.SaveUserData();
        isFillFinish = true;
        yield return new WaitForSeconds(2f);
        fillBar = null;
    }
    public void ReturnLobby()
    {
        if (fillBar != null) return;
        InitScreen();
        PhotonNetwork.LeaveRoom();
        Managers.PunData.Init();
        Managers.UI.GetPopupUI<BattleBoardUpdater>(BAEK.UIKEY.BattleBoard).ResetPlayerScore();
        Managers.SceneLoad.LoadScene("LobbyScene");
    }
    void InitScreen()
    {
        resultButton[(int)ResultButton.MoveTeamRecord].transform.SetParent(buttonPos[(int)ButtonPos.Right]);
        resultButton[(int)ResultButton.MoveTeamRecord].transform.localPosition = Vector3.zero;
        resultButton[(int)ResultButton.MoveTeamRecord].SetActive(true);
        resultButton[(int)ResultButton.MoveResult].SetActive(false);
        resultButton[(int)ResultButton.MoveMVP].SetActive(false);
        resultRecord.SetActive(false);
    }
}
