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
            GameObject mainCam = LocalManagers.CamData.GetCamera(ECameraType.MAINCAMERA);
            GameObject miniMapCam = LocalManagers.CamData.GetCamera(ECameraType.MINIMAPCAMERA);
            PhotonNetwork.Destroy(LocalManagers.PunData.GetPlayerBlackBoard(playerNickname).gameObject);
            Destroy(mainCam);
            Destroy(miniMapCam);
            LocalManagers.CamData.InitCamera();
            LocalManagers.UI.ClosePopupUI("PlayCanvas");
            LocalManagers.UI.ShowPopupUI<Winner>("WinnerCanvas").SetWiner(1);
            Managers.PointData.SetBestPlayer();
            LocalManagers.PunData.Init();
            LocalManagers.CamData.InitCamera();
        }
        public override void UpdateState()
        {
        }
        public override void ExitState()
        {
        }
    }
}
