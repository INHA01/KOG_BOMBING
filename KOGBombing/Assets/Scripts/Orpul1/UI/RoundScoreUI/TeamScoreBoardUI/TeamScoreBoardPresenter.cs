using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class TeamScoreBoardPresenter : MonoBehaviour, ISetScoreable<ETeamScore>
{
    [SerializeField]
    TeamScoreBoardView view;
    TeamScoreBoardModel model;
 
    public void Initialize()
    {
        model = new TeamScoreBoardModel(UpdateUI);
        model.Initialize();
        for(int i=0; i<(int)ETeamScore.END; i++)
        {
            model.SetScore((ETeamScore)i, 0);
        }
    }
    public void SetTitle(StringBuilder title) { }

    public void SetScore(ETeamScore type, int score)
    {
        model.SetScore(type, model.Score + score);
    }

    public void UpdateUI(ETeamScore type)
    {
        view.TeamTextUI[type].text = model.ScoreText[type].ToString();
    }

    public void ResetScore()
    {
        Destroy(gameObject);
    }
}
