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
        protected LogicContext logicContext;
        protected Action<int> transitionState;
        public virtual void Initialize(Action<int> transition, LogicContext logicContext)
        {
            transitionState = transition;
            this.logicContext = logicContext;
            this.logicContext.options.Receivers = ReceiverGroup.All;
        }
        public abstract void EnterState();
        public abstract void ExitState();
        public abstract void UpdateState();
    }
}
