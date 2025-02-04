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
    public void SetSubject(Subject subject)
    {
        this.subject = subject;
        Attach();
    }
    public void RemoveSubject()
    {
        Detach();
        this.subject = null;
    }
    protected void Attach()
    {
        if (subject != null)
        {
            subject.AddObserver(this);
        }
    }
    protected void Detach()
    {
        if (subject != null)
        {
            subject.RemoveObserver(this);
        }
    }
}
