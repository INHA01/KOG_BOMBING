using UnityEngine;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using Photon.Pun;
using System.Text;
using Semin;
using System.Collections;
using Orpul1;
using System;
using Photon.Realtime;
using Unity.VisualScripting;
public class PlayerController : MonoBehaviour, IPunObservable
{
	[SerializeField]
    public PlayerBlackBoard blackBoard;
	[SerializeField] 
	PlayerAnimation animator;
	public ISupportWeapon supportWeapon;
	[SerializeField] HpBar hpBar;

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
	PlayerMaterialController playerMaterialController;
	TeamUIController teamUIController = new TeamUIController();
    void Awake()
	{
		blackBoard.isLive = true;
        playerData = GetComponent<PlayerData>();
		attackRange = new AttackRange();
		playerInteract =  new PlayerInteract();
        playerShooting = GetComponent<PlayerShooting>();
		playerMaterialController = GetComponent<PlayerMaterialController>();

		attackRange.Init(playerData.playerObj.transform, playerData);
		playerInteract.Init(transform);
		playerShooting.Init(playerData.animator,attackRange);
		playerMaterialController.Init(playerData.changeMaterialMeshs, playerData.hitMaterial);
		hpBar.Init(blackBoard.maxHp, blackBoard.maxDefence);

		for (int i = 0; i < (int)EKey.MAX; i++)
            blackBoard.inputs.Add((EKey)i, false);
		blackBoard.hp = blackBoard.maxHp;
		blackBoard.defence = blackBoard.maxDefence;

        playerData.rigidBody = GetComponent<Rigidbody>();
        blackBoard.rigidBody = GetComponent<Rigidbody>();
		//SetTeamFieldOfView();

		if (playerData.pv.IsMine)
		{
			blackBoard.nickname = PhotonNetwork.LocalPlayer.NickName;
			blackBoard.eTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"];

        }
		else
		{
			blackBoard.nickname = playerData.pv.Owner.NickName;
            blackBoard.eTeam = (ETeam)playerData.pv.Owner.CustomProperties["Team"];
        }
	}

	public IEnumerator DamageTest(float time, float damage)
	{
		OnDamaged(damage);
		yield return new WaitForSeconds(time);
		OnResurrect();
	}

	private void Start()
	{
		if (viewCamera == null)
			viewCamera = Camera.main;

        ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties["Team"];
		SetSupportWeapon((int)playerTeam);

		if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"] != playerTeam)
			SetOtherTeamInfo();
		else hpBar.SetIsMyTeam(true);

		playerData.supportWeapon.SetTeam(playerTeam);
		playerData.animator.Init(playerData.playerObj, playerTeam, playerData.shootStartPos);
		playerMaterialController.SaveCurrentMaterial();

		if(playerData.pv.IsMine)
		{
			playerData.pv.RPC("SendBlackBoard", RpcTarget.AllBuffered);
			StartCoroutine(WaitSetTeamUI());
		}
		//StartCoroutine(DamageTest(10f, 350));
	}
	[PunRPC]
	private void SendBlackBoard()
	{
        Managers.PunData.AddPlayerBlackBoard(playerData.pv.Owner.NickName, blackBoard);
    }
    IEnumerator WaitSetTeamUI()
	{
        while (!Managers.PunData.IsDataAllGet) yield return null;
		teamUIController.SetTeamUI(playerShooting);

    }
	public void SetCamera(Camera cam)
	{
		viewCamera = cam;
	}

	void SetSupportWeapon(int team)
	{
		if (team == (int)ETeam.REDTEAM)
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
	}
	
	void SetOtherTeamInfo()
	{
		if (!playerData.pv.IsMine)
		{
			playerMaterialController.SetOtherTeamMaterial(playerData.changeMaterials);
			blackBoard.fieldOfView.SetActive(false);
		}
		hpBar.SetIsMyTeam(false);
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
	public INode.ENodeState CanBehavior()
	{
        if (blackBoard.inputs[EKey.Escape])
			return INode.ENodeState.Success;
        return INode.ENodeState.Fail;
    }
	public INode.ENodeState SuccessNode()
	{
		return INode.ENodeState.Success;
	}
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

	//TODO : Set Camera Target
	public INode.ENodeState SetLookTarget()
	{
		List<PlayerBlackBoard> blackBoards = Managers.PunData.GetAllBlackBoard();
		Debug.Log($"TeamPlayer {blackBoards.Count}");
        for(int i=0; i<blackBoards.Count; i++)
		{
			if (blackBoards[i].eTeam != blackBoard.eTeam) continue;
			if (blackBoards[i].isLive)
			{
				Debug.Log("Find Target");
				blackBoard.gmlookTarget = blackBoards[i].rigidBody.gameObject;
                return INode.ENodeState.Success;
			}
		}
        Debug.Log("All Team Player Die");
		blackBoard.gmlookTarget = null;
        return INode.ENodeState.Fail;
    }
    public INode.ENodeState SetCameraTarget()
	{
		string nickname = blackBoard.gmlookTarget.GetComponent<PhotonView>().Owner.NickName;

        if (Managers.PunData.GetPlayerBlackBoard(nickname).isLive)
		{
			viewCamera.GetComponent<PlayerCamera>().SetTarget(blackBoard.gmlookTarget);
			return INode.ENodeState.Success;
		}
		blackBoard.gmlookTarget = null;
        return INode.ENodeState.Fail;
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
	
	public bool IsDie()
	{
		return !blackBoard.isLive;
	}
	public bool IsTargetDie()
	{
        if (blackBoard.gmlookTarget == null) return true;
		string name = blackBoard.gmlookTarget.GetComponent<PhotonView>().Owner.NickName;
        if (Managers.PunData.GetPlayerBlackBoard(name).isLive) return true;
        Debug.Log("IsTargetDie Return False");
        return false;
	}
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
		return (ETeam)playerData.pv.Owner.CustomProperties["Team"] == ETeam.REDTEAM;
	}

	public bool IsDefenceTeam()
	{
		return (ETeam)playerData.pv.Owner.CustomProperties["Team"] == ETeam.BLUETEAM;
	}
	public bool IsNotGroggy()
	{
		return !animator.GetAnimBool(PlayerAnimation.AnimType.Groggy);
	}

	#endregion
	UIPopup _uiScene;
    #region Input System
    public void OnCanBehavior(InputValue value)
	{
		blackBoard.inputs[EKey.Escape] = !blackBoard.inputs[EKey.Escape];
		if(blackBoard.inputs[EKey.Escape])
		{
			_uiScene = Managers.UI.ShowPopupUI<UIPopup>("OptionCanvas");
            if (_uiScene.GetComponent<Option>().playerBlackBoard == null)
            {
                _uiScene.GetComponent<Option>().playerBlackBoard = blackBoard;
            }
        }
        else
            Managers.UI.ClosePopupUI();
    }

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
		if (IsNotGroggy() == false) return;

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
			stream.SendNext(blackBoard.isLive);
        }
		else if(stream.IsReading)
		{
			transform.rotation = (Quaternion)stream.ReceiveNext();
            blackBoard.rigidBody.velocity = (Vector3)stream.ReceiveNext();
			bool isLive = (bool)stream.ReceiveNext();
			SetActiveState(isLive);
			float lag = Mathf.Abs((float)(PhotonNetwork.Time - info.SentServerTime));
            transform.position += blackBoard.rigidBody.velocity * lag;
        }
    }

	public void OnDamaged(float damage)
	{
		playerData.pv.RPC("Damage", RpcTarget.AllBuffered, damage);
		playerMaterialController.Hit();

		teamUIController.UpdateTeamUI();

        if (playerData.pv.IsMine)
			viewCamera.GetComponent<PlayerCamera>().Shake(0.15f, 0.25f);
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
    public GameDirector gameDirector;

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
			if (blackBoard.groggyable)  // Groggy
			{
				blackBoard.groggyable = false;
				animator.SetAnimBool(PlayerAnimation.AnimType.Groggy, true);
				playerData.speedDebuffPercent = 0.1f;
				ChangeWeapon(WeaponType.NONE);
			}
			else // Death
			{
				if (playerData.pv.IsMine)
				{
                    ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties["Team"];
					if (playerTeam == ETeam.REDTEAM)
						GameDirector.blueScore++;
					else
						GameDirector.redScore++;

					gameDirector.pv.RPC("UpdateScores", RpcTarget.AllBuffered, GameDirector.blueScore, GameDirector.redScore);
					StartCoroutine(RespawnDelay(3.0f));
				}
				blackBoard.hp = blackBoard.maxHp;
				blackBoard.defence = blackBoard.maxDefence;
				animator.SetAnimBool(PlayerAnimation.AnimType.Groggy, false);
				blackBoard.groggyable = true;
                playerData.speedDebuffPercent = 1f;
                hpBar.InitializeValues();
				this.transform.position = blackBoard.spawnPoint;
			}
        }
    }
	IEnumerator RespawnDelay(float time)
	{
        _uiScene = Managers.UI.ShowPopupUI<UIPopup>("DieCanvas");

        hpBar.SetStopHpUI(true);
        blackBoard.isLive = false;
		SetActiveState(false);
        yield return new WaitForSeconds(time);
        blackBoard.isLive = true;
        hpBar.SetStopHpUI(false);
        SetActiveState(true);
        viewCamera.GetComponent<PlayerCamera>().SetTarget(gameObject);
        Managers.UI.ClosePopupUI();
    }
	private void SetActiveState(bool isDie)
	{
        for (int i = 0; i < blackBoard.playerModels.Count; i++)
            blackBoard.playerModels[i].SetActive(isDie);

        blackBoard.rigidBody.isKinematic = !isDie;
        blackBoard.playerCollider.enabled = isDie;
    }

    [PunRPC]
    private void Rigidity(float time)
	{
        playerData.speedDebuffPercent = 0.5f;
        StartCoroutine(ResetRigidity(time));
    }

	[PunRPC]
	public void OnResurrect()
	{
		blackBoard.hp = 50f;
		hpBar.SetHpValue(blackBoard.hp, blackBoard.defence);
		animator.SetAnimBool(PlayerAnimation.AnimType.Groggy, false);
		ChangeWeapon(WeaponType.GUN);
		playerData.speedDebuffPercent = 1f;
	}
}
