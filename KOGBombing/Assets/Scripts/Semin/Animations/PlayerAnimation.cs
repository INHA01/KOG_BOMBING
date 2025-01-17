using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static UnityEngine.GraphicsBuffer;

public class PlayerAnimation : MonoBehaviour
{
    [SerializeField] public Animator animator;
	GameObject playerObj;
	Vector3 pointToLookAt;
	[Range(1f, 20f)]
	public float RotateSpeed;
	Vector3 speedValue;
	bool isRotate;

	void Awake()
    {
        animator = GetComponent<Animator>();
    }

    void Update()
    {
        
    }

	public void SetPlayerObject(GameObject playerObj)
	{
		this.playerObj = playerObj;
	}


	public void UpdateAnimation(Vector2 speedValue)
	{
		this.speedValue = speedValue;
		if (speedValue.magnitude <= 0.1f)
		{
			animator.SetFloat("Horizontal", speedValue.x);
			animator.SetFloat("Vertical", speedValue.y);
			return;
		}

		Quaternion rotation = Quaternion.Euler(0, -45, 0);
		Vector3 forward = playerObj.transform.forward;
		forward = rotation * forward;

		Vector3 right = playerObj.transform.right;
		right = rotation * right;

		float adjustedHorizontal = Vector3.Dot(new Vector3(speedValue.x, 0, speedValue.y), right);
		float adjustedVertical = Vector3.Dot(new Vector3(speedValue.x, 0, speedValue.y), forward);

		animator.SetFloat("Horizontal", adjustedHorizontal);
		animator.SetFloat("Vertical", adjustedVertical);
	}

	public void Rotation(Vector3 pointToLookAt, Vector3 speedValue)
	{
		isRotate = true;
		this.pointToLookAt = pointToLookAt;
		pointToLookAt.y -= 2.0f;
		Vector3 targetDirection = (pointToLookAt - transform.position).normalized;
		float angle = Vector3.SignedAngle(transform.forward, targetDirection, Vector3.up);

		if (speedValue.magnitude < 0.1f)
		{
			float deltaAngle = Mathf.Abs(angle);
			if (deltaAngle < 0.5f)
				animator.SetBool("Rotation", false);
			else if (deltaAngle < 60f) 
				isRotate = false;
			else
				animator.SetBool("Rotation", true);
			if (animator.GetBool("Rotation") == true)
			{
				Quaternion targetRotation = Quaternion.LookRotation(pointToLookAt - transform.position);
				transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, RotateSpeed * Time.deltaTime);
			}
		}
		else
		{
			animator.SetBool("Rotation", false);
			Quaternion targetRotation = Quaternion.LookRotation(pointToLookAt - transform.position);
			transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, RotateSpeed * Time.deltaTime);
		}
	}

	public void Shoot()
	{
		Ray cameraRay = Camera.main.ScreenPointToRay(Input.mousePosition);
		Plane GroupPlane = new Plane(Vector3.up, Vector3.zero);
		float rayLength;

		if (GroupPlane.Raycast(cameraRay, out rayLength))
		{
			Vector3 pointTolook = cameraRay.GetPoint(rayLength);
			transform.LookAt(pointTolook);
			Quaternion targetRotation = Quaternion.LookRotation(pointTolook - transform.position);
			transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, 10.0f * Time.deltaTime);
		}

        animator.SetTrigger("Shoot");
	}

	private void OnAnimatorIK(int layerIndex)
	{
		if (animator != null)
		{
			animator.SetLookAtPosition(pointToLookAt);
			animator.SetLookAtWeight(1.0f);
		}
	}

}
