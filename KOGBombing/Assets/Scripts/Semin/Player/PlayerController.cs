using UnityEngine;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using Photon.Pun;
using System.Text;
using Semin;
using Unity.VisualScripting;


public class PlayerController : MonoBehaviour, IPunObservable
{
	[SerializeField] 
	public GameObject playerObj;
	[SerializeField] 
	PlayerAnimation animator;
	public ISupportWeapon supportWeapon;
	Rigidbody rigidBody;
	Dictionary<EKey, bool> inputs = new Dictionary<EKey, bool>(new EKeyComparer());
	PlayerInteract playerInteract = new PlayerInteract();
	public Dictionary<EKey, bool> Inputs { get { return inputs; } }
	public float moveSpeed = 6;
	Vector2 speedValue = Vector2.zero;
	Vector2 mousePos = Vector2.zero;
	Camera viewCamera;

	// �������� �׽�Ʈ
	Vector3 networkPosi = Vector3.zero;
	Quaternion networkRotation = Quaternion.identity;

	public enum EDirection
	{
		Up,
		Down,
		Left,
		Right,
	}
    AttackRange attackRange;
    PlayerShooting playerShooting;
    PlayerData playerData;

    void Awake()
	{
        playerData = GetComponent<PlayerData>();
		attackRange = new AttackRange();
        playerShooting = GetComponent<PlayerShooting>();
        attackRange.Init(playerObj.transform, playerData);
		playerInteract.Init(transform);
		playerShooting.Init(animator,attackRange);

        for (int i = 0; i < (int)EKey.MAX; i++)
			inputs.Add((EKey)i, false);

		rigidBody = GetComponent<Rigidbody>();
		SetTeamFieldOfView();

		animator.SetPlayerObject(playerObj);

	}

	private void Start()
	{
		if (viewCamera == null)
			viewCamera = Camera.main;

		supportWeapon = gameObject.AddComponent<ThrowableWeapon>();

		if (supportWeapon is SupportWeaponBase support)
			support.SetConsum(SupportWeaponBase.WeaponType.Molotov);
		supportWeapon.SetTeam((string)playerData.pv.Owner.CustomProperties["Team"]);
		
		SetTeamFieldOfView();
	}

	public void SetCamera(Camera cam)
	{
		viewCamera = cam;
	}

	void SetTeamFieldOfView()
	{
		StringBuilder mineTeam = new StringBuilder((string)playerData.pv.Owner.CustomProperties["Team"]);

        if (!playerData.pv.IsMine)
		{
			StringBuilder otherTeam = new StringBuilder((string)PhotonNetwork.LocalPlayer.CustomProperties["Team"]);

            if (mineTeam.ToString() != otherTeam.ToString())
			{
				GetComponentInChildren<FieldOfView>().enabled = false;
			}
		}
	}

	private void Update()
	{
		if (animator != null)
			animator.UpdateAnimation(speedValue);
		if(attackRange != null)
            attackRange.ShowAttackArea();
	}

	#region Attack Node
	public INode.ENodeState Move(EDirection direction)
	{
		Vector3 movement;
		switch (direction)
		{
			case EDirection.Left:
			case EDirection.Right:
				movement = transform.right * Time.deltaTime * moveSpeed * speedValue.x;
				rigidBody.MovePosition(rigidBody.position + movement);
				break;
			case EDirection.Up:
			case EDirection.Down:
				movement = transform.forward * Time.deltaTime * moveSpeed * speedValue.y;
				rigidBody.MovePosition(rigidBody.position + movement);
				break;
		}


		return INode.ENodeState.Success;
	}
	public INode.ENodeState FindInteractObj()
	{
		if (playerInteract.FindInteractObj() == false)
			return INode.ENodeState.Fail;
		return INode.ENodeState.Success;
	}
	public INode.ENodeState ProcessInteractive()
	{
		playerInteract.ProcessInteract();
        return INode.ENodeState.Success;
	}
	public INode.ENodeState AbortInteract()
	{
        playerInteract.AbortInteract();
		inputs[EKey.F] = false;
        return INode.ENodeState.Success;
    }
	public INode.ENodeState RotatePlayer()
	{
		Ray cameraRay = viewCamera.ScreenPointToRay(mousePos);
		Plane GroupPlane = new Plane(Vector3.up, playerObj.transform.position);
		float rayLength;

		if (GroupPlane.Raycast(cameraRay, out rayLength))
		{
			Vector3 pointTolook = cameraRay.GetPoint(rayLength);
			playerData.mousePos = pointTolook;
			animator.Rotation(pointTolook, speedValue);

			playerObj.transform.LookAt(pointTolook);
		}

		return INode.ENodeState.Success;
	}

	public INode.ENodeState ShootBullet()
	{
        playerShooting.Shoot();
        return INode.ENodeState.Success;
    }

	public INode.ENodeState SetSupportWeapon()
	{

		if (supportWeapon is DeployableWeapon)
		{
			supportWeapon.SetWeapon(new SupportWeaponInfo(transform.position, (string)playerData.pv.Owner.CustomProperties["Team"]));
			supportWeapon.Use();
			inputs[EKey.NUM_2] = false;
			return INode.ENodeState.Success;
		}

		else if (supportWeapon is ThrowableWeapon)
		{
			Ray cameraRay = viewCamera.ScreenPointToRay(mousePos); 
			RaycastHit hit;

			if (Physics.Raycast(cameraRay, out hit)) // 레이캐스트 실행
			{
				Vector3 targetPoint = hit.point;
				supportWeapon.SetWeapon(new ThrowableWeaponInfo(playerData.shootStartPos.position, targetPoint, 
					playerObj.transform.eulerAngles.y, (string)playerData.pv.Owner.CustomProperties["Team"]));
			}

			if (inputs[EKey.LMOUSEBUTTON])
			{
				supportWeapon.Use();
				inputs[EKey.NUM_2] = false;
				inputs[EKey.LMOUSEBUTTON] = false;
				return INode.ENodeState.Success;
			}
			return INode.ENodeState.Running;
		}

		return INode.ENodeState.Running;
	}

	#endregion

	#region If Decorater Node
	public bool CheckInput(EKey key)
	{
		return inputs[key];
	}
	public bool IsInteracting()
	{
		return playerInteract.isInteracting;
	}
    #endregion
    #region Input System
    public void OnAttack(InputValue value)
	{
		inputs[EKey.LMOUSEBUTTON] = value.isPressed;
	}
    bool CheckMouseOutScreen(Vector2 mousePos)
    {
        return (mousePos.x >= 0 && mousePos.x <= Screen.width && mousePos.y >= 0 && mousePos.y <= Screen.height);
    }
	public void OnRotate(InputValue value)
	{
		if (!CheckMouseOutScreen(value.Get<Vector2>())) return;
        mousePos = value.Get<Vector2>();
    }
	
	public void OnMove(InputValue value)
	{
        if (!playerData.pv.IsMine) return;
        Vector2 inputVector = value.Get<Vector2>();
		speedValue.x = inputVector.x;
		speedValue.y = inputVector.y;
		inputVector.x = ConvertToThreeValues(value.Get<Vector2>().normalized.x);
		inputVector.y = ConvertToThreeValues(value.Get<Vector2>().normalized.y);

		switch(inputVector.x)
		{
			case -1:
				inputs[EKey.A] = true;
				break;
			case 0:
				inputs[EKey.A] = false;
				inputs[EKey.D] = false;
				break;
			case 1:
				inputs[EKey.D] = true;
				break;
		}

		switch (inputVector.y)
		{
			case -1:
				inputs[EKey.S] = true;
				break;
			case 0:
				inputs[EKey.W] = false;
				inputs[EKey.S] = false;
				break;
			case 1:
				inputs[EKey.W] = true;
				break;
		}
	}

	public void OnUseAttackConsum(InputValue value)
	{
		if (!playerData.pv.IsMine) return;
		
		if (inputs[EKey.NUM_2])
			supportWeapon.Disable();
		inputs[EKey.NUM_2] = !inputs[EKey.NUM_2];
	}

	public void OnInteract(InputValue value)
	{
        inputs[EKey.F] = value.isPressed;
    }

    public int ConvertToThreeValues(float value)
	{
		if (value > 0)  
			return 1;
		else if (value < 0)
			return -1;
		else
			return 0;
	}
    #endregion
    public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info)
    {
		if(stream.IsWriting)
		{
			stream.SendNext(transform.rotation);
			stream.SendNext(rigidBody.velocity);
		}
		else if(stream.IsReading)
		{
			transform.rotation = (Quaternion)stream.ReceiveNext();
			rigidBody.velocity = (Vector3)stream.ReceiveNext();
			float lag = Mathf.Abs((float)(PhotonNetwork.Time - info.SentServerTime));
            transform.position += rigidBody.velocity * lag;

        }
    }
    private void OnDrawGizmos()
    {
		Gizmos.DrawWireSphere(transform.position, 1);
    }

	public void OnDamaged(float damage)
	{
		playerData.hp -= damage;
		Debug.Log($"플레이어 {damage} 타격, 현재 체력: {playerData.hp}");
		if (playerData.hp < 0)
		{
			Debug.Log("죽음");
		}
	}
}
