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
                PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { {(int)EPropertyType.TEAM, ETeam.REDTEAM } });
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

        public override void OnLeftRoom()
        {
            if (PhotonNetwork.CurrentLobby.Name != "CustomLobby") return;
            for (int i=0; i<dicPlayerInfo.Count; i++)
            {
                KeyValuePair<string, DisplayPlayerPresenter> playerInfo = dicPlayerInfo.ElementAt(i);
                Destroy(playerInfo.Value.gameObject);
                Debug.Log($"delete Player UI {playerInfo.Key}");
            }
            dicPlayerInfo.Clear();
        }

        public override void OnPlayerPropertiesUpdate(Player targetPlayer, PhotonHashTable changedProps)
        {
            if (PhotonNetwork.CurrentLobby.Name != "CustomLobby") return;
            if (targetPlayer.CustomProperties.ContainsKey((int)EPropertyType.TEAM))
            {
                SwapPlayerTeam(targetPlayer);
            }
        }
        
        private void UpdatePlayer(Player playerInfo)
        {
            if(!dicPlayerInfo.ContainsKey(playerInfo.NickName))
            {
                ETeam teamIndex = 0;
                if (playerInfo.CustomProperties.ContainsKey((int)EPropertyType.TEAM))
                {
                    teamIndex = (ETeam)playerInfo.CustomProperties[(int)EPropertyType.TEAM];
                    Debug.Log($"{playerInfo.NickName} set {teamIndex.ToString()}");
                }
                else
                {
                    teamIndex = GetTeamIndex();
                }
                GameObject playerPanelObj = Instantiate(playerPanelPref, trTeamPanel[(int)teamIndex]);
                DisplayPlayerPresenter panel = playerPanelObj.GetComponent<DisplayPlayerPresenter>();
                panel.Init(new StringBuilder(playerInfo.NickName), new StringBuilder("0"));
                dicPlayerInfo.Add(playerInfo.NickName, panel);
            }
        }

        private void SwapPlayerTeam(Player playerInfo)
        {
            int teamIndex = (int)ETeam.BLUETEAM;
            if ((int)playerInfo.CustomProperties[(int)EPropertyType.TEAM] == (int)ETeam.REDTEAM)
            {
                teamIndex = (int)ETeam.REDTEAM;
            }

            dicPlayerInfo[playerInfo.NickName].SetTeam(trTeamPanel[teamIndex]);
        }
        private ETeam GetTeamIndex()
        {
            Room curRoom = PhotonNetwork.CurrentRoom;
            if ((int)curRoom.CustomProperties[(int)EPropertyType.REDTEAM] > (int)curRoom.CustomProperties[(int)EPropertyType.BLUETEAM])
            {
                return ETeam.BLUETEAM;
            }
            return ETeam.REDTEAM;
        }

    }
}