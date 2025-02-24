using System.Collections;
using System.Collections.Generic;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using PhotnHashtable = ExitGames.Client.Photon.Hashtable;
using UnityEngine;

namespace Orpul1
{
    public class GameProcess : GameProcessLogic
    {
        [SerializeField]
        float roundInterval = 20;
        [SerializeField]
        float time = 0;

        RoundController roundController = new RoundController();
        private void Start()
        {
            GetComponent<RoundEventListner>().Initialize(roundController);
        }
        public override void EnterState()
        {
            PhotonNetwork.NetworkingClient.EventReceived += roundController.OnSetTeamCount;
            roundController.Initialize(logicContext);
            time = 0;
        }

        public override void UpdateState()
        {
            DoRoundCountDown();
            if (!roundController.IsEndRound) return;
            Debug.Log("Next Transition State");
            roundController.SetTeamScore();
            int nextState = (int)roundController.GetGameState();

            transitionState(nextState);
        }

        public override void ExitState()
        {
            PhotonNetwork.NetworkingClient.EventReceived -= roundController.OnSetTeamCount;
        }

        private void DoRoundCountDown()
        {
            time += Time.deltaTime;
            if (time > roundInterval)
            {
                roundController.SetEndRound();
                time = 0;
            }
        }
    }

}
