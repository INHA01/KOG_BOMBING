using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Pun.UtilityScripts;
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
    string[] playerNicknameList;
    List<string> assistPlayerList = new List<string>();
    int lastAttackPlayerIndex = -1;
    PlayerPointInfo playerPoint = new PlayerPointInfo();
    BattleBoardUpdater scoreUIUpdater;

    RaiseEventOptions options = new RaiseEventOptions();
    IUpdateScore updateScore;
    PhotonView pv;
    public PlayPointController(PhotonView pv)
    {
        this.pv = pv;
        UIPopup _uiPopup = Managers.UI.GetPopupUI<UIPopup>("BattleBoardCanvas");
        updateScore = _uiPopup.GetComponent<BattleBoardUpdater>();

        ETeam currentTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"];

        int playerSize = 0;
        if(currentTeam == ETeam.REDTEAM)
        {
            playerSize = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
        }
        else
        {
            playerSize = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
        }

        attackPlayerIndexList = new List<bool>(playerSize) { false };
        playerNicknameList = new string[playerSize];
        
        Player[] players = PhotonNetwork.PlayerList;
        for(int i=0; i<players.Length; i++)
        {
            Managers.PointData.AddPlayerInfo(players[i].NickName, new PlayerPointInfo());

            if ((ETeam)players[i].CustomProperties["Team"] == currentTeam) continue;
            int playerIndex = (int)players[i].CustomProperties["TeamIndex"];
            Debug.Log($"nickname {players[i].NickName}");
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
        assistPlayerList.Clear();
        UnsubscribeEvent();
        SubscribeEvent();
    }
    public void Disable()
    {
        UnsubscribeEvent();
    }
    private void SubscribeEvent()
    {
        PhotonNetwork.NetworkingClient.EventReceived += KillPointEvent;
        PhotonNetwork.NetworkingClient.EventReceived += DeathPointEvent;
        PhotonNetwork.NetworkingClient.EventReceived += AssistPointEvent;
        PhotonNetwork.NetworkingClient.EventReceived += MissionPointEvent;
    }
    private void UnsubscribeEvent()
    {
        PhotonNetwork.NetworkingClient.EventReceived -= KillPointEvent;
        PhotonNetwork.NetworkingClient.EventReceived -= DeathPointEvent;
        PhotonNetwork.NetworkingClient.EventReceived -= AssistPointEvent;
        PhotonNetwork.NetworkingClient.EventReceived -= MissionPointEvent;
    }
    public void KillPointEvent(EventData punEvent)
    {
        if (!pv.IsMine) return;
        if(punEvent.Code == (int)EPointType.KILL)
        {
            object[] customDatas = (object[])punEvent.CustomData;
            int killPlayerIndex = (int)customDatas[0];
            string attackPlayer = (string)customDatas[1];
            Debug.Log($"On Event killEvent {killPlayerIndex} ,  {attackPlayer}");
            int currentPlayerIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties["TeamIndex"];
            if(killPlayerIndex == currentPlayerIndex)
            {
                playerPoint.SetKillPoint(playerPoint.KillPoint + 1);
            }
            Managers.PointData.AddPlayerInfo(attackPlayer, new PlayerPointInfo());
            updateScore.UpdatePlayerScore(new StringBuilder(attackPlayer),EPlayerScore.KILLSCORE);
        }
    }
    public void AssistPointEvent(EventData punEvent)
    {
        if (!pv.IsMine) return;
        if (punEvent.Code == (int)EPointType.ASSIST)
        {
            string[] assistPlayerList = (string[])punEvent.CustomData;
            
            for (int i=0; i<assistPlayerList.Length; i++)
            {
                if (assistPlayerList[i] == PhotonNetwork.LocalPlayer.NickName)
                {
                    playerPoint.SetAsistePoint(playerPoint.AsistPoint + 1);
                }
                Debug.Log($"OnAssist Event {assistPlayerList[i]}");
                StringBuilder targetPlayer = new StringBuilder(assistPlayerList[i]);
                updateScore.UpdatePlayerScore(targetPlayer, EPlayerScore.ASISTSCORE);
                Managers.PointData.AddPlayerInfo(targetPlayer.ToString(), new PlayerPointInfo());
            }
        }
    }
    public void DeathPointEvent(EventData punEvent)
    {
        if (!pv.IsMine) return;
        if (punEvent.Code == (int)EPointType.DEATH) 
        {
            StringBuilder targetPlayer = new StringBuilder((string)punEvent.CustomData);
            updateScore.UpdatePlayerScore(targetPlayer, EPlayerScore.DEATHSCORE);
            Managers.PointData.AddPlayerInfo(targetPlayer.ToString(), new PlayerPointInfo());

        }
    }
    public void MissionPointEvent(EventData punEvent)
    {
        if (!pv.IsMine) return;
        if (punEvent.Code == (int)EPointType.MISSION)
        {
            StringBuilder targetPlayer = new StringBuilder((string)punEvent.CustomData);
            updateScore.UpdatePlayerScore(targetPlayer, EPlayerScore.MISSIONSCORE);
        }
    }
    public void OnDeathPoint()
    {
        PhotonNetwork.RaiseEvent((int)EPointType.DEATH, PhotonNetwork.LocalPlayer.NickName, options, SendOptions.SendReliable);
        playerPoint.SetDeathPoint(playerPoint.DeathPoint + 1);
    }
    public void OnMissionPoint()
    {
        PhotonNetwork.RaiseEvent((int)EPointType.MISSION, PhotonNetwork.LocalPlayer.NickName, options, SendOptions.SendReliable);
        playerPoint.SetMissionPoint(playerPoint.MissionPoint + 1);
    }
    public void OnKillPoint()
    {
        if (lastAttackPlayerIndex == -1) return;
        object[] killCustomDatas = new object[] { lastAttackPlayerIndex, playerNicknameList[lastAttackPlayerIndex] };
        PhotonNetwork.RaiseEvent((int)EPointType.KILL, killCustomDatas, options, SendOptions.SendReliable); // 킬한 플레이어 당한 플레이어 정보
    }
    public void OnAssistPoint()
    {
        //보낼 값들 다시 확인
        //attackPlayerIndexList[lastAttackPlayerIndex] = false;
        
        if (assistPlayerList.Contains(playerNicknameList[lastAttackPlayerIndex]))
            assistPlayerList.Remove(playerNicknameList[lastAttackPlayerIndex]);
        if (assistPlayerList.Count != 0) 
            PhotonNetwork.RaiseEvent((int)EPointType.ASSIST, assistPlayerList.ToArray(), options, SendOptions.SendReliable); // 공격 기여한 플레이어들 정보
    }
    public void SetAttackPlayer(int index)
    {
        if (index == -1) return;

        Debug.Log($"attackPlayerindex{index}");
        Debug.Log($"AttackPlayer {playerNicknameList[index]}");
        if (!assistPlayerList.Contains(playerNicknameList[index]))
        {
            Debug.Log($"Add AttackPlayer {index}");
            assistPlayerList.Add(playerNicknameList[index].ToString());
        }
        lastAttackPlayerIndex = index;
    }
}
