using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RoundDoorController : MonoBehaviour
{
    [SerializeField]
    Animator animator;
    public void OpenDoor()
    {
        animator.SetTrigger("TriOpenDoor");
    }
    public void CloseDoor()
    {
        animator.SetTrigger("TriCloseDoor");
    }
}
