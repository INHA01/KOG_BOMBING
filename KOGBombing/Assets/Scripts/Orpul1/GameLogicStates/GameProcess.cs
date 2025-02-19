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
    
    RaiseEventOptions options = new RaiseEventOptions();
    GameRoundData roundData = new GameRoundData();
    [SerializeField]
    float roundInterval = 20;
    [SerializeField]
    float time = 0;
    bool isEndRound = false;
    public override void EnterState()
    {
        int attackTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["RT"];
        int defenceTeamCnt = (int)PhotonNetwork.CurrentRoom.CustomProperties["BT"];
        roundData.SetTeamCount((int)ETeam.REDTEAM, attackTeamCnt);
        roundData.SetTeamCount((int)ETeam.BLUETEAM, defenceTeamCnt);

        PhotonNetwork.NetworkingClient.EventReceived += OnSetTeamCount;
        isEndRound = false;
        time = 0;
    }
    public override void UpdateState()
    {
        DoRoundCountDown();
        if (isEndRound)
        {
            roundData.SetTeamScore();
            transitionState((int)roundData.GetNextState());
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
        roundData.SetTeamCount(teamType, -1);
        isEndRound = roundData.IsExterminateTeam();
        Debug.Log($"RT {roundData.TeamScores[(int)ETeam.REDTEAM]} BT {roundData.TeamScores[(int)ETeam.BLUETEAM]}");
    }

    private void DoRoundCountDown()
    {
        time += Time.deltaTime;
        if (time > roundInterval) 
        {
            roundData.RoundTimeOver();
            isEndRound = true;
            time = 0;
        }
    }
    private void RedayNextRound()
    {
        transitionState((int)EGameState.ROUNDWAIT);
    }

    public void SetTeamCount(int teamType)
    {
        // TODO : 팀 감소 동기화
        PhotonNetwork.RaiseEvent((int)EGameEvent.EXTERMINATETEAM, teamType, options, SendOptions.SendReliable);
    }

    public void ExplosionBomb()
    {
        roundData.ExplosionBomb();
        isEndRound = true;
    }

    public void ClearBomb()
    {
        isEndRound = true;
    }
}
