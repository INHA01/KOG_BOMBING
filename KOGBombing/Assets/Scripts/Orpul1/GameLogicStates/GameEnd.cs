using System.Text;
using Photon.Pun;
using UnityEngine;

public class GameEnd : GameProcessLogic
{
    public override void EnterState()
    {
        string playerNickname = PhotonNetwork.LocalPlayer.NickName;
        GameObject mainCam = Managers.CamData.GetCamera(ECameraType.MAINCAMERA);
        GameObject miniMapCam = Managers.CamData.GetCamera(ECameraType.MINIMAPCAMERA);
        PhotonNetwork.Destroy(Managers.PunData.GetPlayerBlackBoard(playerNickname).gameObject);
        Destroy(mainCam);
        Destroy(miniMapCam);
        Managers.CamData.InitCamera();
        Managers.UI.ClosePopupUI("PlayCanvas");
        Managers.UI.ShowPopupUI<UIPopup>("WinnerCanvas");
    }
    public override void UpdateState()
    {
    }
    public override void ExitState()
    {
    }
}