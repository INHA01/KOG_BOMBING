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
    string[] playerNicknameList;
    List<string> assistPlayerList = new List<string>();
    int lastAttackPlayerIndex = -1;
    PlayerPointInfo playerPoint = new PlayerPointInfo();
    BattleBoardUpdater scoreUIUpdater;

    RaiseEventOptions options = new RaiseEventOptions();
    IUpdateScore updateScore;
    PhotonView pv;
    PlayerData playerData;
    private StringBuilder killPlayerNickname = new StringBuilder();

    public PlayPointController(PhotonView pv, PlayerData playerData)
    {
        this.pv = pv;
        this.playerData = playerData;
        updateScore = LocalManagers.UI.GetPopupUI<BattleBoardUpdater>("BattleBoardCanvas");
        LocalManagers.UI.ClosePopupUI("BattleBoardCanvas");

        int playerSize = 0;
        int team = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        EPropertyType otherTeam = (int)EPropertyType.BLUETEAM - (EPropertyType)team;
        playerSize = (int)PhotonNetwork.CurrentRoom.CustomProperties[otherTeam.ToString()];


        playerNicknameList = new string[playerSize];
        
        Player[] players = PhotonNetwork.PlayerList;
        for(int i=0; i<players.Length; i++)
        {
            Managers.PointData.AddPlayerInfo(players[i].NickName, new PlayerPointInfo());

            if ((ETeam)players[i].CustomProperties[EPropertyType.TEAM.ToString()] != (ETeam)otherTeam) continue;
            int playerIndex = (int)players[i].CustomProperties[EPropertyType.TEAMINDEX.ToString()];
            playerNicknameList[playerIndex] = players[i].NickName;
        }
        
        options.Receivers = ReceiverGroup.All;
    }
    public void Initialize()
    {
        lastAttackPlayerIndex = -1;
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
    public StringBuilder GetKillPlayerNickname()
    {
        return killPlayerNickname;
    }
    public void KillPointEvent(EventData punEvent)
    {
        if (!pv.IsMine) return;
        if (punEvent.Code != (int)EPointType.KILL) return;

        object[] customDatas = (object[])punEvent.CustomData;
        int killPlayerIndex = (int)customDatas[0];
        string attackPlayer = (string)customDatas[1];
        /*if (attackPlayer == PhotonNetwork.LocalPlayer.NickName)
        {
            PlayScene playScene = LocalManagers.UI.GetPopupUI<PlayScene>("PlayCanvas");
            playScene.ActiveKill();
            AudioClip killSound = playerData.soundList.HitDeathList[(int)EHitDeathSound.PLAYERKILL];
            SoundManager.Instance.PlayEffect(killSound);
        }*/
        Debug.Log($"On Event killEvent {killPlayerIndex} ,  {attackPlayer}");
        int currentPlayerIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
        updateScore.UpdatePlayerScore(new StringBuilder(attackPlayer), EPlayerScore.KILLSCORE);
        Managers.PointData.AddPoint(attackPlayer, EPointType.KILL);
    }
    public void AssistPointEvent(EventData punEvent)
    {
        if (!pv.IsMine) return;
        if (punEvent.Code != (int)EPointType.ASSIST) return;

        string[] assistPlayerList = (string[])punEvent.CustomData;
        for (int i = 0; i < assistPlayerList.Length; i++)
        {
            Debug.Log($"OnAssist Event {assistPlayerList[i]}");
            StringBuilder targetPlayer = new StringBuilder(assistPlayerList[i]);
            updateScore.UpdatePlayerScore(targetPlayer, EPlayerScore.ASISTSCORE);
            Managers.PointData.AddPoint(targetPlayer.ToString(), EPointType.ASSIST);
        }
    }
    public void DeathPointEvent(EventData punEvent)
    {
        if (!pv.IsMine) return;
        if (punEvent.Code != (int)EPointType.DEATH) return;

        StringBuilder targetPlayer = new StringBuilder((string)punEvent.CustomData);
        updateScore.UpdatePlayerScore(targetPlayer, EPlayerScore.DEATHSCORE);
        Managers.PointData.AddPoint(targetPlayer.ToString(), EPointType.DEATH);
    }
    public void MissionPointEvent(EventData punEvent)
    {
        if (!pv.IsMine) return;
        if (punEvent.Code != (int)EPointType.MISSION) return;

        StringBuilder targetPlayer = new StringBuilder((string)punEvent.CustomData);
        updateScore.UpdatePlayerScore(targetPlayer, EPlayerScore.MISSIONSCORE);
        Managers.PointData.AddPoint(targetPlayer.ToString(), EPointType.MISSION);
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
        killPlayerNickname.Clear();
        killPlayerNickname.Append(playerNicknameList[lastAttackPlayerIndex]);
        object[] killCustomDatas = new object[] { lastAttackPlayerIndex, playerNicknameList[lastAttackPlayerIndex] };
        PhotonNetwork.RaiseEvent((int)EPointType.KILL, killCustomDatas, options, SendOptions.SendReliable); // 킬한 플레이어, 당한 플레이어 정보
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
