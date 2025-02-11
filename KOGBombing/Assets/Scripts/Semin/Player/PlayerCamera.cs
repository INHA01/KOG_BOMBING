using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerCamera : MonoBehaviour
{
	public GameObject target;
	public GameObject minimapCamera;

	public float offsetX = -3.0f;            
	public float offsetY = 7.0f;           
	public float offsetZ = -3f;
	float shakeX = 0;
	float shakeY = 0;

	public float CameraSpeed = 10.0f;
	Vector3 TargetPos;
	Coroutine shake;

    [SerializeField] float sensitivity = 300.0f;

    private void Start()
	{
		if (target == null)
		{
			target = GameObject.FindWithTag("Player");
        }
        TargetPos = new Vector3(
                    target.transform.position.x + offsetX + shakeX,
                    target.transform.position.y + offsetY + shakeY,
                    target.transform.position.z + offsetZ
                    );
        transform.position = TargetPos;
    }
    void FixedUpdate()
	{
		if (Input.GetMouseButton(1))
		{
			TargetRotation();
		}
		else
			this.transform.rotation = Quaternion.Lerp(this.transform.rotation, Quaternion.Euler(50, target.transform.eulerAngles.y, 0), Time.deltaTime * CameraSpeed);
    }

    void TargetRotation()
    {
        float mouseX = Input.GetAxis("Mouse X") * sensitivity * Time.deltaTime;
		target.transform.Rotate(Vector3.up * mouseX);
        minimapCamera.transform.rotation = Quaternion.Euler(90, target.transform.eulerAngles.y, 0);

        this.transform.rotation = Quaternion.Lerp(this.transform.rotation, Quaternion.Euler(30, target.transform.eulerAngles.y, 0), Time.deltaTime * CameraSpeed);
    }
    public void SetTarget(GameObject target)
	{
		this.target = target;
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
