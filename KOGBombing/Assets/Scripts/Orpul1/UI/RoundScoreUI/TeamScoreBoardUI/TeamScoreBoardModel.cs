using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using UnityEngine.SocialPlatforms.Impl;

public class TeamScoreBoardModel
{
    Action<ETeamScore> updateUI;
    Dictionary<ETeamScore, StringBuilder> dictScoreText = new Dictionary<ETeamScore, StringBuilder>();
    public Dictionary<ETeamScore, StringBuilder> ScoreText { get { return dictScoreText; } }
    int score = 0;
    public int Score { get { return score; } }
    public TeamScoreBoardModel(Action<ETeamScore> updateUI)
    {
        this.updateUI = updateUI;
        Initialize();
    }
    public void Initialize()
    {
        dictScoreText.Clear();
        score = 0;
        for (int i = 0; i < (int)ETeamScore.END; i++)
        {
            dictScoreText.Add((ETeamScore)i, new StringBuilder());
        }
    }
    public void SetScore(ETeamScore type, int score)
    {
        this.score = score;
        dictScoreText[type].Clear();
        dictScoreText[type].Append(this.score);
        updateUI(type);
    }
}
