using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace Orpul1
{
    public static class UIEventBus
    {
        public enum UIEventType
        {
            STARTGAME,
            SETMASTER,
            ACTIVEMATCHINGPANEL,
            ACTIVEROOMLISTPANEL,
            DEACTIVEROOMLISTPANEL,
            DEACTIVECREATEROOMPANEL,
            ACTIVECUSTOMROOMPANEL,
            DEACTIVECUSTOMROOMPANEL,
            ACTIVEWAITMATCHPANEL,
            DEACTIVEWAITMATCHPAENL,
        }
        private static Dictionary<UIEventType, UnityEvent> dicUIEvent = new Dictionary<UIEventType, UnityEvent>();
        public static void Subscribe(UIEventType eventType, UnityAction action)
        {
            if (!dicUIEvent.ContainsKey(eventType))
            {
                dicUIEvent.Add(eventType, new UnityEvent());
            }
            dicUIEvent[eventType].AddListener(action);


        }
        public static void UnSubscribe(UIEventType eventType, UnityAction action)
        {
            if (!dicUIEvent.ContainsKey(eventType)) return;
            dicUIEvent[eventType].RemoveListener(action);
        }
        public static void Publish(UIEventType eventType)
        {
            if (!dicUIEvent.ContainsKey(eventType)) return;
            dicUIEvent[eventType]?.Invoke();
        }

    }

}

