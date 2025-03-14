using System.Text;
using Orpul1;

namespace Orpul1
{
    public class PlayerInfo
    {
        public StringBuilder nickname;
        public ETeam team;
        public int teamIndex;
        public PlayerInfo(StringBuilder nickname, ETeam team, int teamIndex = 0)
        {
            this.nickname = nickname;
            this.team = team;
            this.teamIndex = teamIndex;
        }
    }
}
