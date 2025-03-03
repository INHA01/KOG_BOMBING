using Orpul1;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Photon.Pun;
using UnityEngine.UI;
public class Winner : MonoBehaviour
{
    [SerializeField] Image winner;
    [SerializeField] GameObject activeResultButton;
    int redTeamCnt = -1;
    int blueTeamCnt = -1;
    public void SetWiner(int end)
    {
        if(end == 0)
        {
            
            if(Managers.RoundData.RoundWinTeam == ETeam.REDTEAM)
            {
                redTeamCnt = Managers.RoundData.TeamScore[(int)ETeam.REDTEAM];
                winner.sprite = Resources.Load<Sprite>("UISettings/End/End_UI_RedWin_BG");
            }
            else if(Managers.RoundData.RoundWinTeam == ETeam.BLUETEAM)
            {
                blueTeamCnt = Managers.RoundData.TeamScore[(int)ETeam.BLUETEAM];
                winner.sprite = Resources.Load<Sprite>("UISettings/End/End_UI_BlueWin_BG");
            }
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
