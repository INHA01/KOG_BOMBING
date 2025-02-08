using System.Collections.Generic;
using System.Text;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;
namespace Orpul1
{
    public class PlayerListController : MonoBehaviourPunCallbacks
    {
     
        [SerializeField]
        GameObject playerPanelPref;

        [SerializeField]
        Transform[] trTeamPanel;

        Dictionary<string, DisplayPlayerPresenter> dicPlayerInfo = new Dictionary<string, DisplayPlayerPresenter>();

        public override void OnJoinedRoom()
        {
            if (PhotonNetwork.CurrentLobby.Name != "CustomLobby") return;
            if (PhotonNetwork.IsMasterClient)
            {
                PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", ETeam.REDTEAM } });
            }
            Player[] players = PhotonNetwork.PlayerList;
            for(int i=0; i<players.Length; i++)
            {
                UpdatePlayer(players[i]);
            }
        }
        public override void OnPlayerEnteredRoom(Player newPlayer)
        {
            if (PhotonNetwork.CurrentLobby.Name != "CustomLobby") return;
            UpdatePlayer(newPlayer);
        }
        public override void OnPlayerLeftRoom(Player otherPlayer)
        {
            if (PhotonNetwork.CurrentLobby.Name != "CustomLobby") return;
            if (!dicPlayerInfo.ContainsKey(otherPlayer.NickName)) return;
            Destroy(dicPlayerInfo[otherPlayer.NickName].gameObject);
            dicPlayerInfo.Remove(otherPlayer.NickName);
        }

        public override void OnPlayerPropertiesUpdate(Player targetPlayer, PhotonHashTable changedProps)
        {
            if (PhotonNetwork.CurrentLobby.Name != "CustomLobby") return;
            if (targetPlayer.CustomProperties.ContainsKey("Team"))
            {
                SwapPlayerTeam(targetPlayer);
            }
        }
        
        private void UpdatePlayer(Player playerInfo)
        {
            if(!dicPlayerInfo.ContainsKey(playerInfo.NickName))
            {
                int teamIndex = 0;
                if (playerInfo.CustomProperties["Team"]!=null)
                {
                    //teamIndex = GetTeamIndex(new StringBuilder(playerInfo.CustomProperties["Team"].ToString()));
                    teamIndex = (int)playerInfo.CustomProperties["Team"];
                }
                else
                {
                    teamIndex = GetTeamIndex();
                }
                GameObject playerPanelObj = Instantiate(playerPanelPref, trTeamPanel[teamIndex]);
                DisplayPlayerPresenter panel = playerPanelObj.GetComponent<DisplayPlayerPresenter>();
                panel.Init(new StringBuilder(playerInfo.NickName), new StringBuilder("0"));
                dicPlayerInfo.Add(playerInfo.NickName, panel);
            }
        }

        private void SwapPlayerTeam(Player playerInfo)
        {
            int teamIndex = (int)ETeam.BLUETEAM;
            if ((int)playerInfo.CustomProperties["Team"] == (int)ETeam.REDTEAM)
            {
                teamIndex = (int)ETeam.REDTEAM;
            }

            dicPlayerInfo[playerInfo.NickName].SetTeam(trTeamPanel[teamIndex]);
        }
        private int GetTeamIndex()
        {
            Room curRoom = PhotonNetwork.CurrentRoom;
            if ((int)curRoom.CustomProperties["RT"] > (int)curRoom.CustomProperties["BT"])
            {
                return (int)ETeam.REDTEAM;
            }
            Debug.Log("GetTeamIndex()");
            return (int)ETeam.BLUETEAM;
        }
        private int GetTeamIndex(StringBuilder stbTeam)
        {
            if (stbTeam.ToString() == "RT")
            {
                return (int)ETeam.REDTEAM;
            }
            Debug.Log("GetTeamIndex(Param)");
            return (int)ETeam.BLUETEAM;
        }

    }
}