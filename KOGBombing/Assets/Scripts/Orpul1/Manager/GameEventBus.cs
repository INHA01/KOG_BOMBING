using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static Orpul1.UIEventBus;
using UnityEngine.Events;

public class GameEventBus : MonoBehaviour
{
    public enum EGameEvent
    {
        DOOROPEN,
        DOORCLOSE,
        SETBOMB,
        EXPLOSIONBOMB,
        CLEARBOMB
    }
    private static Dictionary<EGameEvent, UnityEvent> dicUIEvent = new Dictionary<EGameEvent, UnityEvent>();
    public static void Subscribe(EGameEvent eventType, UnityAction action)
    {
        if (!dicUIEvent.ContainsKey(eventType))
        {
            dicUIEvent.Add(eventType, new UnityEvent());
        }
        dicUIEvent[eventType].AddListener(action);


    }
    public static void UnSubscribe(EGameEvent eventType, UnityAction action)
    {
        if (!dicUIEvent.ContainsKey(eventType)) return;
        dicUIEvent[eventType].RemoveListener(action);
    }
    public static void Publish(EGameEvent eventType)
    {
        if (!dicUIEvent.ContainsKey(eventType)) return;
        dicUIEvent[eventType]?.Invoke();
    }
}
