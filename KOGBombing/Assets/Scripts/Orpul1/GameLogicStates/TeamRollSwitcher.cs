using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using PhotonHashtable = ExitGames.Client.Photon.Hashtable;

public class TeamRollSwitcher : GameProcessLogic
{
    Player[] players;
    public override void EnterState()
    {
        players = PhotonNetwork.PlayerList;
    }
    public override void UpdateState()
    {
        SwitchTeamRoll();
        DestroyGameObject();
        transitionState((int)EGameState.SELECT);
    }

    public override void ExitState()
    {
    }
    private void DestroyGameObject()
    {
        string playerNickname = PhotonNetwork.LocalPlayer.NickName;
        GameObject mainCam = Managers.CamData.GetCamera(ECameraType.MAINCAMERA);
        GameObject miniMapCam = Managers.CamData.GetCamera(ECameraType.MINIMAPCAMERA);
        PhotonNetwork.Destroy(Managers.PunData.GetPlayerBlackBoard(playerNickname).gameObject);
        Destroy(mainCam);
        Destroy(miniMapCam);
        Managers.PunData.Init();
        Managers.CamData.InitCamera();
        Managers.UI.ClosePopupUI("PlayCanvas");
    }
    private void SwitchTeamRoll()
    {
        if (!PhotonNetwork.IsMasterClient) return;
        for (int i = 0; i < players.Length; i++)
        {
            ETeam setTeam = ETeam.REDTEAM;
            if ((ETeam)players[i].CustomProperties["Team"] == ETeam.REDTEAM)
                setTeam = ETeam.BLUETEAM;
            players[i].SetCustomProperties(new PhotonHashtable { { "Team", setTeam } });
        }
    }
}