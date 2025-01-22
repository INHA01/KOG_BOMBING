using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SupportWeaponInfo 
{
	public int UseCount;

	public SupportWeaponInfo(int useCount)
	{
		UseCount = useCount;
	}
}

public class DeployableWeaponInfo : SupportWeaponInfo
{
	public Vector3 Position;

	public DeployableWeaponInfo(int useCount, Vector3 position) : base(useCount)
	{
		Position = position;
	}
}