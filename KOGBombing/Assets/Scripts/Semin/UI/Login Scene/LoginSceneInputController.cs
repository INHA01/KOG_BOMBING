using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class LoginSceneInputController : MonoBehaviour
{
	[Header("Resources")]
	public GameObject splashScreen;
	public Login login;
	public Animator splashScreenAnimator;

	[Header("Settings")]
	public bool enablePressAnyKeyScreen;
	public bool enableLoginScreen;

	private void Awake()
	{
		enablePressAnyKeyScreen = true;
		splashScreenAnimator = splashScreen.GetComponent<Animator>();
	}

	public void OnPressAnyKeys(InputValue value)
	{
		if (enableLoginScreen == false && enablePressAnyKeyScreen == true)
		{
			splashScreenAnimator.Play("Press Any Key to Login");
			enablePressAnyKeyScreen = false;
			enableLoginScreen = true;
		}
	}
}
