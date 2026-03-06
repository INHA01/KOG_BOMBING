using UnityEngine;
using System.Collections.Generic;

public class SubjectParam<T> : MonoBehaviour
{
    private readonly List<IObserverParam<T>> _observers = new List<IObserverParam<T>>();
    
    public void AddObserver(IObserverParam<T> observer)
    {
        _observers.Add(observer);
    }
    public void RemoveObserver(IObserverParam<T> observer)
    {
        _observers.Remove(observer);
    }
    public void ClearObservers()
    {
        _observers.Clear();
    }
    public virtual void Notify(T data)
    {
        foreach (IObserverParam<T> observer in _observers)
        {
            observer.OnNotify(data);
        }
    }
}
