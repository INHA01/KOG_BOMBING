using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class ChooseObserver : Observer
{
    public override void OnNotify()
    {
        Destroy(this.gameObject);
    }
    public override void OnNotifyParam(int index)
    {
        Choosing(index);
    }
    public override void SetSubject(Subject subject, bool isParam)
    {
        base.SetSubject(subject, isParam);
        Attach(!isParam);
    }
    public abstract void Choosing(int index);
}
