using System.Collections;
using System.Collections.Generic;
using System.Text;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

namespace Orpul1
{
    public class PlayerListController : PhotonUpdateController<Player>
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

        public override void UpdateInfo(Player playerInfo, bool isRemoveInfo)
        {
            if(!dicPlayerInfo.ContainsKey(playerInfo.NickName))
            {
                int teamIndex = GetTeamIndex();
                GameObject playerPanelObj = Instantiate(playerPanelPref, trTeamPanel[teamIndex]);
                DisplayPlayerPresenter presenter = playerPanelObj.GetComponent<DisplayPlayerPresenter>();
                presenter.Init(new StringBuilder(playerInfo.NickName), new StringBuilder("0"));
                dicPlayerInfo.Add(playerInfo.NickName, presenter);
                return;
            }

            if (isRemoveInfo)
            {
                Destroy(dicPlayerInfo[playerInfo.NickName].gameObject);
                dicPlayerInfo.Remove(playerInfo.NickName);
            }
            else
            {
                SetPlayerTeam(playerInfo);
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
    }
}