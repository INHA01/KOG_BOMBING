using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Observer : MonoBehaviour
{
    [SerializeField] Subject subject;

    public virtual void OnNotify()
    {
        // Observer logic
    }
    public virtual void OnNotifyParam(int index)
    {
        // Observer logic
    }
    public virtual void SetSubject(Subject subject , bool isParam)
    {
        this.subject = subject;
        Attach(isParam);
    }
    public virtual void RemoveSubject(bool isParam)
    {
        Detach(isParam);
        this.subject = null;
    }

    protected void Attach(bool isParam)
    {
        if (subject != null)
        {
            if (isParam)
                subject.AddObserverParam(this);
            else
                subject.AddObserver(this);
        }
    }
    protected void Detach(bool isParam)
    {
        if (subject != null)
        {
            if(isParam)
                subject.RemoveObserverParam(this);
            else
                subject.RemoveObserver(this);
        }
    }
}
