using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class ViewObserver : Observer
{
    [SerializeField] protected float finshLerpTime = 0.3f;
    protected Coroutine lerpValue;
    public override void OnNotifyParam(int index)
    {
        SetPlayerSight(index);
    }
    protected virtual void SetPlayerSight(int isZoom)
    {
        // Start LerpValue Coroutine
    }
}
