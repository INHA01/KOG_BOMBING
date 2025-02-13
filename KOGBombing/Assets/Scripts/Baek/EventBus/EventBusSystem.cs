using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class EventBusSystem : MonoBehaviour
{
    static readonly UnityEvent Event = new UnityEvent();

    public static void Subscribe(UnityAction listener)
    {
        Event.AddListener(listener);
    }
    public static void Unsubscribe(UnityAction listener)
    {
        Event.RemoveListener(listener);
    }
    public static void Publish()
    {
        Event.Invoke();
    }
}
