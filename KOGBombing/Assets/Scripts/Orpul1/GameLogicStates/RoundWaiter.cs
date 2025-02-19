using System.Collections;
using System.Collections.Generic;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using PhotonHashtable = ExitGames.Client.Photon.Hashtable;
public class RoundWaiter : PhotonPlayerWaitLogic
{
    RaiseEventOptions options;
    bool canCountDown = false;
    float gamestartInterval = 15;
    [SerializeField]
    float time;
    public override void EnterState()
    {
        PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashtable { { "State", (int)EPlayerState.WAITROUND } });
        PhotonNetwork.NetworkingClient.EventReceived += OoCountDown;
        options.Receivers = ReceiverGroup.All;
        SetPlayerPosi();
        canCountDown = false;
        base.EnterState();
    }
    public override void UpdateState()
    {
        if (canCountDown)
            DoCountDown();
    }
    public override void ExitState()
    {
        PhotonNetwork.NetworkingClient.EventReceived -= OoCountDown;
    }

    public override void OnPlayerPropertiesUpdate(Player targetPlayer, PhotonHashtable hashtable)
    {
        if (!PhotonNetwork.IsMasterClient) return;
        if (!targetPlayer.CustomProperties.ContainsKey("State")) return;
        if ((int)targetPlayer.CustomProperties["State"] != (int)EPlayerState.WAITROUND) return;
        readyPlayerCnt++;
    }

    void SetPlayerPosi()
    {
        Vector3 spawnPoint = Managers.PunData.GetPlayerBlackBoard(PhotonNetwork.LocalPlayer.NickName).spawnPoint;
        Managers.PunData.GetPlayerBlackBoard(PhotonNetwork.LocalPlayer.NickName).transform.position = spawnPoint;
    }
    void OoCountDown(EventData punEvent)
    {
        if ((int)punEvent.Code != (int)EGameEvent.ROUNDREADY) return;
        canCountDown = true;
    }
    void DoCountDown()
    {
        time += Time.deltaTime;
        if(time > gamestartInterval)
        {
            transitionState((int)EGameState.GAMESTART);
        }
    }

    protected override void SetCurReadyPlayer()
    {
        Player[] player = PhotonNetwork.PlayerList;
        for (int i = 0; i < player.Length; i++)
        {
            if ((int)player[i].CustomProperties["State"] == (int)EPlayerState.WAITROUND)
                readyPlayerCnt++;
        }
    }

    protected override IEnumerator CoWaitPlayer()
    {
        while (readyPlayerCnt != PhotonNetwork.CurrentRoom.PlayerCount) yield return null;
        PhotonNetwork.RaiseEvent((int)EGameEvent.ROUNDREADY, null, options, SendOptions.SendUnreliable);
    }
}
