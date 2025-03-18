using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Unity.Collections.LowLevel.Unsafe;

public class PlayerScoreBoardModel 
{
    Action<EPlayerScore> updateUI;
    public List<StringBuilder> scoreText = new List<StringBuilder>();
    public List<int> playerScore = new List<int>();
    int score = 0;
    public int Score { get { return score; } }
    public PlayerScoreBoardModel(Action<EPlayerScore> updateUI)
    {
        this.updateUI = updateUI;
        playerScore.Clear();
        scoreText.Clear();
        for (int i = 0; i < (int)EPlayerScore.END; i++)
        {
            scoreText.Add(new StringBuilder());
            playerScore.Add(0);
        }
    }
    public void SetNickname(string nickname)
    {
        scoreText[(int)EPlayerScore.NICKNAME].Clear();
        scoreText[(int)EPlayerScore.NICKNAME].Append(nickname);
        updateUI(EPlayerScore.NICKNAME);
    }
    public void SetScore(EPlayerScore type, int score)
    {
        playerScore[(int)type] = score;
        scoreText[(int)type].Clear();
        scoreText[(int)type].Append(playerScore[(int)type]);
        updateUI(type);
    }
    
}
