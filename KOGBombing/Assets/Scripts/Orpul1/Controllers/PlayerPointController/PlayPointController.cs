using System.Collections;
using System.Collections.Generic;
using System.Text;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

public enum EPointType
{
    KILL,
    DEATH,
    ASSIST,
    MISSION,
}
public class PlayPointController
{
    List<bool> attackPlayerIndexList;
    List<string> playerNicknameList;
    List<string> assistPlayerList = new List<string>();
    int lastAttackPlayerIndex = -1;
    PlayerPointInfo playerPoint = new PlayerPointInfo();
    ScoreUIUpdater scoreUIUpdater = new ScoreUIUpdater();

    RaiseEventOptions options;
    public PlayPointController()
    {
        Player[] players = PhotonNetwork.PlayerList;
        attackPlayerIndexList = new List<bool>(players.Length) { false };
        playerNicknameList = new List<string>(players.Length);
        for(int i=0; i<players.Length; i++)
        {
            int playerIndex = (int)players[i].CustomProperties["TeamIndex"];
            playerNicknameList[playerIndex] = players[i].NickName;
        }

        options.Receivers = ReceiverGroup.All;
    }
    public void Initialize()
    {
        lastAttackPlayerIndex = -1;
        for (int i = 0; i < attackPlayerIndexList.Count; i++) 
        {
            attackPlayerIndexList[i] = false;
        }
        PhotonNetwork.NetworkingClient.EventReceived -= KillPointEvent;
        PhotonNetwork.NetworkingClient.EventReceived -= AssistPointEvent;
        PhotonNetwork.NetworkingClient.EventReceived += KillPointEvent;
        PhotonNetwork.NetworkingClient.EventReceived += AssistPointEvent;
    }
    public void Disable()
    {
        PhotonNetwork.NetworkingClient.EventReceived -= KillPointEvent;
        PhotonNetwork.NetworkingClient.EventReceived -= AssistPointEvent;
    }
    public void KillPointEvent(EventData punEvent)
    {
        if(punEvent.Code == (int)EPointType.KILL)
        {
            object[] customDatas = (object[])punEvent.CustomData;
            int killPlayerIndex = (int)customDatas[0];
            string killedPlayer = (string)customDatas[1];
            int currentPlayerIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties["TeamIndex"];
            if(killPlayerIndex == currentPlayerIndex)
            {
                playerPoint.SetKillPoint(playerPoint.KillPoint + 1);
            }
            scoreUIUpdater.UpdatePlayerScore(new StringBuilder(playerNicknameList[killPlayerIndex]), EPlayerScore.KILLSCORE);
        }
    }
    public void AssistPointEvent(EventData punEvent)
    {
        if(punEvent.Code == (int)EPointType.ASSIST)
        {
            List<string> assistPlayerList = (List<string>)punEvent.CustomData;
            int currentPlayerIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties["TeamIndex"];
            if (assistPlayerList[currentPlayerIndex] == PhotonNetwork.LocalPlayer.NickName)
            {
                playerPoint.SetAsistePoint(playerPoint.AsistPoint + 1);
            }
            for(int i=0; i<assistPlayerList.Count; i++)
            {
                StringBuilder targetPlayer = new StringBuilder(assistPlayerList[i]);
                scoreUIUpdater.UpdatePlayerScore(targetPlayer, EPlayerScore.ASISTSCORE);
            }
        }
    }
    public void DeathPointEvent(EventData punEvent)
    {
        if (punEvent.Code == (int)EPointType.DEATH) 
        {
            StringBuilder targetPlayer = new StringBuilder((string)punEvent.CustomData);
            scoreUIUpdater.UpdatePlayerScore(targetPlayer, EPlayerScore.DEATHSCORE);
        }
    }
    public void MissionPointEvent(EventData punEvent)
    {
        if (punEvent.Code == (int)EPointType.DEATH)
        {
            StringBuilder targetPlayer = new StringBuilder((string)punEvent.CustomData);
            scoreUIUpdater.UpdatePlayerScore(targetPlayer, EPlayerScore.DEATHSCORE);
        }
    }
    public void OnDeathPoint()
    {
        PhotonNetwork.RaiseEvent((int)EPointType.KILL, PhotonNetwork.LocalPlayer.NickName, options, SendOptions.SendReliable);
        playerPoint.SetDeathPoint(playerPoint.DeathPoint + 1);
    }
    public void OnMissionPoint()
    {
        PhotonNetwork.RaiseEvent((int)EPointType.KILL, PhotonNetwork.LocalPlayer.NickName, options, SendOptions.SendReliable);
        playerPoint.SetMissionPoint(playerPoint.MissionPoint + 1);
    }
    public void OnKillPoint()
    {
        object[] killCustomDatas = new object[] { lastAttackPlayerIndex, PhotonNetwork.LocalPlayer.NickName };
        PhotonNetwork.RaiseEvent((int)EPointType.KILL, killCustomDatas, options, SendOptions.SendReliable); // 킬한 플레이어 당한 플레이어 정보
    }
    public void OnAssistPoint()
    {
        //보낼 값들 다시 확인
        attackPlayerIndexList[lastAttackPlayerIndex] = false;
        assistPlayerList.RemoveAt(lastAttackPlayerIndex);

        PhotonNetwork.RaiseEvent((int)EPointType.ASSIST, assistPlayerList, options, SendOptions.SendReliable); // 공격 기여한 플레이어들 정보
    }
    public void SetAttackPlayer(int index)
    {
        assistPlayerList.Add(playerNicknameList[index]);
        lastAttackPlayerIndex = index;
    }
}
