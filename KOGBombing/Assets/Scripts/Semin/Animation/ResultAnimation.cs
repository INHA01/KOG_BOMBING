using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResultAnimation : MonoBehaviour
{
    Animator animator;
    public bool isMvp;
    void Start()
    {
        animator = GetComponent<Animator>();
        if (isMvp)
            animator.SetTrigger("Mvp");
    }

	private void OnEnable()
	{
        if (animator == null)
			animator = GetComponent<Animator>();

		if (isMvp)
			animator.SetTrigger("Mvp");
	}
}
