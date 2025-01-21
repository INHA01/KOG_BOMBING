using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UseSupportWeaponInfo 
{
	public int UseCount;

	public UseSupportWeaponInfo(int useCount)
	{
		UseCount = useCount;
	}
}

public class UseDeployableWeaponInfo : UseSupportWeaponInfo
{
	public Vector3 Position;

	public UseDeployableWeaponInfo(int useCount, Vector3 position) : base(useCount)
	{
		Position = position;
	}
}