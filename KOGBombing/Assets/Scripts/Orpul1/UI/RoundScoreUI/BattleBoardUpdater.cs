using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using UnityEngine.UI;

public class BattleBoardUpdater : MonoBehaviour, IUpdateScore, IHalfRoundUISetable
{
    [SerializeField]
    Image[] teamPanels = new Image[2];
    [SerializeField]
    Transform[] playerScoreParent;
    [SerializeField]
    GameObject playerScorePrefab;

    [SerializeField]
    GameObject[] teamScorePanels = new GameObject[2];

    Dictionary<string, ISetScoreable<EPlayerScore>> dicPlayerScore = new Dictionary<string, ISetScoreable<EPlayerScore>>();
    Dictionary<ETeam, ISetScoreable<ETeamScore>> dicTeamScore = new Dictionary<ETeam, ISetScoreable<ETeamScore>>();
    List<StringBuilder> playerNicknameList;

    [SerializeField] Sprite[] halfRoundImages;
    [SerializeField] Image[] displayHalfRoundImages;
    void Awake()
    {
        SetTeamScore();
        SetPlayerScore();
        /*UpdatePlayerScore();
        UpdateTeamScore();*/
    }
    void OnEnable()
    { 
        LoadTeamPanelIcon();
    }
    private void SetPlayersMapping()
    {
        int playerCount = PhotonNetwork.CurrentRoom.PlayerCount;
        playerNicknameList = new List<StringBuilder>(playerCount);

    }
    ETeam LoadTeamPanelIcon()
    {
        ETeam mine = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        string teamPanel = mine == ETeam.REDTEAM ? "Red" : "Blue";
        string otherTeamPanel = mine == ETeam.REDTEAM ? "Blue" : "Red";
        teamPanels[0].sprite = Managers.Resource.Load<Sprite>("UISettings/BattleBoard_Popup/BattleBoard_UI_" + teamPanel + "_BG");
        teamPanels[1].sprite = Managers.Resource.Load<Sprite>("UISettings/BattleBoard_Popup/BattleBoard_UI_" + otherTeamPanel + "_BG");
        return mine;
    }
    private void SetPlayerScore()
    {
        ETeam mine = LoadTeamPanelIcon();
        ISetScoreable<EPlayerScore> myPlayerScoreUI = Instantiate(playerScorePrefab, playerScoreParent[0])
                                                        .GetComponent<ISetScoreable<EPlayerScore>>();
        myPlayerScoreUI.SetTitle(new StringBuilder(PhotonNetwork.LocalPlayer.NickName));
        dicPlayerScore.Add(PhotonNetwork.LocalPlayer.NickName, myPlayerScoreUI);

        


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
            playerScoreUI.SetTitle(new StringBuilder(players.ElementAt(i).Value.NickName));
            dicPlayerScore.Add(players.ElementAt(i).Value.NickName, playerScoreUI);
        }
    }

    private void SetTeamScore()
    {
        for (int i = 0; i < teamScorePanels.Length; i++) 
        {
            ISetScoreable<ETeamScore> teamScoreUI = teamScorePanels[i].GetComponent<ISetScoreable<ETeamScore>>();
            dicTeamScore.Add((ETeam)i, teamScoreUI);
        }
    }

    public void UpdatePlayerScore(StringBuilder nickname, EPlayerScore updateType)
    {
        Debug.Log($"{updateType.ToString()} event! key is {nickname.ToString()}");
        if (!dicPlayerScore.ContainsKey(nickname.ToString()))
        {
            return;
        }
        dicPlayerScore[nickname.ToString()].SetScore(updateType, 1);
    }

    public void UpdateTeamScore(ETeam team, ETeamScore updateType)
    {
        dicTeamScore[team].SetScore(updateType, 1);
    }

    public void SetHalfRound(ERoundState state)
    {
        displayHalfRoundImages[0].sprite = halfRoundImages[(int)state];
        displayHalfRoundImages[1].sprite = halfRoundImages[(int)state];
    }
}
