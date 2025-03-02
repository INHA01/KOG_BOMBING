using System.Collections;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using PhotonHashtable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public class TeamRollSwitcher : GameProcessLogic
    {
        [SerializeField]
        float waitRoundInterval = 2f;
        float time = 0;
        public override void EnterState()
        {
            time = 0;
            SwapTeamCount();
            SwitchTeamRoll();
            DestroyGameObject();
        }
        public override void UpdateState()
        {
            time += Time.deltaTime;
            if (time > waitRoundInterval)
            {
                transitionState((int)EGameState.SELECT);
                time = 0;
            }
        }

        public override void ExitState()
        {
            
        }
        private void DestroyGameObject()
        {
            string playerNickname = PhotonNetwork.LocalPlayer.NickName;
            GameObject mainCam = Managers.CamData.GetCamera(ECameraType.MAINCAMERA);
            GameObject miniMapCam = Managers.CamData.GetCamera(ECameraType.MINIMAPCAMERA);
            Destroy(mainCam);
            Destroy(miniMapCam);
            gameData.playerObj.GetComponent<IDestroyAble>().DoDestory();
            Managers.PunData.Init();
            Managers.CamData.InitCamera();
            Managers.UI.ClosePopupUI("PlayCanvas");
        }
        private void SwapTeamCount()
        {
            if (!PhotonNetwork.IsMasterClient) return;
            int redTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[(int)EPropertyType.REDTEAM];
            int blueTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[(int)EPropertyType.BLUETEAM];
            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashtable { { (int)EPropertyType.REDTEAM, blueTeamCnt } });
            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashtable { { (int)EPropertyType.BLUETEAM, redTeamCnt } });
        }
        private void SwitchTeamRoll()
        {
            ETeam setTeam = ETeam.REDTEAM;
            if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties[(int)EPropertyType.TEAM] == ETeam.REDTEAM)
                setTeam = ETeam.BLUETEAM;
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashtable { { (int)EPropertyType.TEAM, setTeam } });

        }
    }
}
