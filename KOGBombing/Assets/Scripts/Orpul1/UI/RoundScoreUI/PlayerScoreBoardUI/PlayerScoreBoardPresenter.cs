using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class PlayerScoreBoardPresenter : MonoBehaviour, ISetScoreable<EPlayerScore>
{
    [SerializeField]
    PlayerScoreBoardView view;
    PlayerScoreBoardModel model;
    private void Awake()
    {
        model = new PlayerScoreBoardModel(UpdateUI);
    }

    public void SetTitle(StringBuilder nickname)
    {
        model.SetNickname(nickname.ToString());
    }
    public void UpdateUI(EPlayerScore type)
    {
        view.tmpScores[(int)type].text = model.scoreText[(int)type].ToString();
    }

    public void SetScore(EPlayerScore type, int score)
    {
        model.SetScore(type, model.playerScore[(int)type] + score);
    }

    public void ResetScore()
    {
        Destroy(gameObject);
    }
}
