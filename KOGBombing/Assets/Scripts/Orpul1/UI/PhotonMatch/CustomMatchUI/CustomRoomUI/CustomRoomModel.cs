using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomRoomModel : MonoBehaviour
{
    public Animator animator;
    Action updateUI;
    public void Init(Action updatUI)
    {
        this.updateUI = updatUI;
    }
    public void TurnBackScreen()
    {
        animator.SetBool("IsOut", true);
        updateUI();
        //StartCoroutine(FadeOut());

    }
    IEnumerator FadeOut()
    {
        yield return new WaitForSeconds(0.8f);
        updateUI();
    }
}
