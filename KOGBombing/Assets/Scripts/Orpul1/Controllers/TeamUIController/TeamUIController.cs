using ExitGames.Client.Photon;
using Photon.Pun;
using Photon.Realtime;
using System;

public class TeamUIController
{
    public Action<string, float> updateProfile;
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
            Player[] players = PhotonNetwork.PlayerList;
            string selfTeam = (string)PhotonNetwork.LocalPlayer.CustomProperties["Team"];
            string otherTeam = "";
            for (int i = 0; i < players.Length; i++)
            {
                otherTeam = (string)players[i].CustomProperties["Team"];

                if (selfTeam == otherTeam)
                {
                    float hp = Managers.PunData.GetPlayerBlackBoard(players[i].NickName).hp;

                    if (updateProfile != null)
                        updateProfile(players[i].NickName, hp);
                }
            }
        }
    }

}
