using Orpul1;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Photon.Pun;
using UnityEngine.UI;
public class Winner : MonoBehaviour
{
    [SerializeField] GameObject activeResultButton;
    public void SetWiner(int end)
    {
        if(end == 0)
        {
            ETeam winTeam = Managers.RoundData.RoundWinTeam;
            if(winTeam == ETeam.REDTEAM)
            {
                // red team win
            }
            else
            {
                // blue team win
            }
        }
        else
        {
            if(Managers.RoundData.WinTeam > 0)
            {
                // red team win
            }
            else
            {
                // blue team win
            }
        }
        activeResultButton.SetActive(end == 1);
    }
    public void OpenResult()
    {
        LocalManagers.UI.ShowPopupUI<UIPopup>("ResultCanvas");
        LocalManagers.UI.ClosePopupUI("WinnerCanvas");
    }
}
