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
        updateScore = Managers.UI.GetPopupUI<BattleBoardUpdater>("BattleBoardCanvas");
        Managers.UI.ClosePopupUI("BattleBoardCanvas");

        ETeam currentTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];

        int playerSize = 0;
        if(currentTeam == ETeam.REDTEAM)
        {
            playerSize = (int)PhotonNetwork.CurrentRoom.CustomProperties[EPropertyType.BLUETEAM.ToString()];
        }
        else
        {
            playerSize = (int)PhotonNetwork.CurrentRoom.CustomProperties[EPropertyType.REDTEAM.ToString()];
        }

        attackPlayerIndexList = new List<bool>(playerSize) { false };
        playerNicknameList = new string[playerSize];
        
        Player[] players = PhotonNetwork.PlayerList;
        for(int i=0; i<players.Length; i++)
        {
            Managers.PointData.AddPlayerInfo(players[i].NickName, new PlayerPointInfo());

            if ((ETeam)players[i].CustomProperties[EPropertyType.TEAM.ToString()] == currentTeam) continue;
            int playerIndex = (int)players[i].CustomProperties[EPropertyType.TEAMINDEX.ToString()];
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
            PlayScene playScene = Managers.UI.GetPopupUI<PlayScene>("PlaySceneCanvas");
            playScene.ActiveKill();
            object[] customDatas = (object[])punEvent.CustomData;
            int killPlayerIndex = (int)customDatas[0];
            string attackPlayer = (string)customDatas[1];
            Debug.Log($"On Event killEvent {killPlayerIndex} ,  {attackPlayer}");
            int currentPlayerIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
            updateScore.UpdatePlayerScore(new StringBuilder(attackPlayer), EPlayerScore.KILLSCORE);
            Managers.PointData.AddPoint(attackPlayer, EPointType.KILL);
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
                Debug.Log($"OnAssist Event {assistPlayerList[i]}");
                StringBuilder targetPlayer = new StringBuilder(assistPlayerList[i]);
                updateScore.UpdatePlayerScore(targetPlayer, EPlayerScore.ASISTSCORE);
                Managers.PointData.AddPoint(targetPlayer.ToString(), EPointType.ASSIST);
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
            Managers.PointData.AddPoint(targetPlayer.ToString(), EPointType.DEATH);
        }
    }
    public void MissionPointEvent(EventData punEvent)
    {
        if (!pv.IsMine) return;
        if (punEvent.Code == (int)EPointType.MISSION)
        {
            StringBuilder targetPlayer = new StringBuilder((string)punEvent.CustomData);
            updateScore.UpdatePlayerScore(targetPlayer, EPlayerScore.MISSIONSCORE);
            Managers.PointData.AddPoint(targetPlayer.ToString(), EPointType.MISSION);
        }
    }
    public void OnDeathPoint()
    {
        PhotonNetwork.RaiseEvent((int)EPointType.DEATH, PhotonNetwork.LocalPlayer.NickName, options, SendOptions.SendReliable);
    }
    public void OnMissionPoint()
    {
        PhotonNetwork.RaiseEvent((int)EPointType.MISSION, PhotonNetwork.LocalPlayer.NickName, options, SendOptions.SendReliable);
    }
    public void OnKillPoint()
    {
        if (lastAttackPlayerIndex == -1) return;
        object[] killCustomDatas = new object[] { lastAttackPlayerIndex, playerNicknameList[lastAttackPlayerIndex] };
        PhotonNetwork.RaiseEvent((int)EPointType.KILL, killCustomDatas, options, SendOptions.SendReliable); // 킬한 플레이어 당한 플레이어 정보
    }
    public void OnAssistPoint()
    {        
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
