using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Subject : MonoBehaviour
{
    public event Action OnNotify;

    public void Notify()
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
}
