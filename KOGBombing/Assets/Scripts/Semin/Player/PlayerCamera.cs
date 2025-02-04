using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

public class PlayerCamera : MonoBehaviour
{
	public GameObject target;               

	public float offsetX = -3.0f;            
	public float offsetY = 7.0f;           
	public float offsetZ = -3f;
	float shakeX = 0;
	float shakeY = 0;

	public float CameraSpeed = 10.0f;
	Vector3 TargetPos;
	Coroutine shake;

	private void Start()
	{
		if (target == null)
			target = GameObject.FindWithTag("Player");
	}

	// Update is called once per frame
	void FixedUpdate()
	{
		TargetPos = new Vector3(
			target.transform.position.x + offsetX + shakeX,
			target.transform.position.y + offsetY + shakeY,
			target.transform.position.z + offsetZ
			);

		transform.position = Vector3.Lerp(transform.position, TargetPos, Time.deltaTime * CameraSpeed);
	}

	public void Shake(float duration, float magnitude)
	{
		if (shake != null)
			StopCoroutine(shake);
		shake = StartCoroutine(StartShake(duration, magnitude));
	}

	IEnumerator StartShake(float duration, float magnitude)
	{
		float elapsed = 0.0f;
		while (elapsed < duration)
		{
			shakeX = Random.Range(-1f, 1f) * magnitude;
			shakeY = Random.Range(-1f, 1f) * magnitude;
			elapsed += Time.deltaTime;
			yield return null;
		}
		shakeX = 0;
		shakeY = 0;
		shake = null;
	}
}
