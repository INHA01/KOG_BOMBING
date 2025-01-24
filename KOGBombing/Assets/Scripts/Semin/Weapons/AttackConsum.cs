using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

namespace Semin
{
	public abstract class AttackConsum : MonoBehaviour, IConsumable
	{
		public abstract float Damage { get; }

		public abstract void Attack(GameObject gameObject);
		public abstract void Use();
	}

}
