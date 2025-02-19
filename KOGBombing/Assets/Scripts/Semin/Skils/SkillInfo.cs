using UnityEngine;


public class SkillInfo
{
	public Vector3 Position;

	public SkillInfo(Vector3 position)
	{
		Position = position;
	}
}

public class ThrowableSkillInfo : SkillInfo
{
	public Vector3 CurPosition;
	public float Angle;

	public ThrowableSkillInfo(Vector3 curPosition, Vector3 targetPosition, float angle) : base(targetPosition)
	{
		CurPosition = curPosition;
		Angle = angle;
	}
}