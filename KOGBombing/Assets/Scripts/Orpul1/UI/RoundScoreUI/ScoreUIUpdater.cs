using System.Collections;
using System.Collections.Generic;
using System.Text;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

public class ScoreUIUpdater : MonoBehaviour, IUpdateScore
{
    [SerializeField]
    Transform playerScoreParent;
    [SerializeField]
    GameObject playerScorePrefab;

    [SerializeField]
    GameObject[] teamScorePanels = new GameObject[2];

    Dictionary<string, ISetScoreable<EPlayerScore>> dicPlayerScore = new Dictionary<string, ISetScoreable<EPlayerScore>>();
    Dictionary<ETeam, ISetScoreable<ETeamScore>> dicTeamScore = new Dictionary<ETeam, ISetScoreable<ETeamScore>>();
    List<StringBuilder> playerNicknameList;

    void Start()
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
        for (int i = 0; i < players.Length; i++) 
        {
            int index = (int)players[i].CustomProperties["TeamIndex"];
            ISetScoreable<EPlayerScore> playerScoreUI = Instantiate(playerScorePrefab).GetComponent<ISetScoreable<EPlayerScore>>();
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
        dicPlayerScore[nickname.ToString()].SetScore(updateType, 1);
    }

    public void UpdateTeamScore(ETeam team, ETeamScore updateType)
    {
        dicTeamScore[team].SetScore(updateType, 1);
    }
}
