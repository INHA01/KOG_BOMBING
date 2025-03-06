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
        public void SetOtherTeam(int changeTeam)
        {
            ETeam curTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
            SetRoomTeamCount((int)curTeam, -1);
            SetRoomTeamCount(changeTeam, 1);
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { EPropertyType.TEAM.ToString(), changeTeam } });
        }
        private void SetRoomTeamCount(int teamType, int count)
        {
            int teamCnt = 0;
            EPropertyType propertyType = (EPropertyType)teamType;
            teamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties[propertyType.ToString()];
            PhotonNetwork.CurrentRoom.SetCustomProperties(new PhotonHashTable { { propertyType.ToString(), teamCnt + count } });

        }
    }

}
