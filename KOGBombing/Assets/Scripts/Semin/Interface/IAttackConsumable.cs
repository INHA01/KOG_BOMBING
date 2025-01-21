using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

namespace Semin
{
	public interface IAttackConsumable : IConsumable
	{
		public float Damage { get; }
		public void Attack(GameObject gameObject);
	}

}
