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
        float roundInterval = 50;
        [SerializeField]
        float time = 0;

        RoundController roundController = new RoundController();
        TextMeshProUGUI timeTMP;
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
            timeTMP = Managers.UI.GetPopupUI<UIPopup>("PlayCanvas").GetComponent<PlayScene>().timer;
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotnHashtable { { "State", EPlayerState.START} });
            PhotonNetwork.NetworkingClient.EventReceived -= roundController.OnSetTeamCount;
            PhotonNetwork.NetworkingClient.EventReceived -= roundController.OnEndRound;
            PhotonNetwork.NetworkingClient.EventReceived += roundController.OnSetTeamCount;
            PhotonNetwork.NetworkingClient.EventReceived += roundController.OnEndRound;
            roundController.Initialize(gameData);
            time = 0;
        }

        public override void UpdateState()
        {
            DoRoundCountDown();
            Debug.Log("UpdateGameProcess");
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
            PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotnHashtable { { "State", EPlayerState.READY } });
        }

        private void DoRoundCountDown()
        {
            time += Time.deltaTime;
            timeTMP.text = string.Format("{0:00}:{1:00}", (int)(roundInterval - time) / 60, (int)(roundInterval - time) % 60);
            if (time > roundInterval)
            {
                roundController.SetRoundTimeOver();
                time = 0;
            }
        }
    }

}
