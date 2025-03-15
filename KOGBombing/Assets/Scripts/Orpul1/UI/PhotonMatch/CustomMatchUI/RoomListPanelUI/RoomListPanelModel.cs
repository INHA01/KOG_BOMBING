using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RoomListPanelModel : MonoBehaviour
{
    public Animator animator;
    Action updateUI;
    public void Init(Action updatUI)
    {
        this.updateUI = updatUI;
    }
    public void TurnBackScreen()
    {
        StartCoroutine(FadeOut());

    }
    IEnumerator FadeOut()
    {
        animator.SetBool("IsOut", true);
        while (!animator.GetCurrentAnimatorStateInfo(0).IsName("Window Out")) yield return null;
        yield return new WaitForSeconds(animator.GetCurrentAnimatorStateInfo(0).length);
        updateUI();
    }
}
