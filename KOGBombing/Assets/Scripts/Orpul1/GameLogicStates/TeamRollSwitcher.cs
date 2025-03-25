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
            GameObject mainCam = Managers.CamData.GetCamera(ECameraType.MAINCAMERA);
            GameObject miniMapCam = Managers.CamData.GetCamera(ECameraType.MINIMAPCAMERA);
            Destroy(mainCam);
            Destroy(miniMapCam);
            gameData.playerObj.GetComponent<IDestroyAble>().DoDestory();
            Managers.PunData.Initialize();
            Managers.CamData.InitCamera();
            Managers.UI.ClosePopupUI(BAEK.UIKEY.Play);
        }
        private void SwapTeamCount()
        {
            if (!PhotonNetwork.IsMasterClient) return;
            int redTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[EPropertyType.REDTEAM.ToString()];
            int blueTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[EPropertyType.BLUETEAM.ToString()];
            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashtable { { EPropertyType.REDTEAM.ToString(), blueTeamCnt } });
            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashtable { { EPropertyType.BLUETEAM.ToString(), redTeamCnt } });
        }
        private void SwitchTeamRoll()
        {
            ETeam setTeam = ETeam.REDTEAM;
            if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()] == ETeam.REDTEAM)
                setTeam = ETeam.BLUETEAM;
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashtable { { EPropertyType.TEAM.ToString(), setTeam } });

        }
    }
}
