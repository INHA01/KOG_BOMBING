using System.Collections.Generic;
using System.Linq;
using System.Text;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;
namespace Orpul1
{
    public class PlayerListController : MonoBehaviourPunCallbacks
    {
     
        [SerializeField] GameObject playerPanelPref;
        [SerializeField] MatchData matchData;
        [SerializeField] Transform[] trTeamPanel;

        Dictionary<string, DisplayPlayerPresenter> dicPlayerInfo = new Dictionary<string, DisplayPlayerPresenter>();

        public override void OnJoinedRoom()
        {
            if (PhotonNetwork.CurrentLobby.Name != matchData.LobbyName.ToString()) return;
            Player[] players = PhotonNetwork.PlayerList;
            for(int i=0; i<players.Length; i++)
            {
                AddPlayerUI(players[i]);
            }
        }
        public override void OnPlayerEnteredRoom(Player newPlayer)
        {
            if (PhotonNetwork.CurrentLobby.Name != matchData.LobbyName.ToString()) return;
            AddPlayerUI(newPlayer);
        }
        public override void OnPlayerLeftRoom(Player otherPlayer)
        {
            if (PhotonNetwork.CurrentLobby.Name != matchData.LobbyName.ToString()) return;
            if (!dicPlayerInfo.ContainsKey(otherPlayer.NickName)) return; 
            
            Destroy(dicPlayerInfo[otherPlayer.NickName].gameObject);
            dicPlayerInfo.Remove(otherPlayer.NickName);
        }

        public override void OnLeftRoom()
        {
            if (PhotonNetwork.CurrentLobby.Name != matchData.LobbyName.ToString()) return;
            for (int i=0; i<dicPlayerInfo.Count; i++)
            {
                KeyValuePair<string, DisplayPlayerPresenter> playerInfo = dicPlayerInfo.ElementAt(i);
                Destroy(playerInfo.Value.gameObject);
            }
            dicPlayerInfo.Clear();
        }

        public override void OnPlayerPropertiesUpdate(Player targetPlayer, PhotonHashTable changedProps)
        {
            if (PhotonNetwork.CurrentLobby.Name != matchData.LobbyName.ToString()) return;
            if (!targetPlayer.CustomProperties.ContainsKey(EPropertyType.TEAM.ToString())) return;
            SetPlayerUIPosi(targetPlayer);
        }

        private void AddPlayerUI(Player playerInfo)
        {
            if (dicPlayerInfo.ContainsKey(playerInfo.NickName)) return;
            ETeam playerTeam = (ETeam)playerInfo.CustomProperties[EPropertyType.TEAM.ToString()];
            GameObject playerUi = Instantiate(playerPanelPref, trTeamPanel[(int)playerTeam]);
            DisplayPlayerPresenter panel = playerUi.GetComponent<DisplayPlayerPresenter>();
            panel.Init(new StringBuilder(playerInfo.NickName), new StringBuilder(Managers.UserData.userData.level));
            dicPlayerInfo.Add(playerInfo.NickName, panel);
        }

        private void SetPlayerUIPosi(Player playerInfo)
        {
            ETeam playerTeam = (ETeam)playerInfo.CustomProperties[EPropertyType.TEAM.ToString()];
            dicPlayerInfo[playerInfo.NickName].SetTeam(trTeamPanel[(int)playerTeam]);
        }

    }
}