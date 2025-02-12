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
	public float offsetY = 6.0f;           
	public float offsetZ = -3.0f;
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
		//Cursor.lockState = CursorLockMode.Locked;
        //Cursor.visible = false;
        //Vector3 cursorPosition = new Vector3(Screen.width / 2, 50, 0); // 50은 위쪽 위치 (y 좌표)
        //Cursor.SetCursor(null, cursorPosition, CursorMode.Auto);

    }
    void FixedUpdate()
	{
		if(Input.GetMouseButton(1))
		{
			TargetRotation();
		}
    }

    void TargetRotation()
    {
        float mouseX = Input.GetAxis("Mouse X") * sensitivity * Time.deltaTime;
		target.transform.Rotate(Vector3.up * mouseX);
		//target.transform.rotation = Quaternion.Lerp(target.transform.rotation, Quaternion.Euler(target.transform.eulerAngles.x, target.transform.eulerAngles.y + mouseX, target.transform.eulerAngles.z), Time.deltaTime * CameraSpeed);
        minimapCamera.transform.rotation = Quaternion.Euler(90, target.transform.eulerAngles.y, 0);

    }
    public void SetTarget(GameObject target)
	{
		this.target = target;
		this.transform.parent = target.transform;
        TargetPos = new Vector3(
                    target.transform.position.x + offsetX + shakeX,
                    target.transform.position.y + offsetY + shakeY,
                    target.transform.position.z + offsetZ
                    );
        transform.position = TargetPos;
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
