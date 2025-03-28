using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using BAEK;

public class BattleBoardUpdater : UIPopup, IUpdateScore, IHalfRoundUISetable
{
    enum TeamScore
    {
        Kill,
        WinRound,
        MissionPoint,
        Max,
    }
    [SerializeField]
    Image[] teamPanels = new Image[2];
    [SerializeField]
    Transform[] playerScoreParent;
    [SerializeField]
    GameObject playerScorePrefab;

    [SerializeField]
    GameObject[] teamScorePanels = new GameObject[2];

    Dictionary<string, ISetScoreable<EPlayerScore>> dictPlayerScore = new Dictionary<string, ISetScoreable<EPlayerScore>>();
    Dictionary<ETeam, ISetScoreable<ETeamScore>> dicTeamScore = new Dictionary<ETeam, ISetScoreable<ETeamScore>>();
    List<StringBuilder> playerNicknameList;

    [SerializeField] Sprite[] halfRoundImages;
    [SerializeField] Image[] displayHalfRoundImages;
    bool isAlreadyReset = false;
    void OnEnable()
    { 
        LoadTeamPanelIcon();
    }
    public void Initialize()
    {
        SetTeamScore();
        SetPlayerScore();
    }
    private void SetPlayersMapping()
    {
        int playerCount = PhotonNetwork.CurrentRoom.PlayerCount;
        playerNicknameList = new List<StringBuilder>(playerCount);

    }
    ETeam LoadTeamPanelIcon()
    {
        ETeam mine = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        PlayUI teamPanel = mine == ETeam.REDTEAM ? PlayUI.BattleBoardRed : PlayUI.BattleBoardBlue;
        PlayUI otherTeamPanel = mine == ETeam.REDTEAM ? PlayUI.BattleBoardBlue : PlayUI.BattleBoardRed;
        teamPanels[0].sprite = Managers.Resource.LoadImg(ImgLoaderType.Play, (int)teamPanel);
        teamPanels[1].sprite = Managers.Resource.LoadImg(ImgLoaderType.Play, (int)otherTeamPanel);
        return mine;
    }
    private void SetPlayerScore()
    {
        ETeam mine = LoadTeamPanelIcon();
        ISetScoreable<EPlayerScore> myPlayerScoreUI = Instantiate(playerScorePrefab, playerScoreParent[0])
                                                        .GetComponent<ISetScoreable<EPlayerScore>>();
        myPlayerScoreUI.Initialize();
        myPlayerScoreUI.SetTitle(new StringBuilder(PhotonNetwork.LocalPlayer.NickName));
        dictPlayerScore.Add(PhotonNetwork.LocalPlayer.NickName, myPlayerScoreUI);

        Dictionary<string , Player> players = new Dictionary<string, Player>();
        foreach (Player player in PhotonNetwork.PlayerListOthers)
        {
            players.Add(player.NickName, player);
        }
        
        for (int i = 0; i < players.Count; i++) 
        {
            //순서대로 탐색
            ETeam team = (ETeam)players.ElementAt(i).Value.CustomProperties[EPropertyType.TEAM.ToString()];
            int parentIndex = team == mine ? 0 : 1;
            ISetScoreable<EPlayerScore> playerScoreUI = Instantiate(playerScorePrefab, playerScoreParent[parentIndex])
                                                        .GetComponent<ISetScoreable<EPlayerScore>>();
            playerScoreUI.Initialize();
            playerScoreUI.SetTitle(new StringBuilder(players.ElementAt(i).Value.NickName));
            dictPlayerScore.Add(players.ElementAt(i).Value.NickName, playerScoreUI);
        }
    }
    public void ResetScore()
    {
        for (int i = 0; i < dictPlayerScore.Count; i++)
        {
            ISetScoreable<EPlayerScore> score = dictPlayerScore.ElementAt(i).Value;
            score.ResetScore();
        }
        for (int i = 0; i < dicTeamScore.Count; i++) 
        {
            ISetScoreable<ETeamScore> teamScore = dicTeamScore.ElementAt(i).Value;
            teamScore.Initialize();
        }
        dictPlayerScore.Clear();
        dicTeamScore.Clear();
        isAlreadyReset = false;
    }

    private void SetTeamScore()
    {
        ETeam mTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        ETeam otherTeam = ETeam.BLUETEAM - (int)mTeam;
        int[] teamIndex = new int[] { (int)mTeam, (int)otherTeam };
        for (int i = 0; i < (int)ETeam.END; i++)
        {
            ISetScoreable<ETeamScore> teamScoreUI = teamScorePanels[i].GetComponent<ISetScoreable<ETeamScore>>();
            teamScoreUI.Initialize();
            dicTeamScore.Add((ETeam)teamIndex[i], teamScoreUI);
        }
        
    }

    public void UpdatePlayerScore(StringBuilder nickname, EPlayerScore updateType , int score)
    {
        if (!dictPlayerScore.ContainsKey(nickname.ToString())) return;
        
        dictPlayerScore[nickname.ToString()].SetScore(updateType, score);
        List<string> myTeamList = Managers.PointData.MyTeamPlayers;
        List<string> otherTeamList = Managers.PointData.OtherTeamPlayers;
        
        int myK = 0;
        int myM = 0;
        
        int otherK = 0;
        int otherM = 0;
        
        for (int i=0; i< myTeamList.Count; i++)
        {
            PlayerPointInfo point = Managers.PointData.GetPlayerInfo(myTeamList[i]);
            myK += point.KillPoint;
            myM += point.MissionPoint;
        }
        for (int i = 0; i < otherTeamList.Count; i++) 
        {
            PlayerPointInfo point = Managers.PointData.GetPlayerInfo(otherTeamList[i]);
            otherK += point.KillPoint;
            otherM += point.MissionPoint;

        }

        teamScorePanels[0].transform.GetChild((int)TeamScore.Kill).GetComponent<TextMeshProUGUI>().text = myK.ToString();
        teamScorePanels[0].transform.GetChild((int)TeamScore.MissionPoint).GetComponent<TextMeshProUGUI>().text = myM.ToString();
        teamScorePanels[1].transform.GetChild((int)TeamScore.Kill).GetComponent<TextMeshProUGUI>().text = otherK.ToString();
        teamScorePanels[1].transform.GetChild((int)TeamScore.MissionPoint).GetComponent<TextMeshProUGUI>().text = otherM.ToString();
    }
    public void UpdateTeamWinScore()
    {
        ETeam myTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        ETeam otherTeam = 1 - myTeam;
        int myW = Managers.RoundData.TeamScore[(int)myTeam];
        int otherW = Managers.RoundData.TeamScore[(int)otherTeam];
        teamScorePanels[0].transform.GetChild((int)TeamScore.WinRound).GetComponent<TextMeshProUGUI>().text = myW.ToString();
        teamScorePanels[1].transform.GetChild((int)TeamScore.WinRound).GetComponent<TextMeshProUGUI>().text = otherW.ToString();
    }
    public void UpdateMissionPoint()
    { 
    }
    public void UpdateTeamScore(ETeam team, ETeamScore updateType, int score)
    {
        Debug.Log($"UpdateBattleBoard {updateType.ToString()}");
        dicTeamScore[team].SetScore(updateType, score);
    }

    public void SetHalfRound(ERoundState state)
    {
        displayHalfRoundImages[0].sprite = halfRoundImages[(int)state];
        displayHalfRoundImages[1].sprite = halfRoundImages[(int)state];
    }

    public void SwapTeamUIScore()
    {
        ISetScoreable<ETeamScore> redTeamTmp = dicTeamScore[(int)ETeam.REDTEAM];
        dicTeamScore[(int)ETeam.REDTEAM] = dicTeamScore[ETeam.BLUETEAM];
        dicTeamScore[ETeam.BLUETEAM] = redTeamTmp;
    }
}
