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

    public override void Init()
    {
        base.Init();
        Canvas canvas = GetComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceCamera;
        canvas.worldCamera = Managers.CamData.GetCamera(ECameraType.EFFECTCAMERA).GetComponent<Camera>();
        Managers.UI.ChangeAllCanvsRender(RenderMode.ScreenSpaceCamera);
    }

	public void SetWiner(int end)
    {
        WinnerTeam winTeam = Managers.RoundData.RoundWinTeam;
        if(end == 0)
            winTeam = Managers.RoundData.RoundWinTeam;
        else
            winTeam = Managers.RoundData.WinTeam;
        ActiveRoundResultSound(winTeam);
        animator.Rebind();
        animator.SetInteger("winner", (int)winTeam);
        activeResultButton.SetActive(end == 1);
    }
    public void OpenResult()
    {
        Managers.UI.ShowPopupUI<UIPopup>("ResultCanvas");
        Managers.UI.ClosePopupUI("WinnerCanvas");
    }
    private void ActiveRoundResultSound(WinnerTeam winTeam)
    {
        ETeam myTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        EUiSoundType roundResultSound = (int)myTeam == (int)winTeam ? EUiSoundType.WIN : EUiSoundType.LOSS;
        Managers.Sound.PlayUISound(roundResultSound);
    }
}
