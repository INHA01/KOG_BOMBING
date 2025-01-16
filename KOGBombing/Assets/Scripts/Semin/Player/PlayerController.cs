using UnityEngine;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using Photon.Pun;
using System.Text;
namespace Semin
{

	public class PlayerController : MonoBehaviour
	{
		[SerializeField]
		PhotonView pv;
		[SerializeField] 
		public GameObject playerObj;
		[SerializeField]
		public Animator animator;
		[SerializeField]
		bool canConnectPhoton = false;
		Rigidbody rigidBody;
		Dictionary<EKey, bool> inputs = new Dictionary<EKey, bool>(new EKeyComparer());
		public Dictionary<EKey, bool> Inputs { get { return inputs; } }
		//BehaviourTree behaviourTree;
		public float moveSpeed = 6;
		Vector2 speedValue = Vector2.zero;
		Vector2 mousePos = Vector2.zero;
		Camera viewCamera;

		public enum EDirection
		{
			Up,
			Down,
			Left,
			Right,
		}
		PlayerShooting playerShooting;

		void Start()
		{
			playerShooting = GetComponent<PlayerShooting>();
			viewCamera = Camera.main;

			for (int i = 0; i < (int)EKey.MAX; i++)
				inputs[(EKey)i] = false;

			rigidBody = GetComponent<Rigidbody>();
			//behaviourTree = new BehaviourTree(SetBehaviourTree());
			if(canConnectPhoton)
				SetTeamFieldOfView();

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

	INode SetBehaviourTree()
		{
			return new ParallelNode(
				new List<Node>()
				{
					new IfDecoratorNode(() => CheckInput(EKey.W), new ActionNode(() => Move(EDirection.Up))),
					new IfDecoratorNode(() => CheckInput(EKey.A), new ActionNode(() => Move(EDirection.Left))),
					new IfDecoratorNode(() => CheckInput(EKey.S), new ActionNode(() => Move(EDirection.Down))),
					new IfDecoratorNode(() => CheckInput(EKey.D), new ActionNode(() => Move(EDirection.Right))),
					new ActionNode(RotatePlayer)
				}
			);
		}

		private void Update()
		{
			UpdateAnimation();
		}

		private void UpdateAnimation()
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



		#region Attack Node
		public INode.ENodeState Move(EDirection direction)
		{
			switch(direction)
			{
				case EDirection.Left:
					transform.Translate(Vector3.right * Time.deltaTime * moveSpeed * -1 * speedValue.x);
					break;
				case EDirection.Right:
					transform.Translate(Vector3.right * Time.deltaTime * moveSpeed * speedValue.x);
					break;
				case EDirection.Up:
					transform.Translate(Vector3.forward * Time.deltaTime * moveSpeed * speedValue.y);
					break;
				case EDirection.Down:
					transform.Translate(Vector3.forward * Time.deltaTime * moveSpeed * -1 * speedValue.y);
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
			playerShooting.Shoot();
		}
		public void OnRotate(InputValue value)
		{
            if (!pv.IsMine) return;
            mousePos = value.Get<Vector2>();
		}
	
		public void OnMove(InputValue value)
		{
            if (!pv.IsMine) return;
            Vector2 inputVector = value.Get<Vector2>();
			speedValue.x = Mathf.Abs(inputVector.x);
			speedValue.y = Mathf.Abs(inputVector.y);
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
    }
}
