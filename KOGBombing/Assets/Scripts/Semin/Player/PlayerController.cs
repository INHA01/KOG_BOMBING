using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine.InputSystem;
using Photon.Pun;
using Photon.Realtime;
using Photon.Pun.UtilityScripts;
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

		private void FixedUpdate()
		{
			if (canConnectPhoton)
			{
				if (!pv.IsMine) return;
			}

			Quaternion rotation = Quaternion.Euler(0, -45, 0);
			Vector3 forward = playerObj.transform.forward; // 캐릭터가 바라보는 방향
			forward.y = 0;
			forward.Normalize();			
			forward = rotation * forward;

			Vector3 right = playerObj.transform.right;
			right.y = 0;
			right.Normalize();
			right = rotation * right;

			Vector3 normal = speedValue.normalized;
			float adjustedHorizontal = Vector3.Dot(new Vector3(normal.x, 0, normal.y), right);
			float adjustedVertical = Vector3.Dot(new Vector3(normal.x, 0, normal.y), forward);
			if (speedValue.x != 0 || speedValue.y != 0)
			{                                                                                                                                            
				animator.SetFloat("Horizontal", adjustedHorizontal);
				animator.SetFloat("Vertical", adjustedVertical);
			}				
			else
			{
				animator.SetFloat("Horizontal", 0);
				animator.SetFloat("Vertical", 0);
			}
		}

        #region Action Node
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
			Plane GroupPlane = new Plane(Vector3.up, Vector3.zero);
			float rayLength;

			if (GroupPlane.Raycast(cameraRay, out rayLength))
			{
				Vector3 pointTolook = cameraRay.GetPoint(rayLength);
				playerObj.transform.LookAt(new Vector3(pointTolook.x, playerObj.transform.position.y, pointTolook.z));
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
			//playerShooting.ShootButton();
		}
		public void OnRotate(InputValue value)
		{
			mousePos = value.Get<Vector2>();
		}
	
		public void OnMove(InputValue value)
		{
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
