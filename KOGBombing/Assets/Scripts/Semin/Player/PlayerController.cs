using UnityEngine;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using Photon.Pun;
using System.Text;
using Semin;
using System;
using System.Collections;
using UnityEditor.Animations;
[Serializable]
public class PlayerBlackBoard
{
    public float hp;
	public float maxHp;
    public float moveSpeed;
    public Rigidbody rigidBody;
    public Dictionary<EKey, bool> inputs = new Dictionary<EKey, bool>(new EKeyComparer());
    public Vector2 speedValue;
    public Vector2 mousePos;
	public Vector3 spawnPoint;
}

public class PlayerController : MonoBehaviour, IPunObservable
{
	[SerializeField]
    PlayerBlackBoard blackBoard;
	[SerializeField] 
	PlayerAnimation animator;
	public ISupportWeapon supportWeapon;
	public Dictionary<EKey, bool> Inputs { get { return blackBoard.inputs; } }

	PlayerInteract playerInteract;
	Camera viewCamera;

	Coroutine animChange;
	bool isChangableAnim;
	public Vector3 SpawnPoint { set { blackBoard.spawnPoint = value; } }
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
		playerInteract =  new PlayerInteract();
        playerShooting = GetComponent<PlayerShooting>();
        attackRange.Init(playerData.playerObj.transform, playerData);
		playerInteract.Init(transform);
		playerShooting.Init(playerData.animator,attackRange);

        for (int i = 0; i < (int)EKey.MAX; i++)
            blackBoard.inputs.Add((EKey)i, false);
		blackBoard.hp = blackBoard.maxHp;

        playerData.rigidBody = GetComponent<Rigidbody>();
        blackBoard.rigidBody = GetComponent<Rigidbody>();
		SetTeamFieldOfView();

        playerData.animator.SetPlayerObject(playerData.playerObj);

	}

	private void Start()
	{
		if (viewCamera == null)
			viewCamera = Camera.main;

		playerData.supportWeapon = gameObject.AddComponent<ThrowableWeapon>();
		//playerData.supportWeapon = gameObject.AddComponent<DeployableWeapon>();

		if (playerData.supportWeapon is SupportWeaponBase support)
			//support.SetConsum(WeaponType.LANDMINE);
			support.SetConsum(WeaponType.MOLOTOV);
        //playerData.supportWeapon.SetTeam((string)playerData.pv.Owner.CustomProperties["Team"]);
		playerData.animator.SetTeam((string)playerData.pv.Owner.CustomProperties["Team"]);
		playerData.animator.SetTeam("RT");

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
		if (playerData.animator != null)
            playerData.animator.UpdateAnimation(blackBoard.speedValue);
		if(attackRange != null)
            attackRange.ShowAttackArea();
    }

    void ChangeWeapon(WeaponType type)
    {
        for (int i = 0; i < playerData.weapons.Count; i++)
        {
            if (playerData.weapons[i].type == type)
                playerData.weapons[i].obj.SetActive(true);
            else playerData.weapons[i].obj.SetActive(false);
        }
    }

	IEnumerator WaitForChangeAnim(float waitTime, WeaponType type)
	{
		isChangableAnim = false;
        yield return new WaitForSeconds(waitTime);
        animChange = null;
		ChangeWeapon(type);
	}

    #region Attack Node
    public INode.ENodeState Move(EDirection direction)
	{
		Vector3 movement;
		switch (direction)
		{
			case EDirection.Left:
			case EDirection.Right:
				movement = transform.right * Time.deltaTime * blackBoard.moveSpeed * blackBoard.speedValue.x;
				blackBoard.rigidBody.MovePosition(blackBoard.rigidBody.position + movement);
				break;
			case EDirection.Up:
			case EDirection.Down:
				movement = transform.forward * Time.deltaTime * blackBoard.moveSpeed * blackBoard.speedValue.y;
                blackBoard.rigidBody.MovePosition(blackBoard.rigidBody.position + movement);
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
		blackBoard.inputs[EKey.F] = false;
        return INode.ENodeState.Success;
    }

	Vector3 debugRayHit = Vector3.zero;
	public INode.ENodeState RotatePlayer()
	{

        Ray cameraRay = viewCamera.ScreenPointToRay(blackBoard.mousePos);
        RaycastHit hit;
		if(Physics.Raycast(cameraRay, out hit , 100f,LayerMask.GetMask("BackGroundObj")))
        {
            Vector3 planePos = hit.point;
			planePos.y += 1.6f;
			Plane GroupPlane = new Plane(Vector3.up, planePos);
			float rayLength;
			if (GroupPlane.Raycast(cameraRay, out rayLength))
			{
				Vector3 pointTolook = cameraRay.GetPoint(rayLength);
				debugRayHit = pointTolook;
                /*playerData.mousePos = pointTolook;
                playerData.animator.Rotation(pointTolook, playerData.speedValue);
                playerData.playerObj.transform.LookAt(pointTolook);*/

                playerData.mousePos = pointTolook;
                playerData.animator.Rotation(pointTolook, blackBoard.speedValue);
                playerData.playerObj.transform.LookAt(pointTolook);
			}
		}


        return INode.ENodeState.Success;
	}

	public INode.ENodeState ShootBullet()
	{
        playerShooting.Shoot();
        return INode.ENodeState.Success;
    }

	public INode.ENodeState LayingLandmine()
	{
		if (playerData.supportWeapon is DeployableWeapon deploy)
		{
			if (isChangableAnim)
			{
				ChangeWeapon(WeaponType.NONE);
				animChange = StartCoroutine(WaitForChangeAnim(1.5f, WeaponType.GUN));
				playerData.supportWeapon.SetWeapon(new SupportWeaponInfo(transform.position));
				playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Landmine);
				playerData.supportWeapon.Use();
			}
			if (animChange != null)
			{
				return INode.ENodeState.Running;
			}
			else
			{
				isChangableAnim = true;
				blackBoard.inputs[EKey.NUM_2] = false;
				playerData.animator.ResetAnimTrigger(PlayerAnimation.AnimType.Landmine);
				return INode.ENodeState.Success;
			}
		}
		return INode.ENodeState.Fail;
	}

	public INode.ENodeState SetSupportWeapon()
    {
		if (playerData.supportWeapon is ThrowableWeapon throwable)
		{
            Ray cameraRay = viewCamera.ScreenPointToRay(blackBoard.mousePos); 
			RaycastHit hit;

			if (!isChangableAnim)
			{
				if (animChange != null)
					return INode.ENodeState.Running;
				else
				{
					Debug.Log("End anim");
                    blackBoard.inputs[EKey.LMOUSEBUTTON] = false;
					blackBoard.inputs[EKey.NUM_2] = false;
                    playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Granade, false);
					playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Cancel);
                    playerData.animator.ResetAnimTrigger(PlayerAnimation.AnimType.Cancel);
                    isChangableAnim = true;
                    return INode.ENodeState.Success;
                }
			}

			if (Physics.Raycast(cameraRay, out hit))
			{
				Vector3 targetPoint = hit.point;
                playerData.supportWeapon.SetWeapon(new ThrowableWeaponInfo(playerData.shootStartPos.position, targetPoint,
                    playerData.playerObj.transform.eulerAngles.y));
			}

			if (blackBoard.inputs[EKey.LMOUSEBUTTON])
			{
				animChange = StartCoroutine(WaitForChangeAnim(0.5f, WeaponType.GUN));
                playerData.supportWeapon.Use();
                playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Throw);
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
		return blackBoard.inputs[key];
	}
	public bool IsInteracting()
	{
		return playerInteract.isInteracting;
	}

	public bool IsAttackTeam()
	{
		return (string)playerData.pv.Owner.CustomProperties["Team"] == "RT";
		//return false;
	}

	public bool IsDefenceTeam()
	{
		//return true;
		return (string)playerData.pv.Owner.CustomProperties["Team"] == "BT";
	}

    #endregion
    #region Input System
    public void OnAttack(InputValue value)
	{
        blackBoard.inputs[EKey.LMOUSEBUTTON] = value.isPressed;
	}
    bool CheckMouseOutScreen(Vector2 mousePos)
    {
        return (mousePos.x >= 0 && mousePos.x <= Screen.width && mousePos.y >= 0 && mousePos.y <= Screen.height);
    }
	public void OnRotate(InputValue value)
	{
		if (!CheckMouseOutScreen(value.Get<Vector2>())) return;
        blackBoard.mousePos = value.Get<Vector2>();
    }
	
	public void OnMove(InputValue value)
	{
        if (!playerData.pv.IsMine) return;
        Vector2 inputVector = value.Get<Vector2>();
        blackBoard.speedValue.x = inputVector.x;
        blackBoard.speedValue.y = inputVector.y;
		inputVector.x = ConvertToThreeValues(value.Get<Vector2>().normalized.x);
		inputVector.y = ConvertToThreeValues(value.Get<Vector2>().normalized.y);

		switch(inputVector.x)
		{
			case -1:
				blackBoard.inputs[EKey.A] = true;
				break;
			case 0:
				blackBoard.inputs[EKey.A] = false;
				blackBoard.inputs[EKey.D] = false;
				break;
			case 1:
				blackBoard.inputs[EKey.D] = true;
				break;
		}

		switch (inputVector.y)
		{
			case -1:
				blackBoard.inputs[EKey.S] = true;
				break;
			case 0:
				blackBoard.inputs[EKey.W] = false;
				blackBoard.inputs[EKey.S] = false;
				break;
			case 1:
				blackBoard.inputs[EKey.W] = true;
				break;
		}
	}

	public void OnUseAttackConsum(InputValue value)
	{
		if (!playerData.pv.IsMine) return;

        isChangableAnim = true;
        WeaponType weaponType = WeaponType.GUN;
        blackBoard.inputs[EKey.NUM_2] = !blackBoard.inputs[EKey.NUM_2];

        if (blackBoard.inputs[EKey.NUM_2])
        {
            playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Granade, true);
            if (playerData.supportWeapon is SupportWeaponBase baseWeapon)
                weaponType = baseWeapon.consum.type;
		}
		else
        {
            playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Granade, false);
            playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Cancel);
            playerData.supportWeapon.Disable();
        }

		ChangeWeapon(weaponType);
    }

	public void OnInteract(InputValue value)
	{
		blackBoard.inputs[EKey.F] = value.isPressed;
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
			stream.SendNext(blackBoard.rigidBody.velocity);
		}
		else if(stream.IsReading)
		{
			transform.rotation = (Quaternion)stream.ReceiveNext();
            blackBoard.rigidBody.velocity = (Vector3)stream.ReceiveNext();
			float lag = Mathf.Abs((float)(PhotonNetwork.Time - info.SentServerTime));
            transform.position += blackBoard.rigidBody.velocity * lag;

        }
    }
    private void OnDrawGizmos()
    {
		Gizmos.color = Color.red;
		Gizmos.DrawWireSphere(debugRayHit, 0.1f);
    }

	public void OnDamaged(float damage)
	{
        blackBoard.hp -= damage;
		if (blackBoard.hp < 0)
		{
			this.transform.position = blackBoard.spawnPoint;
			blackBoard.hp = blackBoard.maxHp;
        }
	}
}
