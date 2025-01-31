using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;
using static UnityEngine.GraphicsBuffer;

public class PlayerAnimation : MonoBehaviour,IPunObservable
{
	public enum AnimType
	{
		Throw,
		Granade,
        Cancel,
		Landmine,
		MAX
	}

    [SerializeField] public Animator animator;
	[Range(1f, 20f)] public float RotateSpeed;
	[SerializeField] PhotonView pv;
	GameObject playerObj;
	Vector3 pointToLookAt;
	Vector3 speedValue;
	Vector3 netWorkPointToLookAt;

    void Awake()
    {
		if (animator == null)
			animator = GetComponent<Animator>();
    }

	public void SetPlayerObject(GameObject playerObj)
	{
		this.playerObj = playerObj;
	}

	public void SetTeam(string team)
	{
		if (team == "RT")
			animator.SetBool("IsAttackTeam", true);
		else if (team == "BT")
			animator.SetBool("IsAttackTeam", false);

	}

	public void SetAnimTrigger(AnimType type)
	{
		animator.SetTrigger(type.ToString());
		if (type == AnimType.Throw)
			TurnAtForward();
	}

	public void ResetAnimTrigger(AnimType type)
	{
		animator.ResetTrigger(type.ToString());
	}

	public bool GetAnimBool(AnimType type)
	{
		return animator.GetBool(type.ToString());
	}

	public void SetAnimBool(AnimType type, bool value)
	{
		animator.SetBool(type.ToString(), value);
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
        animator.SetBool("IsMoving", true);
    }

	public bool GetCurAnim(AnimType type)
    {
        AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(1);
		return stateInfo.IsName(type.ToString());
    }

	public void Rotation(Vector3 pointToLookAt, Vector3 speedValue)
    {
        AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(1);
		if (stateInfo.IsName("Throw"))
			return;

        this.pointToLookAt = pointToLookAt;
		Vector3 direction = pointToLookAt - transform.position;
		direction.y = 0;
		float angle = Vector3.SignedAngle(transform.forward, direction, Vector3.up);

		if (speedValue.magnitude < 0.1f)
        {
            animator.SetBool("IsMoving", false);
            float deltaAngle = Mathf.Abs(angle);
			if (deltaAngle < 0.5f)
				animator.SetBool("Rotation", false);
			else if (deltaAngle >= 60.0f)
			{
				animator.SetBool("IsMoving", true);
				animator.SetBool("Rotation", true);
			}
			if (animator.GetBool("Rotation") == true)
			{
				Quaternion targetRotation = Quaternion.LookRotation(direction);
				transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, RotateSpeed * Time.deltaTime);
			}
		}
		else
        {
            animator.SetBool("IsMoving", false);
            animator.SetBool("Rotation", false);
			Quaternion targetRotation = Quaternion.LookRotation(direction);
			transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, RotateSpeed * Time.deltaTime);
		}
	}

	public void Shoot()
	{
		TurnAtForward();
		animator.SetTrigger("Shoot");
	}

	private void TurnAtForward()
	{
        Vector3 direction = pointToLookAt - transform.position;
        direction.y = 0;
        Quaternion targetRotation = Quaternion.LookRotation(direction);
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, 50f * Time.deltaTime);
    }

	private void OnAnimatorIK(int layerIndex)
	{
		if (animator == null) return;
		if(pv.IsMine)
		{
			animator.SetLookAtPosition(pointToLookAt);
			animator.SetLookAtWeight(1.0f);
		}
		else
		{
			animator.SetLookAtPosition(netWorkPointToLookAt);
			animator.SetLookAtWeight(1.0f);
        }
	}

    public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info)
    {
		if(stream.IsWriting)
		{
			stream.SendNext(pointToLookAt);
		}
		else if(stream.IsReading)
		{
			netWorkPointToLookAt = (Vector3)stream.ReceiveNext();
        }
    }
}
