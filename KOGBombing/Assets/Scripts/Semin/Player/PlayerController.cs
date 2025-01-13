using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine.InputSystem;
using Photon.Pun;
using Photon.Realtime;
namespace Semin
{

	public class PlayerController : MonoBehaviour
	{
		[SerializeField]
		PhotonView pv;
		[SerializeField] public GameObject playerObj;
		Rigidbody rigidBody;
		Dictionary<EKey, bool> inputs = new Dictionary<EKey, bool>(new EKeyComparer());
		public Dictionary<EKey, bool> Inputs { get { return inputs; } }
		BehaviourTree behaviourTree;
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
			behaviourTree = new BehaviourTree(SetBehaviourTree());
		}

		INode SetBehaviourTree()
		{
			return new ParallelNode(
				new List<INode>()
				{
					new IfDecoratorNode(() => CheckInput(inputs[EKey.W]), new ActionNode(() => Move(EDirection.Up))),
					new IfDecoratorNode(() => CheckInput(inputs[EKey.A]), new ActionNode(() => Move(EDirection.Left))),
					new IfDecoratorNode(() => CheckInput(inputs[EKey.S]), new ActionNode(() => Move(EDirection.Down))),
					new IfDecoratorNode(() => CheckInput(inputs[EKey.D]), new ActionNode(() => Move(EDirection.Right))),
					new ActionNode(RotatePlayer)
				}
			);
		}

		private void FixedUpdate()
		{
			//if (!pv.IsMine) return;
			behaviourTree.Operate();
		}

		#region Attack Node
		INode.ENodeState Move(EDirection direction)
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

		INode.ENodeState RotatePlayer()
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
		bool CheckInput(bool input)
		{
			return input;
		}
		#endregion

		#region Input System
		public void OnAttack(InputValue value)
		{
			playerShooting.ShootButton();
		}
		public void OnRotate(InputValue value)
		{
			mousePos = value.Get<Vector2>();
		}
	
		public void OnMove(InputValue value)
		{
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
