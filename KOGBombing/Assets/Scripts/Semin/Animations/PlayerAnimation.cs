using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerAnimation : MonoBehaviour
{
    [SerializeField] Animator animator;
	[SerializeField] GameObject model;
	GameObject playerObj;
	Vector3 pointToLookAt;

	void Start()
    {
        
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

		Ray cameraRay = Camera.main.ScreenPointToRay(Input.mousePosition);
		Plane GroupPlane = new Plane(Vector3.up, Vector3.zero);
		float rayLength;

		if (GroupPlane.Raycast(cameraRay, out rayLength))
		{
			Vector3 pointTolook = cameraRay.GetPoint(rayLength);
			Vector3 targetDirection = (pointTolook - model.transform.position).normalized;
			float angle = Vector3.SignedAngle(model.transform.forward, targetDirection, Vector3.up);

			if (speedValue.magnitude < 0.1f)
			{
				if (Mathf.Abs(angle) > 0.5f)
					animator.SetBool("Rotation", true);
				else animator.SetBool("Rotation", false);
			}
			else animator.SetBool("Rotation", false);

			model.transform.LookAt(pointTolook);
		}
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
