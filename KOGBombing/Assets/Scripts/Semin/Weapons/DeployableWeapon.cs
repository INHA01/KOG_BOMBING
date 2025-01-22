using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeployableWeapon : SupportWeaponBase
{
	private Vector3 position;

	public override void SetWeapon(SupportWeaponInfo info)
	{
		if (consum == null)
			return;

		if (info is DeployableWeaponInfo attackInfo)
		{
			position = attackInfo.Position;
		}
	}

	public override void Use()
	{
		AttackConsum obj = Instantiate(consum.gameObject, position, Quaternion.identity).GetComponent<AttackConsum>();
	}
}
