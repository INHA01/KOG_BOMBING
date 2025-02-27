using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResultAnimation : MonoBehaviour
{
    Animator animator;
    public bool isMvp;
    public bool isUni;
    [SerializeField] GameObject gun;
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
        {
            gun.SetActive(!isUni);
            animator.SetTrigger("Mvp");
        }
	}
    void WeaponActive(int yes)
    {
        if(yes == 1)
            gun.SetActive(true);
        else
            gun.SetActive(false);
    }
}
