using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DisplayPlayerPresenter : MonoBehaviour
{
    public enum ETeamType
    {
        REDTEAM,
        BLUETEAM
    }
    [SerializeField] DisplayPlayerView view;
    DisplayPlayerModel model = new DisplayPlayerModel();
    
    public void SetPlayerUIInfo(Transform[] teams)
    {
        model.trTeams = teams;
    }

    public void SetTeam(ETeamType teamType)
    {
        if (teamType == ETeamType.REDTEAM)
            transform.SetParent(model.trTeams[(int)ETeamType.REDTEAM]);
        else
            transform.SetParent(model.trTeams[(int)ETeamType.BLUETEAM]);
    }
    
}
