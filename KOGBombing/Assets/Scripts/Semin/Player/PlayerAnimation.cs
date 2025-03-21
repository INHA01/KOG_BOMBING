using Orpul1;
using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class PlayerAnimation : MonoBehaviour,IPunObservable
{
	public enum AnimType
	{
		Throw,
		Granade,
        Cancel,
		Landmine,
		Bomb,
		Shoot,
		Groggy,
		Right,
		Left,
		Skill,
		DashEnd,
		BombDefuse,
		BombPlant,
        IsMoving,
        Rotation,
        MAX
	}

    [SerializeField] public Animator animator;
	[Range(1f, 20f)] public float RotateSpeed;
	[SerializeField] PhotonView pv;
	GameObject playerObj;
	Vector3 pointToLookAt;
	Vector3 speedValue;
	Vector3 netWorkPointToLookAt;
	Transform bulletPoint;

    void Awake()
    {
		if (animator == null)
			animator = GetComponent<Animator>();
    }

	public void Init(GameObject playerObj, ETeam team, Transform bulletPoint, CharacterType type)
	{
		this.playerObj = playerObj;
		if (team == ETeam.REDTEAM)
			animator.SetBool("IsAttackTeam", true);
		else if (team == ETeam.BLUETEAM)
			animator.SetBool("IsAttackTeam", false);
		this.bulletPoint = bulletPoint;
		animator.SetInteger("CharacterType", (int)type);
	}

	public void SetAnimTrigger(AnimType type,Vector3 pointLookAt)
	{
		animator.SetTrigger(type.ToString());
		if (type == AnimType.Throw)
			TurnAtForward(pointLookAt);
	}

	public void ResetAnimTrigger(AnimType type)
	{
		animator.ResetTrigger(type.ToString());
	}

	public bool GetAnimBool(AnimType type)
	{
		return animator.GetBool("Is" + type.ToString());
	}

	public void SetAnimBool(AnimType type, bool value)
	{
		if (type == AnimType.IsMoving)
			animator.SetBool(type.ToString(), value);
		else animator.SetBool("Is" + type.ToString(), value);
	}


	public void UpdateAnimation(Vector2 speedValue, Transform tr)
	{
		this.speedValue = speedValue;
		if (speedValue.magnitude <= 0.1f)
		{
			animator.SetFloat("Horizontal", speedValue.x);
			animator.SetFloat("Vertical", speedValue.y);
			return;
		}

		Quaternion rotation = Quaternion.Euler(0, -tr.localEulerAngles.y, 0);
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

	public void SetPointToLookAt(Vector3 pointToLookAt)
	{
		this.pointToLookAt = pointToLookAt;
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
				if (angle > 0)
				{
					SetAnimBool(AnimType.Right, true);
					SetAnimBool(AnimType.Left, false);
				}
				else
				{
					SetAnimBool(AnimType.Right, false);
					SetAnimBool(AnimType.Left, true);
				}

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

	public void Shoot(Vector3 pointLookAt)
	{
		TurnAtForward(pointLookAt);
		animator.SetTrigger("Shoot");
	}

	private void TurnAtForward(Vector3 pointLookAt)
	{
        Vector3 direction = pointLookAt - transform.position;
        direction.y = 0;
        Quaternion targetRotation = Quaternion.LookRotation(direction);
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, 50f * Time.deltaTime);
    }

	private void OnAnimatorIK(int layerIndex)
	{
		if (animator == null) return;
		if (pv.IsMine)
		{
			if (!GetCurAnim(AnimType.Skill))
				animator.SetLookAtPosition(pointToLookAt);
		}
		else
			animator.SetLookAtPosition(netWorkPointToLookAt);
		if (GetAnimBool(AnimType.Groggy))
		{
			animator.SetLookAtWeight(0f);
			animator.SetIKRotationWeight(AvatarIKGoal.RightHand, 0f);
		}
		else if (GetCurAnim(AnimType.Shoot))
		{
			animator.SetIKRotationWeight(AvatarIKGoal.RightHand, 1f);
			animator.SetIKRotation(AvatarIKGoal.RightHand, bulletPoint.rotation);
		}
		else animator.SetLookAtWeight(0.5f);
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

    public void ChangeWeapon(PlayerData playerData, int type)
    {
        for (int i = 0; i < playerData.weapons.Count; i++)
        {
            if (playerData.weapons[i].type == (WeaponType)type)
                playerData.weapons[i].obj.SetActive(true);
            else playerData.weapons[i].obj.SetActive(false);
        }
    }
}
