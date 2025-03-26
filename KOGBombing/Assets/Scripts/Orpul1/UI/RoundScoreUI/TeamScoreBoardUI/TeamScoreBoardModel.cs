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
    List<int> scoreList = new List<int>();
    public TeamScoreBoardModel(Action<ETeamScore> updateUI)
    {
        this.updateUI = updateUI;
        scoreList.Clear();
        for (int i = 0; i < (int)ETeamScore.END; i++)
            scoreList.Add(0);
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
        scoreList[(int)type] += score;
        dictScoreText[type].Clear();
        dictScoreText[type].Append(this.scoreList[(int)type]);
        updateUI(type);
    }
}
