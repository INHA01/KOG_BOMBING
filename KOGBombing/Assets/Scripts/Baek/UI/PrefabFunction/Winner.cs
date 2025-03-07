using Orpul1;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Photon.Pun;
using UnityEngine.UI;
public class Winner : UIPopup
{
    [SerializeField] GameObject activeResultButton;
    [SerializeField] Animator animator;
    public void SetWiner(int end)
    {
        WinnerTeam winTeam = Managers.RoundData.RoundWinTeam;
        if(end == 0)
            winTeam = Managers.RoundData.RoundWinTeam;
        else
            winTeam = Managers.RoundData.WinTeam;
        animator.SetInteger("winner", (int)winTeam);
        activeResultButton.SetActive(end == 1);
    }
    public void OpenResult()
    {
        LocalManagers.UI.ShowPopupUI<UIPopup>("ResultCanvas");
        LocalManagers.UI.ClosePopupUI("WinnerCanvas");
    }
}
