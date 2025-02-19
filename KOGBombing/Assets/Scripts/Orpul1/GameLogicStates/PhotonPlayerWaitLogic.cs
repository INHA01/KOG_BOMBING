using System;
using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;

public abstract class PhotonPlayerWaitLogic : MonoBehaviourPunCallbacks, IState
{
    [SerializeField]
    protected LogicContext logicContext;
    protected int readyPlayerCnt = 0;
    protected Action<int> transitionState;
    public void Initialize(Action<int> transition)
    {
        transitionState = transition;
        logicContext = GetComponent<LogicContext>();
        logicContext.options.Receivers = ReceiverGroup.All;
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
