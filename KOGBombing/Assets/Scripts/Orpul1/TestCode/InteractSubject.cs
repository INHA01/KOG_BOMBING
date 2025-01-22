using System.Collections;
using System.Collections.Generic;
using Orpul1;
using UnityEngine;

public class InteractSubject : MonoBehaviour, IInteractAble
{

    public void ProcessInteract()
    {
        Debug.Log("상호작용 시작!");
    }
    
    public void AbortInteract()
    {
        Debug.Log("상호작용 중단!");
    }
}
