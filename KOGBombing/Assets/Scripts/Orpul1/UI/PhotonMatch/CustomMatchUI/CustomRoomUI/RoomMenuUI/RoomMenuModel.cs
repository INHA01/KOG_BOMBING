using Photon.Pun;
using System;
using System.Text;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public class RoomMenuModel
    {
        Action updateUI;
        public RoomMenuModel(Action updateUI)
        {
            this.updateUI = updateUI;
        }
        public void SetStartRoomState()
        {
            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { "RoomState", "Start" } });
            updateUI();
        }
        public void SetOtherTeam(int team)
        {
            ETeam changeTeam = (ETeam)team;
            ETeam curTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"];
            if (changeTeam == curTeam) return;
            SetRoomTeamCount(curTeam, -1);
            if (curTeam == ETeam.REDTEAM) changeTeam = ETeam.BLUETEAM;
            SetRoomTeamCount(changeTeam, 1);
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { "Team", changeTeam } });
        }
        private void SetRoomTeamCount(ETeam teamType, int count)
        {
            int teamCnt = 0;
            StringBuilder stbTeam = new StringBuilder();
            if (teamType == ETeam.BLUETEAM)
            {
                teamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
                stbTeam.Append("BT");
            }
            else
            {
                teamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
                stbTeam.Append("RT");
            }

            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { stbTeam.ToString(), teamCnt + count } });

        }
    }

}
