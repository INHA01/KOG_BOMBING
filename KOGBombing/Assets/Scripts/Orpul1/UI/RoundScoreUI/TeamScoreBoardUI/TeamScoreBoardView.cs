using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class TeamScoreBoardView : MonoBehaviour
{
    public TextMeshProUGUI tmpHalfRound;
    public TextMeshProUGUI tmpTeamScoreKill;
    public TextMeshProUGUI tmpTeamScoreWin;
    public TextMeshProUGUI tmpTeamScoreMission;
    TextMeshProUGUI[] tmpScores { get { return new TextMeshProUGUI[] { tmpHalfRound, tmpTeamScoreKill, tmpTeamScoreWin, tmpTeamScoreMission }; } }
    Dictionary<ETeamScore, TextMeshProUGUI> dicTeamText;
    public Dictionary<ETeamScore, TextMeshProUGUI> TeamTextUI { get { return dicTeamText; } }
    private void Start()
    {
        for(int i=0; i< (int)ETeamScore.END; i++)
        {
            dicTeamText.Add((ETeamScore)i, tmpScores[i]);
        }
    }
}

