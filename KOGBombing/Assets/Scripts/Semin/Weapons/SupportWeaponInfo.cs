using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SupportWeaponInfo 
{
	public Vector3 Position;


	public SupportWeaponInfo(Vector3 position)
	{
		Position = position;
	}
}

public class ThrowableWeaponInfo : SupportWeaponInfo
{
	public Vector3 CurPosition;
	public float angle;

	public ThrowableWeaponInfo(Vector3 curPosition, Vector3 targetPosition, float angle) : base(targetPosition)
	{
		CurPosition = curPosition;
		this.angle = angle;
	}
}