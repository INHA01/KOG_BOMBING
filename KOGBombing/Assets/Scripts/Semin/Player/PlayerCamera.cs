using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerCamera : ViewObserver
{
	public GameObject target;
	public GameObject minimapCamera;

	public float offsetX = -3.0f;            
	public float offsetY = 6.0f;           
	public float offsetZ = -3.0f;
	float shakeX = 0;
	float shakeY = 0;

	public float CameraSpeed = 10.0f;
	Coroutine shake;
    PlayerData playerData;

    [SerializeField] float sensitivity = 300.0f;
	[SerializeField] Quaternion initRotation = Quaternion.Euler(55f, 45f, 0);

    public void SettingTargetPos(Transform parent)
    {
        this.transform.SetParent(parent);
        this.transform.localPosition = new Vector3(offsetX, offsetY, offsetZ);
		transform.rotation = initRotation;
    }
    private void Start()
	{
		if (target == null)
		{
			target = GameObject.FindWithTag("Player");
        }
        playerData = target.GetComponent<PlayerData>();
		SetSubject(target.GetComponent<PlayerInputListner>(),true);
    }
    void FixedUpdate()
	{
		if(Input.GetMouseButton(1))
		{
            TargetRotation();
		}
    }
    protected override void SetPlayerSight(int isZoom)
    {
        if (lerpValue != null)
        {
            StopCoroutine(lerpValue);
            lerpValue = null;
        }
        if (isZoom == 1)
            lerpValue = StartCoroutine(ZoomCamera(30));
        else
            lerpValue = StartCoroutine(ZoomCamera(50));
    }
    private IEnumerator ZoomCamera(float angle)
    {
        float elapsedTime = 0f;
        while (elapsedTime < finshLerpTime)
        {
            this.transform.rotation 
                = Quaternion.Lerp(
                    this.transform.rotation, 
                    Quaternion.Euler(angle, target.transform.eulerAngles.y, 0), 
                    elapsedTime / finshLerpTime);
            elapsedTime += Time.deltaTime;
            yield return null;
        }
    }
    void TargetRotation()
    {
        float mouseX = Input.GetAxis("Mouse X") * sensitivity * Time.deltaTime;
		target.transform.Rotate(Vector3.up * mouseX);
        minimapCamera.transform.rotation = Quaternion.Euler(90, target.transform.eulerAngles.y, 0);

    }
    public void SetTarget(GameObject target)
	{
		this.target = target;
        SettingTargetPos(target.transform);
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
            this.transform.position = new Vector3(transform.position.x + shakeX, transform.position.y + shakeY, transform.position.z);

            elapsed += Time.deltaTime;
			yield return null;
            this.transform.localPosition = new Vector3(offsetX, offsetY, offsetZ);
		}
		shakeX = 0;
		shakeY = 0;
        shake = null;
	}
}
