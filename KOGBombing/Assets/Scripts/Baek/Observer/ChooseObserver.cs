using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class ChooseObserver : MonoBehaviour, IObserver , IObserverParam<int>
{
    public void OnNotify()
    {
        Destroy(this.gameObject);
    }
    public void OnNotify(int index)
    {
        Choosing(index);
    }
    public abstract void Choosing(int index);
}
