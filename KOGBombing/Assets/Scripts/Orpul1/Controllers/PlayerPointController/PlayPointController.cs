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
    string[] otherTeamPlayerList;
    string[] myTeamPlayerList;
    Dictionary<ETeam, string[]> dictPlayerInfos = new Dictionary<ETeam, string[]>();
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
        updateScore = Managers.UI.GetPopupUI<BattleBoardUpdater>("BattleBoardCanvas");
        Managers.UI.ClosePopupUI("BattleBoardCanvas");
        SetPlayerList();
        options.Receivers = ReceiverGroup.All;
    }
    private void SetPlayerList()
    {
        int otherTeamCount = 0;
        int myTeamCount = 0;
        ETeam myTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        EPropertyType otherTeam = (int)EPropertyType.BLUETEAM - (EPropertyType)myTeam;
        otherTeamCount = (int)PhotonNetwork.CurrentRoom.CustomProperties[otherTeam.ToString()];
        myTeamCount = (int)PhotonNetwork.CurrentRoom.CustomProperties[myTeam.ToString()];

        myTeamPlayerList = new string[myTeamCount];
        otherTeamPlayerList = new string[otherTeamCount];

        Player[] players = PhotonNetwork.PlayerList;
        for (int i = 0; i < players.Length; i++)
        {
            Managers.PointData.AddPlayerInfo(players[i].NickName, new PlayerPointInfo());

            int playerIndex = (int)players[i].CustomProperties[EPropertyType.TEAMINDEX.ToString()];
            if ((ETeam)players[i].CustomProperties[EPropertyType.TEAM.ToString()] != (ETeam)otherTeam)
            {
                myTeamPlayerList[playerIndex] = players[i].NickName;
            }
            else
            {
                otherTeamPlayerList[playerIndex] = players[i].NickName;
            }
        }
        dictPlayerInfos.Add(myTeam, myTeamPlayerList);
        dictPlayerInfos.Add((ETeam)otherTeam, otherTeamPlayerList);
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
        int deathPlayerTeamIndex = (int)customDatas[1];
        ETeam killPlayerTeam = (ETeam)customDatas[2];
        PlayScene playScene = Managers.UI.GetPopupUI<PlayScene>("PlayCanvas");
        ShowKillLogoUI(playScene, killPlayerIndex,killPlayerTeam);
        ShowKillLogUI(playScene, killPlayerIndex, deathPlayerTeamIndex, killPlayerTeam);
        
        updateScore.UpdatePlayerScore(new StringBuilder(dictPlayerInfos[killPlayerTeam][killPlayerIndex]), EPlayerScore.KILLSCORE);
        Managers.PointData.AddPoint(dictPlayerInfos[killPlayerTeam][killPlayerIndex], EPointType.KILL);
    }
    private void ShowKillLogoUI(PlayScene playScene, int killPlayerIndex, ETeam killPlayerTeam)
    {
        if (killPlayerTeam != (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()]) return;
        if (killPlayerIndex != (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()]) return;
        playScene.ActiveKill();
        AudioClip killSound = playerData.soundList.HitDeathList[(int)EHitDeathSound.PLAYERKILL];
        Managers.Sound.PlayEffect(killSound);
    }
    private void ShowKillLogUI(PlayScene playScene, int killPlayerIndex, int deathPlayerTeamIndex, ETeam killPlayerTeam)
    {
        ETeam deathPlayerTeam = ETeam.BLUETEAM - (int)killPlayerTeam;
        PlayerInfo killPlayer = new PlayerInfo(new StringBuilder(dictPlayerInfos[killPlayerTeam][killPlayerIndex]), killPlayerTeam);
        PlayerInfo deathPlayer = new PlayerInfo(new StringBuilder(dictPlayerInfos[deathPlayerTeam][deathPlayerTeamIndex]), deathPlayerTeam);
        playScene.UpdateKillLog(new PlayerInfo[2] { killPlayer, deathPlayer });
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
        killPlayerNickname.Append(otherTeamPlayerList[lastAttackPlayerIndex]);
        //161번째 줄 null  이슈
        ETeam killPlayerTeam = ETeam.BLUETEAM - (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        int deathPlayerTeamIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
        object[] killCustomDatas = new object[] { lastAttackPlayerIndex , deathPlayerTeamIndex, killPlayerTeam };
        PhotonNetwork.RaiseEvent((int)EPointType.KILL, killCustomDatas, options, SendOptions.SendReliable); // 킬한 플레이어, 당한 플레이어 정보
    }
    public void OnAssistPoint()
    {        
        if (assistPlayerList.Contains(otherTeamPlayerList[lastAttackPlayerIndex]))
            assistPlayerList.Remove(otherTeamPlayerList[lastAttackPlayerIndex]);
        if (assistPlayerList.Count != 0) 
            PhotonNetwork.RaiseEvent((int)EPointType.ASSIST, assistPlayerList.ToArray(), options, SendOptions.SendReliable); // 공격 기여한 플레이어들 정보
    }
    public void SetAttackPlayer(int index)
    {
        if (index == -1) return;

        Debug.Log($"attackPlayerindex{index}");
        Debug.Log($"AttackPlayer {otherTeamPlayerList[index]}");
        if (!assistPlayerList.Contains(otherTeamPlayerList[index]))
        {
            Debug.Log($"Add AttackPlayer {index}");
            assistPlayerList.Add(otherTeamPlayerList[index].ToString());
        }
        lastAttackPlayerIndex = index;
    }
}
