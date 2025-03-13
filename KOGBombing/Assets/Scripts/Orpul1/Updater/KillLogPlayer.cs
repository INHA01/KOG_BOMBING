using System.Text;
using Orpul1;

public class KillLogPlayer
{
    public StringBuilder nickname;
    public ETeam team;
    public KillLogPlayer(StringBuilder nickname, ETeam team)
    {
        this.nickname = nickname;
        this.team = team;
    }
}