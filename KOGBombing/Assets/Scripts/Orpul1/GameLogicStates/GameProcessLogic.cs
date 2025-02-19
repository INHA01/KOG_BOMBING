using System;
using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

public abstract class GameProcessLogic : MonoBehaviourPunCallbacks, IState
{
    protected Action<int> transitionState;
    public virtual void Initialize(Action<int> transition)
    {
        transitionState = transition;
    }
    public abstract void EnterState();
    public abstract void ExitState();
    public abstract void UpdateState();
}
