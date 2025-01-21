using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Semin
{
	public interface IConsumable
	{
		public int Count { get; }
		public bool Use(UseSupportWeaponInfo info);
	}

}
