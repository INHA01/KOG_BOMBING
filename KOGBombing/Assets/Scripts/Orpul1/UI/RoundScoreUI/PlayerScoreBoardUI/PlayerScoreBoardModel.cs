using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Photon.Pun.UtilityScripts;
using Unity.VisualScripting;
using UnityEngine;

public class PlayerScoreBoardModel 
{
    Action<EPlayerScore> updateUI;
    Dictionary<EPlayerScore, StringBuilder> dicScoreText = new Dictionary<EPlayerScore, StringBuilder>();
    public Dictionary<EPlayerScore, StringBuilder> TextValues { get { return dicScoreText; } }
    int score = 0;
    public int Score { get { return score; } }
    public PlayerScoreBoardModel(Action<EPlayerScore> updateUI)
    {
        this.updateUI = updateUI;
        for (int i = 0; i < (int)EPlayerScore.END; i++)
        {
            dicScoreText.Add((EPlayerScore)i, new StringBuilder());
        }
    }
    public void SetNickname(string nickname)
    {
        TextValues[EPlayerScore.NICKNAME].Clear();
        TextValues[EPlayerScore.NICKNAME].Append(nickname);
        updateUI(EPlayerScore.NICKNAME);
    }
    public void SetScore(EPlayerScore type, int score)
    {
        this.score = score;
        dicScoreText[type].Clear();
        dicScoreText[type].Append(this.score);
        updateUI(type);
    }
    
}
