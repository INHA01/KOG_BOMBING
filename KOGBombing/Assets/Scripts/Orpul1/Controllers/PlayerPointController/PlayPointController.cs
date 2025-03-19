using System.Collections;
using System.Collections.Generic;
using System.Text;
using System;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using System.Security.Cryptography;

public enum EPointType
{
    KILL,
    DEATH,
    ASSIST,
    MISSION,
    DAMAGE,
}
public class PlayPointController : MonoBehaviour, ISetPointable
{

    string[] otherTeamPlayerList;
    string[] myTeamPlayerList;
    Dictionary<ETeam, string[]> dictPlayerInfos = new Dictionary<ETeam, string[]>();
    List<int> assistPlayerList = new List<int>();
    int lastAttackPlayerIndex = -1;

    [SerializeField] PhotonView pView;
    [SerializeField] PlayerData playerData;
    RaiseEventOptions options = new RaiseEventOptions();
    IUpdateScore updateScore;
    private StringBuilder killPlayerNickname = new StringBuilder();

    public void Start()
    {
        updateScore = Managers.UI.GetPopupUI<BattleBoardUpdater>(BAEK.UIKEY.BattleBoard);
        Managers.UI.ClosePopupUI(BAEK.UIKEY.BattleBoard);
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
    }
    public StringBuilder GetKillPlayerNickname()
    {
        return killPlayerNickname;
    }
    private void ShowKillLogUI(PlayScene playScene, int killPlayerIndex, int deathPlayerTeamIndex, ETeam killPlayerTeam)
    {
        ETeam deathPlayerTeam = ETeam.BLUETEAM - (int)killPlayerTeam;
        PlayerInfo killPlayer = new PlayerInfo(new StringBuilder(dictPlayerInfos[killPlayerTeam][killPlayerIndex]), killPlayerTeam);
        PlayerInfo deathPlayer = new PlayerInfo(new StringBuilder(dictPlayerInfos[deathPlayerTeam][deathPlayerTeamIndex]), deathPlayerTeam);
        playScene.UpdateKillLog(new PlayerInfo[2] { killPlayer, deathPlayer });
    }
    private void ShowKillLogoUI(PlayScene playScene, int killPlayerIndex, ETeam killPlayerTeam)
    {
        if (killPlayerTeam != (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()]) return;
        if (killPlayerIndex != (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()]) return;
        playScene.ActiveKill();

        playerData.playerSound.hitDeathSound.ActiveSound(transform, EHitDeathSound.PLAYERKILL);
    }
    private string[] GetPlayerList(ETeam team)
    {
        ETeam myTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        return team == myTeam ? myTeamPlayerList : otherTeamPlayerList;
    }
    [PunRPC]
    public void PunKill(int killPlayerIndex, int deathPlayerTeamIndex, ETeam killPlayerTeam)
    {
        PlayScene playScene = Managers.UI.GetPopupUI<PlayScene>(BAEK.UIKEY.Play);
        ShowKillLogoUI(playScene, killPlayerIndex, killPlayerTeam);
        ShowKillLogUI(playScene, killPlayerIndex, deathPlayerTeamIndex, killPlayerTeam);

        updateScore.UpdatePlayerScore(new StringBuilder(dictPlayerInfos[killPlayerTeam][killPlayerIndex]), EPlayerScore.KILLSCORE);
        Managers.PointData.AddPoint(dictPlayerInfos[killPlayerTeam][killPlayerIndex], EPointType.KILL);
    }
   
    [PunRPC]
    public void PunAssist(int[] playerIndex, ETeam team)
    {
        string[] playerList = GetPlayerList(team);

        for (int i = 0; i < playerIndex.Length; i++)
        {
            StringBuilder targetPlayer = new StringBuilder(playerList[playerIndex[i]]);
            updateScore.UpdatePlayerScore(targetPlayer, EPlayerScore.ASISTSCORE);
            Managers.PointData.AddPoint(targetPlayer.ToString(), EPointType.ASSIST);
        }
    }
    [PunRPC]
    public void PunDeath(int playerIndex, ETeam team)
    {
        string[] playerList = GetPlayerList(team);
        StringBuilder targetPlayer = new StringBuilder(playerList[playerIndex]);
        updateScore.UpdatePlayerScore(targetPlayer, EPlayerScore.DEATHSCORE);
        Managers.PointData.AddPoint(targetPlayer.ToString(), EPointType.DEATH);
    }
    [PunRPC]
    public void PunMission(int playerIndex, ETeam team)
    {
        string[] playerList = GetPlayerList(team);
        StringBuilder targetPlayer = new StringBuilder(playerList[playerIndex]);
        updateScore.UpdatePlayerScore(targetPlayer, EPlayerScore.MISSIONSCORE);
        updateScore.UpdateTeamScore(team, ETeamScore.MISSIONSCORE);
        Managers.PointData.AddPoint(targetPlayer.ToString(), EPointType.MISSION);
    }
    
    [PunRPC]
    public void PunDamage(ETeam damagePlayerTeam, int playerIndex, int damage)
    {
        ETeam myTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        string player = damagePlayerTeam == myTeam ? myTeamPlayerList[(int)playerIndex] : otherTeamPlayerList[(int)playerIndex];
        StringBuilder targetPlayer = new StringBuilder(player);
        updateScore.UpdatePlayerScore(targetPlayer, EPlayerScore.DAMAGESCORE, damage);
    }

    public void OnDeathPoint()
    {
        ETeam playerTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        int playerIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
        pView.RPC("PunDeath", RpcTarget.All, playerIndex, playerTeam);
    }
    public void OnMissionPoint(ETeam playerTeam, int playerIndex)
    {
        pView.RPC("PunMission", RpcTarget.All, playerIndex, playerTeam);
    }
    public void OnKillPoint()
    {
        if (lastAttackPlayerIndex == -1) return;
        killPlayerNickname.Clear();
        killPlayerNickname.Append(otherTeamPlayerList[lastAttackPlayerIndex]);
        ETeam killPlayerTeam = ETeam.BLUETEAM - (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        int deathPlayerTeamIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
        pView.RPC("PunKill", RpcTarget.All, lastAttackPlayerIndex, deathPlayerTeamIndex, killPlayerTeam);
    }
    public void OnAssistPoint()
    {        
        if (assistPlayerList.Contains(lastAttackPlayerIndex))
            assistPlayerList.Remove(lastAttackPlayerIndex);
        if (assistPlayerList.Count == 0) return;
        ETeam team = ETeam.BLUETEAM - (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        pView.RPC("PunAssist", RpcTarget.All, assistPlayerList.ToArray(), team);
    }
    public void OnDamagePoint(int index, int damage)
    {
        ETeam damagePlayerTeam = ETeam.BLUETEAM - (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        pView.RPC("PunDamage", RpcTarget.All, damagePlayerTeam, index, damage);
    }
    public void SetAttackPlayer(int index)
    {
        if (index == -1) return;
        if (!assistPlayerList.Contains(index)) 
            assistPlayerList.Add(index);

        lastAttackPlayerIndex = index;
    }

    public void SetMissionPoint(ETeam team, int playerIndex)
    {
        OnMissionPoint(team, playerIndex);
    }
}
