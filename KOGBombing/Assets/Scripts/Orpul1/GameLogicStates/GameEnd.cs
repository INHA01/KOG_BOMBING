using System.Text;
using Michsky.UI.Shift;
using Photon.Pun;
using UnityEngine;

namespace Orpul1
{
    public class GameEnd : GameProcessLogic
    {
        public override void EnterState()
        {
            int playerIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
            GameObject mainCam = Managers.CamData.GetCamera(ECameraType.MAINCAMERA);
            GameObject miniMapCam = Managers.CamData.GetCamera(ECameraType.MINIMAPCAMERA);
            GameObject playerObj = Managers.PunData.GetPlayerStateData(playerIndex).playerObj;

            PhotonNetwork.Destroy(playerObj);
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
