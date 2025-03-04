using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class RoundDoorController : MonoBehaviour
{
    [SerializeField] InteractSound sound;
    [SerializeField]
    Animator animator;
    public void OpenDoor()
    {
        SoundManager.Instance.PlayEffect(sound.DoorSounds[(int)EDoorSound.OPEN], transform, 1, 0, 30);
        animator.SetTrigger("TriOpenDoor");
    }
    public void CloseDoor()
    {
        animator.SetTrigger("TriCloseDoor");
    }
}
