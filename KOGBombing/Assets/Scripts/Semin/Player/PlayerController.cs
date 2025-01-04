using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using Unity.VisualScripting;

namespace Semin
{


	public class PlayerController : MonoBehaviour
	{

		public float moveSpeed = 6;
		public Dictionary<EKey, bool> inputs = new Dictionary<EKey, bool>(new EKeyComparer());
		public Dictionary<EKey, bool> Inputs { get { return inputs; } }

		Rigidbody rigidbody;
		Camera viewCamera;
		Vector3 velocity;

		void Start()
		{
			rigidbody = GetComponent<Rigidbody>();
			viewCamera = Camera.main;

			for (int i = 0; i < (int)EKey.MAX; i++)
				inputs[(EKey)i] = false;
		}

		void Update()
		{
			Vector3 mousePos = viewCamera.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, viewCamera.transform.position.y));
			transform.LookAt(mousePos + Vector3.up * transform.position.y);
			velocity = new Vector3(Input.GetAxisRaw("Horizontal"), 0, Input.GetAxisRaw("Vertical")).normalized * moveSpeed;

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

		void FixedUpdate()
		{
			rigidbody.MovePosition(rigidbody.position + velocity * Time.fixedDeltaTime);
		}
	}
}
