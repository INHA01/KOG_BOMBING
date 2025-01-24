using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SupportWeaponInfo 
{
	public Vector3 Position;
	public string Team;

	public SupportWeaponInfo(Vector3 position, string team)
	{
		Position = position;
		Team = team;
	}
}

public class ThrowableWeaponInfo : SupportWeaponInfo
{
	public Vector3 CurPosition;
	public float angle;

	public ThrowableWeaponInfo(Vector3 curPosition, Vector3 targetPosition, float angle, string team) : base(targetPosition, team)
	{
		CurPosition = curPosition;
		this.angle = angle;
	}
}