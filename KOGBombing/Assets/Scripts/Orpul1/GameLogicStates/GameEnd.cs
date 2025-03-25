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
            GameObject mainCam = Managers.CamData.GetCamera(ECameraType.MAINCAMERA);
            GameObject miniMapCam = Managers.CamData.GetCamera(ECameraType.MINIMAPCAMERA);

            gameData.playerObj.GetComponent<IDestroyAble>().DoDestory();
            Destroy(mainCam);
            Destroy(miniMapCam);

            Managers.CamData.InitCamera();
            Managers.UI.ClosePopupUI(BAEK.UIKEY.Play);
            Managers.RoundData.CalcWinTeam();
            Managers.UI.ShowPopupUI<Winner>(BAEK.UIKEY.Winner).SetWiner(1);
            Managers.PointData.SetBestPlayer();
            Managers.PunData.Initialize();
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
