using System.Collections;
using System.Collections.Generic;
using System.Text;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using UnityEngine.UI;

public class BattleBoardUpdater : MonoBehaviour, IUpdateScore, IHalfRoundUISetable
{
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
    private void SetPlayersMapping()
    {
        int playerCount = PhotonNetwork.CurrentRoom.PlayerCount;
        playerNicknameList = new List<StringBuilder>(playerCount);

    }
    private void SetPlayerScore()
    {
        Player[] players = PhotonNetwork.PlayerList;
        Debug.Log($"SetPlayerScore {players.Length} ");
        for (int i = 0; i < players.Length; i++) 
        {
            int index = (int)players[i].CustomProperties["TeamIndex"];
            ETeam team = (ETeam)players[i].CustomProperties["Team"];
            ISetScoreable<EPlayerScore> playerScoreUI = Instantiate(playerScorePrefab, playerScoreParent[(int)team])
                                                        .GetComponent<ISetScoreable<EPlayerScore>>();
            playerScoreUI.SetTitle(new StringBuilder(players[i].NickName));
            dicPlayerScore.Add(players[i].NickName, playerScoreUI);
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
