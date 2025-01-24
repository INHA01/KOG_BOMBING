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
        public enum ETeamType
        {
            REDTEAM = 0,
            BLUETEAM
        }
        [SerializeField]
        GameObject playerPanelPref;

        [SerializeField]
        Transform[] trTeamPanel;

        Dictionary<string, DisplayPlayerPresenter> dicPlayerInfo = new Dictionary<string, DisplayPlayerPresenter>();

        public override void OnJoinedRoom()
        {
            if (PhotonNetwork.CurrentLobby.Name != "CustomLobby") return;
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
                SetPlayerTeam(targetPlayer);
            }
        }
        
        private void UpdatePlayer(Player playerInfo)
        {
            if(!dicPlayerInfo.ContainsKey(playerInfo.NickName))
            {
                int teamIndex = 0;
                if ((string)playerInfo.CustomProperties["Team"]!=null)
                {
                    teamIndex = GetTeamIndex(new StringBuilder(playerInfo.CustomProperties["Team"].ToString()));
                }
                else
                {
                    teamIndex = GetTeamIndex();
                }
                GameObject playerPanelObj = Instantiate(playerPanelPref, trTeamPanel[teamIndex]);
                DisplayPlayerPresenter presenter = playerPanelObj.GetComponent<DisplayPlayerPresenter>();
                presenter.Init(new StringBuilder(playerInfo.NickName), new StringBuilder("0"));
                dicPlayerInfo.Add(playerInfo.NickName, presenter);
            }
        }

        public void RemoveAllInfo()
        {
            List<string> keyList = new List<string>(dicPlayerInfo.Keys);
            for (int i=0; i< keyList.Count; i++)
            {
                Destroy(dicPlayerInfo[keyList[i]].gameObject);
                dicPlayerInfo.Remove(keyList[i]);
            }
        }
        private void SetPlayerTeam(Player playerInfo)
        {
            if ((string)playerInfo.CustomProperties["Team"] == "RT")
            {
                dicPlayerInfo[playerInfo.NickName].SetTeam(trTeamPanel[(int)ETeamType.REDTEAM]);
            }
            else
            {
                dicPlayerInfo[playerInfo.NickName].SetTeam(trTeamPanel[(int)ETeamType.BLUETEAM]);
            }
        }
        private int GetTeamIndex()
        {
            Room curRoom = PhotonNetwork.CurrentRoom;
            if ((int)curRoom.CustomProperties["RT"] > (int)curRoom.CustomProperties["BT"])
            {
                return (int)ETeamType.REDTEAM;
            }

            return (int)ETeamType.BLUETEAM;
        }
        private int GetTeamIndex(StringBuilder stbTeam)
        {
            if (stbTeam.ToString() == "RT")
            {
                return (int)ETeamType.REDTEAM;
            }
            return (int)ETeamType.BLUETEAM;
        }

    }
}