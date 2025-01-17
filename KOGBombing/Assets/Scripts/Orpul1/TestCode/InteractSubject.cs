using System.Collections;
using System.Collections.Generic;
using Orpul1;
using UnityEngine;

public class InteractSubject : MonoBehaviour, IInteractAble
{
    public void Interact()
    {
        Debug.Log("상호작용!");
    }
}
