using System.Collections;
using System.Collections.Generic;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using PhotnHashtable = ExitGames.Client.Photon.Hashtable;
using UnityEngine;

public class GameProcess : GameProcessLogic, ISetTeamCountable, IBombStateAble
{
    [SerializeField]
    float roundInterval = 20;
    [SerializeField]
    float time = 0;
    bool isEndRound = false;
    public override void EnterState()
    {
        int attackTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
        int defenceTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
        logicContext.roundData.SetTeamCount((int)ETeam.REDTEAM, attackTeamCnt);
        logicContext.roundData.SetTeamCount((int)ETeam.BLUETEAM, defenceTeamCnt);

        PhotonNetwork.NetworkingClient.EventReceived += OnSetTeamCount;
        isEndRound = false;
        time = 0;
    }
    public override void UpdateState()
    {
        DoRoundCountDown();
        if (isEndRound)
        {
            logicContext.roundData.SetTeamScore();
            transitionState((int)logicContext.roundData.GetNextState());
        }
    }

    public override void ExitState()
    {
        PhotonNetwork.NetworkingClient.EventReceived -= OnSetTeamCount;
    }
    private void OnSetTeamCount(EventData punEvent)
    {
        if ((int)punEvent.Code != (int)EGameEvent.EXTERMINATETEAM) return;
        int teamType = (int)punEvent.CustomData;
        logicContext.roundData.SetDecreaseTeamCount(teamType);
        isEndRound = logicContext.roundData.IsExterminateTeam();
        Managers.UI.ClosePopupUI("DieCanvas");
        Debug.Log($"RT {logicContext.roundData.TeamScores[(int)ETeam.REDTEAM]} BT {logicContext.roundData.TeamScores[(int)ETeam.BLUETEAM]}");
    }

    private void DoRoundCountDown()
    {
        time += Time.deltaTime;
        if (time > roundInterval) 
        {
            logicContext.roundData.RoundTimeOver();
            isEndRound = true;
            time = 0;
        }
    }

    public void SetTeamCount(int teamType)
    {
        // TODO : 팀 감소 동기화
        PhotonNetwork.RaiseEvent((int)EGameEvent.EXTERMINATETEAM, teamType, logicContext.options, SendOptions.SendReliable);
    }

    public void ExplosionBomb()
    {
        logicContext.roundData.ExplosionBomb();
        isEndRound = true;
    }

    public void ClearBomb()
    {
        isEndRound = true;
    }
}
