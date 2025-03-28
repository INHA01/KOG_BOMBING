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
    public TeamScoreBoardModel(Action<ETeamScore> updateUI)
    {
        this.updateUI = updateUI;
        Initialize();
    }
    public void Initialize()
    {
        dictScoreText.Clear();
        for (int i = 0; i < (int)ETeamScore.END; i++)
        {
            dictScoreText.Add((ETeamScore)i, new StringBuilder());
        }
    }
    public void SetScore(ETeamScore type, int score)
    {
        dictScoreText[type].Clear();
        dictScoreText[type].Append(score.ToString());
        updateUI(type);
    }
}
