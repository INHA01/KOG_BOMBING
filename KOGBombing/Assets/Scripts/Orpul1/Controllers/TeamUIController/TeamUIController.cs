using BAEK;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using System;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class TeamUIController : IUpdateStateAble
{
    private Action<string> updateProfile;
    private Action<ETeam, int> updateScore;
    List<Player> teamPlayerList  = new List<Player>();
    RaiseEventOptions options = new RaiseEventOptions();
    Vector3[] bombPos = new Vector3[(int)BombCursorType.Max];
    int playerIndex = 0;
    public void Init(Transform[] bombPos)
    {
        for(int i = 0; i < bombPos.Length; i++)
        {
            this.bombPos[i] = bombPos[i].position;
        }
        playerIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
    }
    public void SetTeamUI(PlayerShooting playerShooting)
    {
        options.Receivers = ReceiverGroup.All;
       
        Player[] players = PhotonNetwork.PlayerList;
        UIPopup _uiScene = null;
        ETeam selfPlayerTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        ETeam otherPlayerTeam;

        _uiScene = Managers.UI.ShowPopupUI<UIPopup>(UIKEY.Play);
        _uiScene.GetComponent<ShowCursor>().bombPos = bombPos;
        _uiScene.GetComponent<PlayScene>().weapon = playerShooting;
        _uiScene.GetComponent<PlayScene>().Reset();
        int mPlayerIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
        teamPlayerList.Add(PhotonNetwork.LocalPlayer);
        _uiScene.GetComponent<PlayScene>().SetTeam(Managers.PunData.GetPlayerStateData(playerIndex));
        for (int i = 0; i < players.Length; i++)
        {
            otherPlayerTeam = (ETeam)players[i].CustomProperties[EPropertyType.TEAM.ToString()];
            int otherPlayerIndex = (int)players[i].CustomProperties[EPropertyType.TEAMINDEX.ToString()];
            if (otherPlayerIndex == mPlayerIndex) continue;
            if (selfPlayerTeam == otherPlayerTeam)
            {
                teamPlayerList.Add(players[i]);
                _uiScene.GetComponent<PlayScene>().SetTeam(Managers.PunData.GetPlayerStateData(otherPlayerIndex));
            }
        }
        if (_uiScene != null)
        {
            updateProfile = _uiScene.GetComponent<PlayScene>().UpdateProfile;
            updateScore = _uiScene.GetComponent<PlayScene>().UpdateScore;
            PhotonNetwork.NetworkingClient.EventReceived -= UpdateTeamState;
            PhotonNetwork.NetworkingClient.EventReceived -= UpdateTeamScore;
            PhotonNetwork.NetworkingClient.EventReceived += UpdateTeamState;
            PhotonNetwork.NetworkingClient.EventReceived += UpdateTeamScore;
            updateScore(ETeam.REDTEAM, Managers.RoundData.TeamScore[(int)ETeam.REDTEAM]);
            updateScore(ETeam.REDTEAM, Managers.RoundData.TeamScore[(int)ETeam.BLUETEAM]);
        }
    }


    public void UpdateTeamScore(ETeam team, int score)
    {
        if (!PhotonNetwork.IsMasterClient) return;
        object[] datas = new object[2]{team, score};
        PhotonNetwork.RaiseEvent((int)PunEventType.UPDATETEAMSCORE, datas, options, SendOptions.SendReliable);
    }
    private void UpdateTeamState(EventData photonEvent)
    {
        int eventcode = photonEvent.Code;
        if (eventcode != (int)PunEventType.UPDATETEAMSTATE) return;
        Debug.Log("On UpdateTeamState Event");
        for (int i = 0; i < teamPlayerList.Count; i++)
        {
            if (updateProfile != null)
                updateProfile(teamPlayerList[i].NickName);
        }
    }
    private void UpdateTeamScore(EventData photonEvent)
    {
        int eventcode = photonEvent.Code;
        if (eventcode == (int)PunEventType.UPDATETEAMSCORE)
        {
            object[] datas = (object[])photonEvent.CustomData;
            Debug.Log($"On UpdateTeamScore Event {(ETeam)datas[0]} {(int)datas[1]}");
            updateScore((ETeam)datas[0], (int)datas[1]);
        }
    }
    public void EndRound()
    {
        PhotonNetwork.NetworkingClient.EventReceived -= UpdateTeamState;
        PhotonNetwork.NetworkingClient.EventReceived -= UpdateTeamScore;
    }

    public void UpdateTeamState()
    {
        PhotonNetwork.RaiseEvent((int)PunEventType.UPDATETEAMSTATE, null, options, SendOptions.SendReliable);
    }
}
