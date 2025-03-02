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
            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { (int)EPropertyType.ROOMSTATE, "Start" } });
            updateUI();
        }
        public void SetOtherTeam(int team)
        {
            ETeam changeTeam = (ETeam)team;
            ETeam curTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[(int)EPropertyType.TEAM];
            if (changeTeam == curTeam) return;
            SetRoomTeamCount(curTeam, -1);
            if (curTeam == ETeam.REDTEAM) changeTeam = ETeam.BLUETEAM;
            SetRoomTeamCount(changeTeam, 1);
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { (int)EPropertyType.TEAM, changeTeam } });
        }
        private void SetRoomTeamCount(ETeam teamType, int count)
        {
            int teamCnt = 0;
            StringBuilder stbTeam = new StringBuilder();
            EPropertyType propertyType = EPropertyType.BLUETEAM;
            if (teamType == ETeam.BLUETEAM)
            {
                teamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[(int)EPropertyType.BLUETEAM];
                stbTeam.Append((int)EPropertyType.BLUETEAM);
            }
            else
            {
                teamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[(int)EPropertyType.REDTEAM];
                stbTeam.Append((int)EPropertyType.REDTEAM);
                propertyType = EPropertyType.REDTEAM;
            }

            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { propertyType, teamCnt + count } });

        }
    }

}
