using System.Collections;
using System.Collections.Generic;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using PhotnHashtable = ExitGames.Client.Photon.Hashtable;
using UnityEngine;

public class GameProcess : GameProcessLogic
{
    RaiseEventOptions options;
    int attakTeamCnt = 0;
    int defensTeamCnt = 0;
    public override void EnterState()
    {
        attakTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
        defensTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
        PhotonNetwork.NetworkingClient.EventReceived += SendRoundEnd;

    }
    public override void UpdateState()
    {
    }

    public override void ExitState()
    {
        PhotonNetwork.NetworkingClient.EventReceived -= SendRoundEnd;
    }
    private void CheckExterminateTeam()
    {
        if (attakTeamCnt == 0)
        {

        }
        else if(defensTeamCnt == 0)
        {

        }
    }
    private void SendRoundEnd(EventData punEvent)
    {
        if ((int)punEvent.Code != (int)EGameEvent.EXTERMINATETEAM) return;
        PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotnHashtable { { "State", EPlayerState.WAITROUND } });
    }
    private void RedayNextRound()
    {
        transitionState((int)EGameState.ROUNDWAIT);
    }
}
