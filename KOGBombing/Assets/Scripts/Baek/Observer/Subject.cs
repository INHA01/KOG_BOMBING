using UnityEngine;
using System.Collections.Generic;

public class Subject : MonoBehaviour
{
    private readonly List<IObserver> _observers = new List<IObserver>();

    public void AddObserver(IObserver observer)
    {
        _observers.Add(observer);
    }
    public void RemoveObserver(IObserver observer)
    {
        _observers.Remove(observer);
    }
    public void ClearObservers()
    {
        _observers.Clear();
    }
    public virtual void Notify()
    {
        foreach (IObserver observer in _observers)
        {
            observer.OnNotify();
        }
    }
}
