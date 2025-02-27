using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class TeamScoreBoardPresenter : MonoBehaviour, ISetScoreable<ETeamScore>
{
    [SerializeField]
    TeamScoreBoardView view;
    TeamScoreBoardModel model;


    private void Start()
    {
        model = new TeamScoreBoardModel(UpdateUI);
    }
    public void SetTitle(StringBuilder title)
    {
        model.SetTeamTitle(title);
    }

    public void SetScore(ETeamScore type, int score)
    {
        model.SetScore(type, model.Score);
    }

    public void UpdateUI(ETeamScore type)
    {
        view.TeamTextUI[type].text = model.ScoreText[type].ToString();
    }

}
