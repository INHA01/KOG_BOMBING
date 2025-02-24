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
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotnHashtable { { "State", EPlayerState.START} });
            PhotonNetwork.NetworkingClient.EventReceived += roundController.OnSetTeamCount;
            PhotonNetwork.NetworkingClient.EventReceived += roundController.OnEndRound;
            roundController.Initialize(logicContext);
            time = 0;
        }

        public override void UpdateState()
        {
            DoRoundCountDown();
            Debug.Log("UpdateGameProcess");
            if (!roundController.IsEndRound) return;
            Debug.Log("---END Round---");
            if(PhotonNetwork.IsMasterClient)
            {
                object[] datas = roundController.GetEndEvnetDatas();
                PhotonNetwork.RaiseEvent((int)PunEventType.ENDROUND, datas, logicContext.options, SendOptions.SendReliable);
            }
            Debug.Log("Next Transition State");
            roundController.SetTeamScore();
            int nextState = (int)roundController.GetGameState();

            transitionState(nextState);
        }

        public override void ExitState()
        {
            PhotonNetwork.NetworkingClient.EventReceived -= roundController.OnSetTeamCount;
            PhotonNetwork.NetworkingClient.EventReceived -= roundController.OnEndRound;
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotnHashtable { { "State", EPlayerState.READY } });
        }

        private void DoRoundCountDown()
        {
            time += Time.deltaTime;
            if (time > roundInterval)
            {
                roundController.SetRoundTimeOver();
                time = 0;
            }
        }
    }

}
