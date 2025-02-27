using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using UnityEngine.SocialPlatforms.Impl;

public class TeamScoreBoardModel : MonoBehaviour
{
    Action<ETeamScore> updateUI;
    Dictionary<ETeamScore, StringBuilder> dicScoreText = new Dictionary<ETeamScore, StringBuilder>();
    public Dictionary<ETeamScore, StringBuilder> ScoreText { get { return dicScoreText; } }
    int score = 0;
    public int Score { get { return score; } }
    public TeamScoreBoardModel(Action<ETeamScore> updateUI)
    {
        this.updateUI = updateUI;
        for(int i=0; i< (int)ETeamScore.END; i++)
        {
            dicScoreText.Add((ETeamScore)i, new StringBuilder());
        }
    }
    public void SetTeamTitle(StringBuilder title)
    {
        dicScoreText[ETeamScore.HALFROUND].Clear();
        dicScoreText[ETeamScore.HALFROUND].Append(title);
        updateUI(ETeamScore.HALFROUND);
    }
    public void SetScore(ETeamScore type, int score)
    {
        this.score = score;
        dicScoreText[type].Clear();
        dicScoreText[type].Append(this.score);
        updateUI(type);
    }
}
