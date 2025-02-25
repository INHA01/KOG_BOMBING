using System;
using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

namespace Orpul1
{
    public abstract class GameProcessLogic : MonoBehaviourPunCallbacks, IState
    {
        [SerializeField]
        protected GameProcessData gameData;
        protected Action<int> transitionState;
        public virtual void Initialize(Action<int> transition, GameProcessData logicContext)
        {
            transitionState = transition;
            this.gameData = logicContext;
            this.gameData.options.Receivers = ReceiverGroup.All;
        }
        public abstract void EnterState();
        public abstract void ExitState();
        public abstract void UpdateState();
    }
}
