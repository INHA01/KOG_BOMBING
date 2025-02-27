using System.Collections;
using System.Collections.Generic;
using System.Text;
using Orpul1;
using UnityEngine;

public interface IUpdateScore
{
    public void UpdatePlayerScore(StringBuilder playerIndex, EPlayerScore updateType);
    public void UpdateTeamScore(ETeam teamType,ETeamScore updateType);
}
