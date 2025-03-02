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
            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { EPropertyType.ROOMSTATE.ToString(), "Start" } });
            updateUI();
        }
        public void SetOtherTeam(int team)
        {
            ETeam changeTeam = (ETeam)team;
            ETeam curTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
            if (changeTeam == curTeam) return;
            SetRoomTeamCount(curTeam, -1);
            if (curTeam == ETeam.REDTEAM) changeTeam = ETeam.BLUETEAM;
            SetRoomTeamCount(changeTeam, 1);
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { EPropertyType.TEAM.ToString(), changeTeam } });
        }
        private void SetRoomTeamCount(ETeam teamType, int count)
        {
            int teamCnt = 0;
            EPropertyType propertyType = EPropertyType.BLUETEAM;
            if (teamType == ETeam.BLUETEAM)
            {
                teamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[EPropertyType.BLUETEAM.ToString()];
            }
            else
            {
                teamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[EPropertyType.REDTEAM.ToString()];
                propertyType = EPropertyType.REDTEAM;
            }

            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { propertyType.ToString(), teamCnt + count } });

        }
    }

}
