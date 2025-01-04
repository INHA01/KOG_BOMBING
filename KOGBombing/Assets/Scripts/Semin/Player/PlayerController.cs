using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using Unity.VisualScripting;

namespace Semin
{
	public class PlayerController : MonoBehaviour
	{
		[SerializeField] public GameObject playerObj;
		Dictionary<EKey, bool> inputs = new Dictionary<EKey, bool>(new EKeyComparer());
		public Dictionary<EKey, bool> Inputs { get { return inputs; } }
		BehaviourTree behaviourTree;
		public float moveSpeed = 6;
		Camera viewCamera;

		void Start()
		{
			viewCamera = Camera.main;

			for (int i = 0; i < (int)EKey.MAX; i++)
				inputs[(EKey)i] = false;

			behaviourTree = new BehaviourTree(SetBehaviourTree());
		}

		INode SetBehaviourTree()
		{
			return new ParallelNode(
				new List<INode>()
				{
					new ActionNode(Move),
					new ActionNode(RotatePlayer)
				}
			);
		}

		void Update()
		{
			//  Move
			if (Input.GetKeyDown(KeyCode.W))
				inputs[EKey.W] = true;
			if (Input.GetKeyUp(KeyCode.W))
				inputs[EKey.W] = false;
			if (Input.GetKeyDown(KeyCode.A))
				inputs[EKey.A] = true;
			if (Input.GetKeyUp(KeyCode.A))
				inputs[EKey.A] = false;
			if (Input.GetKeyDown(KeyCode.S))
				inputs[EKey.S] = true;
			if (Input.GetKeyUp(KeyCode.S))
				inputs[EKey.S] = false;
			if (Input.GetKeyDown(KeyCode.D))
				inputs[EKey.D] = true;
			if (Input.GetKeyUp(KeyCode.D))
				inputs[EKey.D] = false;
		}

		private void FixedUpdate()
		{ 
			behaviourTree.Operate();
		}


		#region Attack Node
		INode.ENodeState Move()
		{
			bool isSuccess = false;

			if (inputs[EKey.W])
			{
				Debug.Log(transform.forward);
				transform.Translate(Vector3.forward * Time.deltaTime * moveSpeed);
				isSuccess = true;
			}
			if (inputs[EKey.A])
			{
				transform.Translate(Vector3.right * Time.deltaTime * moveSpeed * -1);
				isSuccess = true;
			}
			if (inputs[EKey.D])
			{
				transform.Translate(Vector3.right * Time.deltaTime * moveSpeed);
				isSuccess = true;
			}
			if (inputs[EKey.S])
			{
				transform.Translate(Vector3.forward * Time.deltaTime * moveSpeed * -1);
				isSuccess = true;
			}

			if (isSuccess)
				return INode.ENodeState.Success;
			return INode.ENodeState.Fail;
		}

		INode.ENodeState RotatePlayer()
		{
			Ray cameraRay = viewCamera.ScreenPointToRay(Input.mousePosition);
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
	}
}
