using ExitGames.Client.Photon;
using Photon.Pun;
using Photon.Realtime;
using System;
using System.Collections.Generic;

public class TeamUIController
{
    private Action<string, float,float ,bool> updateProfile;
    List<Player> teamPlayerList  = new List<Player>();
    public void SetTeamUI(PlayerShooting playerShooting)
    {
        PhotonNetwork.NetworkingClient.EventReceived += UpdateUI;
        Player[] players = PhotonNetwork.PlayerList;
        UIScene _uiScene = null;
        string selfPlayerTeam = (string)PhotonNetwork.LocalPlayer.CustomProperties["Team"];
        string otherPlayerTeam = "";
        for (int i = 0; i < players.Length; i++)
        {
            otherPlayerTeam = (string)players[i].CustomProperties["Team"];
            if (selfPlayerTeam == otherPlayerTeam)
            {
                teamPlayerList.Add(players[i]);
                _uiScene = Managers.UI.ShowSceneUI<UIScene>("PlayCanvas");
                _uiScene.GetComponent<PlayScene>().weapon = playerShooting;
                _uiScene.GetComponent<PlayScene>().SetTeam(Managers.PunData.GetPlayerBlackBoard(players[i].NickName));
            }
        }
        if (_uiScene != null)
            updateProfile = _uiScene.GetComponent<PlayScene>().UpdateProfile;
    }
    public void UpdateTeamUI()
    {
        RaiseEventOptions options = new RaiseEventOptions();
        options.Receivers = ReceiverGroup.All;
        PhotonNetwork.RaiseEvent(0, null, options, SendOptions.SendReliable);
    }
    private void UpdateUI(EventData photonEvent)
    {
        int eventcode = photonEvent.Code;
        if (eventcode == 0)
        {
            for (int i = 0; i < teamPlayerList.Count; i++)
            {
                PlayerBlackBoard blackBoard = Managers.PunData.GetPlayerBlackBoard(teamPlayerList[i].NickName);

                if (updateProfile != null)
                    updateProfile(teamPlayerList[i].NickName, blackBoard.hp, blackBoard.defence , blackBoard.isLive);
            }
        }
    }

}
