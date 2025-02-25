using System;
using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

namespace Orpul1
{
    public abstract class PhotonPlayerWaitLogic : MonoBehaviourPunCallbacks, IState
    {
        [SerializeField]
        protected GameProcessData gameData;
        protected int readyPlayerCnt = 0;
        protected Action<int> transitionState;
        public void Initialize(Action<int> transition, GameProcessData logicContext)
        {
            transitionState = transition;
            this.gameData = logicContext;
            this.gameData.options.Receivers = ReceiverGroup.All;
        }
        public virtual void EnterState()
        {
            if (PhotonNetwork.IsMasterClient)
            {
                SetCurReadyPlayer();
                StartCoroutine(CoWaitPlayer());
            }
        }
        public abstract void UpdateState();
        public abstract void ExitState();

        protected abstract void SetCurReadyPlayer();
        protected abstract IEnumerator CoWaitPlayer();
    }
}
