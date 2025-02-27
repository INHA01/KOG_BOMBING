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
        view.Texts[type].text = model.TextValues[type].ToString();
    }

    public void SetScore(EPlayerScore type, int score)
    {
        model.SetScore(type, model.PlayerScore[type] + score);
    }

}
