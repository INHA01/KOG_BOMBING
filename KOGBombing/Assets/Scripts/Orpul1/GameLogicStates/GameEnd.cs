using System.Text;
using Photon.Pun;
using UnityEngine;

namespace Orpul1
{
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
            Managers.UI.ClosePopupUI(BAEK.UIKEY.Play);
            Managers.UI.ShowPopupUI<Winner>(BAEK.UIKEY.Winner).SetWiner(1);
            Managers.PointData.SetBestPlayer();
            Managers.PunData.Init();
            Managers.CamData.InitCamera();
        }
        public override void UpdateState()
        {
        }
        public override void ExitState()
        {
        }
    }
}
