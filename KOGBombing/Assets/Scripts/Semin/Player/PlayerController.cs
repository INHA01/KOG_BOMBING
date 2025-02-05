using UnityEngine;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using Photon.Pun;
using System.Text;
using Semin;
using System;
using System.Collections;
using Photon.Realtime;
using ExitGames.Client.Photon;

public class PlayerController : MonoBehaviour, IPunObservable
{
	[SerializeField]
    public PlayerBlackBoard blackBoard;
	[SerializeField] 
	PlayerAnimation animator;
	public ISupportWeapon supportWeapon;
	[SerializeField] HpBar hpBar;

    public Action<string,float> updateProfile;
	public int teamIndex;

	public Dictionary<EKey, bool> Inputs { get { return blackBoard.inputs; } }

	PlayerInteract playerInteract;
	Camera viewCamera;

	Coroutine animChange;
	bool isChangableAnim;
	public Vector3 SpawnPoint { set { blackBoard.spawnPoint = value; } }
	TeamUIController teamUIController = new TeamUIController();
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
	PlayerMaterialController playerMaterialController;
	
    void Awake()
	{
		PhotonNetwork.NetworkingClient.EventReceived += UpdateUI;

        playerData = GetComponent<PlayerData>();
		attackRange = new AttackRange();
		playerInteract =  new PlayerInteract();
        playerShooting = GetComponent<PlayerShooting>();
		playerMaterialController = GetComponent<PlayerMaterialController>();

		attackRange.Init(playerData.playerObj.transform, playerData);
		playerInteract.Init(transform);
		playerShooting.Init(playerData.animator,attackRange);
		playerMaterialController.Init(playerData.changeMaterialMeshs, playerData.hitMaterial);

		for (int i = 0; i < (int)EKey.MAX; i++)
            blackBoard.inputs.Add((EKey)i, false);
		blackBoard.hp = blackBoard.maxHp;
		blackBoard.defence = blackBoard.maxDefence;

        playerData.rigidBody = GetComponent<Rigidbody>();
        blackBoard.rigidBody = GetComponent<Rigidbody>();
       
        if (playerData.pv.IsMine)
        {
            blackBoard.nickname = PhotonNetwork.LocalPlayer.NickName;
        }
        else
            blackBoard.nickname = playerData.pv.Owner.NickName;

        SetTeamFieldOfView();
	}
	
    private void Start()
	{
        if (playerData.pv.IsMine)
            playerData.pv.RPC("SendBlackBoard", RpcTarget.AllBuffered);

        if (viewCamera == null)
			viewCamera = Camera.main;
		teamIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties["TeamIndex"];

        string team = (string)playerData.pv.Owner.CustomProperties["Team"];

        if (team == "RT")
		{
			playerData.supportWeapon = gameObject.AddComponent<ThrowableWeapon>();
			if (playerData.supportWeapon is SupportWeaponBase support)
				support.SetConsum(WeaponType.MOLOTOV);
		}
		else
		{
			playerData.supportWeapon = gameObject.AddComponent<DeployableWeapon>();
			if (playerData.supportWeapon is SupportWeaponBase support)
				support.SetConsum(WeaponType.LANDMINE);
		}

		if ((string)PhotonNetwork.LocalPlayer.CustomProperties["Team"] != team)
		{
			if (!playerData.pv.IsMine)
				playerMaterialController.SetOtherTeamMaterial(playerData.changeMaterials);
			hpBar.SetIsMyTeam(true);
        }
		else hpBar.SetIsMyTeam(false);

		playerData.supportWeapon.SetTeam(team);
		playerData.animator.Init(playerData.playerObj, team, playerData.shootStartPos);

		hpBar.Init(blackBoard.maxHp, blackBoard.maxDefence);
		SetTeamFieldOfView();
		playerMaterialController.SaveCurrentMaterial();
        //StartCoroutine(DamageTest(0.5f, 10));
        
		//StartCoroutine(DamageTest(0.5f, 40));
	

		StartCoroutine(CoWaitSetTeamUI());

    }
    [PunRPC]
    private void SendBlackBoard()
    {
        Managers.PunData.AddPlayerBlackBoard(playerData.pv.Owner.NickName, blackBoard);
    }

    IEnumerator CoWaitSetTeamUI()
	{
		while(!Managers.PunData.IsDataAllGet)
			yield return null;
		if (playerData.pv.IsMine)
			teamUIController.SetTeamUI(playerShooting);
    }
	public void SetCamera(Camera cam)
	{
		viewCamera = cam;
	}

	//public IEnumerator DamageTest(float time, float damage)
	//{
	//	while (true)
	//	{
	//		yield return new WaitForSeconds(time);
	//		OnDamaged(damage);
	//	}
	//}

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
        if (!playerData.pv.IsMine) return;

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
				movement = transform.right * Time.deltaTime * blackBoard.moveSpeed * blackBoard.speedValue.x * playerData.speedDebuffPercent;
				blackBoard.rigidBody.MovePosition(blackBoard.rigidBody.position + movement);
				break;
			case EDirection.Up:
			case EDirection.Down:
				movement = transform.forward * Time.deltaTime * blackBoard.moveSpeed * blackBoard.speedValue.y * playerData.speedDebuffPercent;
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
	
	public void OnDamaged(float damage)
	{
        playerData.pv.RPC("Damage", RpcTarget.AllBuffered, damage);
		playerMaterialController.Hit();

		//포톤 RaiseEvent 발생
		teamUIController.UpdateTeamUI();
        if (playerData.pv.IsMine)
		{
			viewCamera.GetComponent<PlayerCamera>().Shake(0.15f, 0.25f);
        }
		Debug.Log("Ondamage Callback Test");
    }

    public void OnRigidity(float time)
    {
        playerData.pv.RPC("Rigidity", RpcTarget.AllBuffered, time);
    }

	IEnumerator ResetRigidity(float time)
	{
		yield return new WaitForSeconds(time);
		playerData.speedDebuffPercent = 1.0f;
	}
	
    [PunRPC]
	private void Damage(float damage)
	{
        float decreaseHp = blackBoard.defence - damage;
		blackBoard.defence = Mathf.Max(decreaseHp, 0);
		if ( decreaseHp < 0)
			blackBoard.hp += decreaseHp;
		hpBar.SetHpValue(blackBoard.hp, blackBoard.defence);

        
        if (blackBoard.hp <= 0)
        {
            this.transform.position = blackBoard.spawnPoint;
            blackBoard.hp = blackBoard.maxHp;
			blackBoard.defence = blackBoard.maxDefence;
			hpBar.InitializeValues();
		}
    }
	
	//포톤 RaiseEvent 발생 시 실행( eventcode = 실행 코드)
	private void UpdateUI(EventData photonEvent)
	{
		int eventcode = photonEvent.Code;
		if(eventcode == 0)
		{
			Player[] players = PhotonNetwork.PlayerList;
			string selfTeam = (string)PhotonNetwork.LocalPlayer.CustomProperties["Team"];
			string otherTeam = "";
			for(int i=0; i<players.Length; i++)
			{
				otherTeam = (string)players[i].CustomProperties["Team"];

                if (selfTeam == otherTeam)
				{
					float hp = Managers.PunData.GetPlayerBlackBoard(players[i].NickName).hp;

					if (updateProfile != null)
						updateProfile(players[i].NickName, hp);
				}
			}
		}

	}
    [PunRPC]
    private void Rigidity(float time)
	{
        playerData.speedDebuffPercent = 0.5f;
        StartCoroutine(ResetRigidity(time));
    }
}
