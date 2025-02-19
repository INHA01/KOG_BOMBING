using System;
using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

public abstract class PhotonPlayerWaitLogic : MonoBehaviourPunCallbacks,IState
{
    protected int readyPlayerCnt = 0;
    protected Action<int> transitionState;
    public void Initialize(Action<int> transition)
    {
        transitionState = transition;
    }
    public virtual void EnterState()
    {
        if(PhotonNetwork.IsMasterClient)
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
