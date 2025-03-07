using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Subject : MonoBehaviour
{
    public event Action OnNotify;
    public event Action<int> OnNotifyParam;

    #region OnNotify
    public virtual void Notify()
    {
         OnNotify?.Invoke();
    }
    public void AddObserver(Observer observer)
    {
        OnNotify += observer.OnNotify;
    }
    public void RemoveObserver(Observer observer)
    {
        OnNotify -= observer.OnNotify;
    }
    #endregion

    #region OnNotifyParam
    public virtual void Notify(int index)
    {
        OnNotifyParam?.Invoke(index);
    }
    public void AddObserverParam(Observer observer)
    {
        OnNotifyParam += observer.OnNotifyParam;
    }
    public void RemoveObserverParam(Observer observer)
    {
        OnNotifyParam -= observer.OnNotifyParam;
    }
    #endregion
    public void RemoveAllObserver()
    {
        OnNotify = null;
        OnNotifyParam = null;
    }
}
