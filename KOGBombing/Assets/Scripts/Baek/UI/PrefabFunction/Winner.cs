using Orpul1;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Photon.Pun;
using UnityEngine.UI;
public class Winner : MonoBehaviour
{
    string[] winUIPath = new string[2]
    {
        "UISettings/End/End_UI_RedWin_BG",
        "UISettings/End/End_UI_BlueWin_BG"
    };
    [SerializeField] Image winner;
    [SerializeField] GameObject activeResultButton;
    int redTeamCnt = -1;
    int blueTeamCnt = -1;
    public void SetWiner(int end)
    {
        if(end == 0)
        {
            ETeam winTeam = Managers.RoundData.RoundWinTeam;
            winner.sprite = Resources.Load<Sprite>(winUIPath[(int)winTeam]);
        }
        else
        {
            if(Managers.RoundData.WinTeam > 0)
            {
                winner.sprite = Resources.Load<Sprite>("UISettings/End/End_UI_RedWin_BG");
            }
            else
            {
                winner.sprite = Resources.Load<Sprite>("UISettings/End/End_UI_BlueWin_BG");
            }
        }
        activeResultButton.SetActive(end == 1);
    }
    public void OpenResult()
    {
        Managers.UI.ShowPopupUI<UIPopup>("ResultCanvas");
        Managers.UI.ClosePopupUI("WinnerCanvas");
    }
}
