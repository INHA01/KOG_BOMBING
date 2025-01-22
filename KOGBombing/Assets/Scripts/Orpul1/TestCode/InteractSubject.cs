using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Orpul1
{
    public class InteractSubject : MonoBehaviour, IInteractAble
    {
        Coroutine coroutine;
        [SerializeField]
        float interactEventTime = 0;
        [SerializeField]
        bool isDoneInteract = false;
        private void Awake()
        {
        }
        public void ProcessInteract()
        {
            if (isDoneInteract) return;
            if( coroutine == null)
            {
                Debug.Log("상호작용 시작!");
                coroutine = StartCoroutine(CoInteract());
            }
        }

        public void AbortInteract()
        {
            if (isDoneInteract) return;
            if (coroutine != null) 
            {
                Debug.Log("상호작용 중단!");
                StopCoroutine(coroutine);
                coroutine = null;
            }
        }
        IEnumerator CoInteract()
        {
            float time = Time.time + interactEventTime;
            while (Time.time < time) 
            {
                yield return null;
            }
            Debug.Log("상호작용 이벤트!");
            coroutine = null;
            isDoneInteract = true;
        }
    }
}
