using System.Collections;
using System.Collections.Generic;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using PhotnHashtable = ExitGames.Client.Photon.Hashtable;
using UnityEngine;
using TMPro;

namespace Orpul1
{
    public class GameProcess : GameProcessLogic
    {
        [SerializeField]
        float roundInterval;

        RoundController roundController = new RoundController();
        private void Start()
        {
            GetComponent<RoundEventListner>().Initialize(roundController);
        }
        private void OnDisable()
        {
            roundController.DoRemoveEvents();
        }
        public override void EnterState()
        {
            
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotnHashtable { { (int)EPropertyType.STATE, EPlayerState.START} });
            PhotonNetwork.NetworkingClient.EventReceived -= roundController.OnSetTeamCount;
            PhotonNetwork.NetworkingClient.EventReceived -= roundController.OnEndRound;
            PhotonNetwork.NetworkingClient.EventReceived += roundController.OnSetTeamCount;
            PhotonNetwork.NetworkingClient.EventReceived += roundController.OnEndRound;
            roundController.Initialize(gameData, roundInterval);
        }

        public override void UpdateState()
        {
            roundController.DoRoundCountDown();
            if (!roundController.IsEndRound) return;
            if(PhotonNetwork.IsMasterClient)
            {
                object[] datas = roundController.GetEndEvnetDatas();
                PhotonNetwork.RaiseEvent((int)PunEventType.ENDROUND, datas, gameData.options, SendOptions.SendReliable);
            }
            roundController.SetTeamScore();
            int nextState = (int)roundController.GetGameState();

            transitionState(nextState);
        }

        public override void ExitState()
        {
            PhotonNetwork.NetworkingClient.EventReceived -= roundController.OnSetTeamCount;
            PhotonNetwork.NetworkingClient.EventReceived -= roundController.OnEndRound;
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotnHashtable { { (int)EPropertyType.STATE, EPlayerState.READY } });
        }

    }

}
