using UnityEngine;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using Photon.Pun;
using System.Text;
using Semin;
using Photon.Pun.Demo.Cockpit;



public class PlayerController : MonoBehaviour, IPunObservable
{
	[SerializeField]
	PhotonView pv;
	[SerializeField] 
	public GameObject playerObj;
	[SerializeField]
	bool canConnectPhoton = false;
	[SerializeField] 
	PlayerAnimation animator;
	public ISupportWeapon supportWeapon = new DeployableWeapon();
	Rigidbody rigidBody;
	Dictionary<EKey, bool> inputs = new Dictionary<EKey, bool>(new EKeyComparer());
	public Dictionary<EKey, bool> Inputs { get { return inputs; } }
	public float moveSpeed = 6;
	Vector2 speedValue = Vector2.zero;
	Vector2 mousePos = Vector2.zero;
	Camera viewCamera;

	// 지연보상 테스트
	Vector3 networkPosi = Vector3.zero;
	Quaternion networkRotation = Quaternion.identity;

	public enum EDirection
	{
		Up,
		Down,
		Left,
		Right,
	}
	PlayerShooting playerShooting;

	void Awake()
	{
		playerShooting = GetComponent<PlayerShooting>();
		playerShooting.Init(playerObj.transform);

		for (int i = 0; i < (int)EKey.MAX; i++)
			inputs.Add((EKey)i, false);

		rigidBody = GetComponent<Rigidbody>();
		if(canConnectPhoton)
			SetTeamFieldOfView();

		animator.SetPlayerObject(playerObj);
    }

	private void Start()
	{
		if (viewCamera == null)
			viewCamera = Camera.main;

		if (supportWeapon is DeployableWeapon support)
			support.SetWeapon(Resources.Load("Prefabs/SupportWeapon/Landmine") as GameObject);
	}

	public void SetCamera(Camera cam)
	{
		viewCamera = cam;
	}

	void SetTeamFieldOfView()
	{
		StringBuilder mineTeam = new StringBuilder((string)pv.Owner.CustomProperties["Team"]);

        if (!pv.IsMine)
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
		if(!pv.IsMine)
		{
			if((transform.position - networkPosi).sqrMagnitude >= 10f)
			{
				transform.position = Vector3.Lerp(transform.position, networkPosi, Time.deltaTime);
			}
			transform.rotation = Quaternion.Lerp(transform.rotation, networkRotation, Time.deltaTime);
		}
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

	public INode.ENodeState RotatePlayer()
	{
		Ray cameraRay = viewCamera.ScreenPointToRay(mousePos);
		Plane GroupPlane = new Plane(Vector3.up, playerObj.transform.position);
		float rayLength;

		if (GroupPlane.Raycast(cameraRay, out rayLength))
		{
			Vector3 pointTolook = cameraRay.GetPoint(rayLength);
			playerShooting.attackPoint = pointTolook;
			animator.Rotation(pointTolook, speedValue);

			playerObj.transform.LookAt(pointTolook);
		}

		return INode.ENodeState.Success;
	}


	#endregion

	#region If Decorater Node
	public bool CheckInput(EKey key)
	{
		return inputs[key];
	}
    #endregion
    #region Input System
    public void OnAttack(InputValue value)
	{
		if (!pv.IsMine) return;
		playerShooting.Shoot(animator);
	}
    bool CheckMouseOutScreen(Vector2 mousePos)
    {
        return (mousePos.x >= 0 && mousePos.x <= Screen.width && mousePos.y >= 0 && mousePos.y <= Screen.height);
    }
	public void OnRotate(InputValue value)
	{
        if (!pv.IsMine) return;
		if (!CheckMouseOutScreen(value.Get<Vector2>())) return;
        mousePos = value.Get<Vector2>();
    }
	
	public void OnMove(InputValue value)
	{
        if (!pv.IsMine) return;
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
		if (!pv.IsMine) return;
		supportWeapon.Use(new UseDeployableWeaponInfo(1, playerObj.transform.position));
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
			stream.SendNext(transform.position);
			stream.SendNext(transform.rotation);
			stream.SendNext(rigidBody.velocity);
		}
		else if(stream.IsReading)
		{
			networkPosi = (Vector3)stream.ReceiveNext();
			networkRotation = (Quaternion)stream.ReceiveNext();
			rigidBody.velocity = (Vector3)stream.ReceiveNext();
			float lag = Mathf.Abs((float)(PhotonNetwork.Time - info.SentServerTime));
            transform.position += rigidBody.velocity * lag;

        }
    }
}
