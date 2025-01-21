using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static UnityEngine.GraphicsBuffer;

public class PlayerAnimation : MonoBehaviour
{
    [SerializeField] public Animator animator;
	[Range(1f, 20f)] public float RotateSpeed;
	[SerializeField] PhotonView pv;
	GameObject playerObj;
	Vector3 pointToLookAt;
	Vector3 speedValue;

	void Awake()
    {
		if (animator == null)
			animator = GetComponent<Animator>();
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
		this.pointToLookAt = pointToLookAt;
		Vector3 direction = pointToLookAt - transform.position;
		direction.y = 0;
		float angle = Vector3.SignedAngle(transform.forward, direction, Vector3.up);

		if (speedValue.magnitude < 0.1f)
		{
			float deltaAngle = Mathf.Abs(angle);
			if (deltaAngle < 0.5f)
				animator.SetBool("Rotation", false);
			else if (deltaAngle >= 60.0f)
				animator.SetBool("Rotation", true);
			if (animator.GetBool("Rotation") == true)
			{
				Quaternion targetRotation = Quaternion.LookRotation(direction);
				transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, RotateSpeed * Time.deltaTime);
			}
		}
		else
		{
			animator.SetBool("Rotation", false);
			Quaternion targetRotation = Quaternion.LookRotation(direction);
			transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, RotateSpeed * Time.deltaTime);
		}
	}

	public void Shoot()
	{
		Vector3 direction = pointToLookAt - transform.position;
		direction.y = 0;
		Quaternion targetRotation = Quaternion.LookRotation(direction);
		transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, 50f * Time.deltaTime);


		animator.SetTrigger("Shoot");
	}

	private void OnAnimatorIK(int layerIndex)
	{
		if (animator != null && pv.IsMine)
		{
			animator.SetLookAtPosition(pointToLookAt);
			animator.SetLookAtWeight(1.0f);
		}
	}

}
