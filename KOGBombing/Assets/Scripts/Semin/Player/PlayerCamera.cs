using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCamera : MonoBehaviour
{
	public GameObject target;               

	public float offsetX = -3.0f;            
	public float offsetY = 7.0f;           
	public float offsetZ = -3f;          

	public float CameraSpeed = 10.0f;
	Vector3 TargetPos;

	private void Start()
	{
		if (target == null)
			target = GameObject.FindWithTag("Player");
	}

	// Update is called once per frame
	void FixedUpdate()
	{
		TargetPos = new Vector3(
			target.transform.position.x + offsetX,
			target.transform.position.y + offsetY,
			target.transform.position.z + offsetZ
			);

		transform.position = Vector3.Lerp(transform.position, TargetPos, Time.deltaTime * CameraSpeed);
	}
}
