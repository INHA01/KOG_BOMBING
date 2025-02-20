using System.Collections;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using PhotonHashtable = ExitGames.Client.Photon.Hashtable;

public class TeamRollSwitcher : GameProcessLogic
{
    [SerializeField]
    float waitRoundInterval = 2f;
    float time = 0;
    public override void EnterState()
    {
        time = 0;
        SwitchTeamRoll();
    }
    public override void UpdateState()
    {
        time += Time.deltaTime;
        if (time > waitRoundInterval) 
        {
            DestroyGameObject();
            transitionState((int)EGameState.SELECT);
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
        PhotonNetwork.Destroy(logicContext.playerObj);
        Managers.PunData.Init();
        Managers.CamData.InitCamera();
        Managers.UI.ClosePopupUI("PlayCanvas");
    }
    private void SwitchTeamRoll()
    {
        logicContext.roundData.SwapTeam();
        if (!PhotonNetwork.IsMasterClient) return;
        Player[] players = PhotonNetwork.PlayerList;
        for (int i = 0; i < players.Length; i++)
        {
            ETeam setTeam = ETeam.REDTEAM;
            if ((ETeam)players[i].CustomProperties["Team"] == ETeam.REDTEAM)
                setTeam = ETeam.BLUETEAM;
            players[i].SetCustomProperties(new PhotonHashtable { { "Team", setTeam } });
        }
    }
}