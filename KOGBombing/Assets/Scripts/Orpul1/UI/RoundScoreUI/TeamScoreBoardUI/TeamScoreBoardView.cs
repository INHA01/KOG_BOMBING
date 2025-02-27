using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class TeamScoreBoardView : MonoBehaviour
{
    public TextMeshProUGUI tmpTeamScoreKill;
    public TextMeshProUGUI tmpTeamScoreWin;
    public TextMeshProUGUI tmpTeamScoreMission;
    TextMeshProUGUI[] tmpScores { get { return new TextMeshProUGUI[] { tmpTeamScoreKill, tmpTeamScoreWin, tmpTeamScoreMission }; } }
    Dictionary<ETeamScore, TextMeshProUGUI> dicTeamText = new Dictionary<ETeamScore, TextMeshProUGUI>();
    public Dictionary<ETeamScore, TextMeshProUGUI> TeamTextUI { get { return dicTeamText; } }
    private void Awake()
    {
        for(int i=(int)ETeamScore.KILLSCORE; i< (int)ETeamScore.END; i++)
        {
            dicTeamText.Add((ETeamScore)i, tmpScores[i]);
        }
    }
}

