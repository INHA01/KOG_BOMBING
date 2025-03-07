using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public abstract class ViewObserver : Observer
{
    [SerializeField] protected float finshLerpTime = 0.3f;
    protected Coroutine lerpValue;
    public override void OnNotify()
    {
        
    }
    public override void OnNotifyParam(int index)
    {
        SetPlayerSight(index);
    }
    protected abstract void SetPlayerSight(int isZoom);
}
