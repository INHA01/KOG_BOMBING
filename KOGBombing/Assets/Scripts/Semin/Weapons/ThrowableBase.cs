using Photon.Pun;
using Semin;
using BAEK;	
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public abstract class ThrowableBase : SupportWeaponBase
{
	protected DecalProjector decal;
	protected LineRenderer lineRendererToTarget;
	protected LineRenderer lineRendererToRange;
	protected Vector3[] points = new Vector3[4];
	protected Vector3 targetPos;
	protected Vector3 curPos;
	protected int lineCnt = 20;
	protected float yPos = 6.0f;
	protected float throwDuration = 0.5f;
	public float maxDistance = 7f;
	protected float angle;

	public float angleStart = 55;
	public float angleEnd = 125;
	public int segments = 20;

	protected virtual void Awake()
	{
		decal = Managers.Resource.Instantiate("SupportWeapon/AttackRagneDecal").GetComponent<DecalProjector>();
		lineRendererToTarget = Managers.Resource.Instantiate("SupportWeapon/AttackLineRenderer").GetComponent<LineRenderer>();
		lineRendererToRange = Managers.Resource.Instantiate("SupportWeapon/AttackRangeLineRenderer").GetComponent<LineRenderer>();
		decal.gameObject.SetActive(false);
		lineRendererToTarget.gameObject.SetActive(false);
		lineRendererToRange.gameObject.SetActive(false);
		decal.transform.parent = transform;
		lineRendererToTarget.transform.parent = transform;
		lineRendererToRange.transform.parent = transform;
		lineRendererToTarget.positionCount = lineCnt;

		count = 1;
	}

	public void SetDistanceInfo(Vector3 curPos, Vector3 targetPos, float angle)
	{
		this.curPos = curPos;
		this.targetPos = targetPos;
		this.angle = angle;

		Vector3 zeroCurPos = curPos;
		zeroCurPos.y = 0;
		float distance = Vector3.Distance(zeroCurPos, targetPos);

		Vector3 direction = targetPos - zeroCurPos;
		Vector3 normalizedDirection = direction.normalized;

		if (distance > maxDistance * 2 / 3)
		{
			if (playerData.pv.IsMine)
				lineRendererToRange.gameObject.SetActive(true);
			if (distance >= maxDistance)
				this.targetPos = zeroCurPos + normalizedDirection * maxDistance;
		}
		else lineRendererToRange.gameObject.SetActive(false);

		SetLineToTarget(normalizedDirection);
		SetLineToRange(angle);
	}

	public override void Disable()
	{
		decal.gameObject.SetActive(false);
		lineRendererToTarget.gameObject.SetActive(false);
		lineRendererToRange.gameObject.SetActive(false);
	}

	protected void SetLineToTarget(Vector3 direction)
	{
		points[0] = playerData.shootPos[(int)ShootPos.Start].position;
		points[1] = playerData.shootPos[(int)ShootPos.Start].position + new Vector3(0, yPos, 0);
		points[2] = targetPos;


		decal.transform.position = Vector3.Lerp(decal.transform.position, targetPos, Time.deltaTime * 20.0f);

		for (int i = 0; i < lineCnt; i++)
		{
			float t;
			if (i != 0)
				t = (float)i / (lineCnt - 1);
			else
				t = 0;

			Vector3 bezier = Bezier(points[0], points[1], points[2], t);

			lineRendererToTarget.SetPosition(i, bezier);
		}
	}

	protected void SetLineToRange(float angle)
	{
		lineRendererToRange.positionCount = segments + 1;
		float angleStep = (angleEnd - angleStart) / segments;

		for (int i = 0; i <= segments; i++)
		{
			float currentAngle = angle + angleStart + i * angleStep;
			float x = curPos.x - (maxDistance + decal.size.x / 4) * Mathf.Cos(currentAngle * Mathf.Deg2Rad);
			float z = curPos.z + (maxDistance + decal.size.x / 4) * Mathf.Sin(currentAngle * Mathf.Deg2Rad);
			lineRendererToRange.SetPosition(i, new Vector3(x, curPos.y, z));
		}
	}

	protected Vector3 Bezier(Vector3 p0, Vector3 p1, Vector3 p2, float t)
	{
		Vector3 m0 = Vector3.Lerp(p0, p1, t);
		Vector3 m1 = Vector3.Lerp(p1, p2, t);

		return Vector3.Lerp(m0, m1, t);
	}

	protected IEnumerator ThrowConsum()
	{
		float elapsedTime = 0f;

		GameObject molotov = GetPooledObject().gameObject;
		molotov.transform.position = points[0];
		molotov.transform.rotation = Quaternion.identity;
		AttackConsum grenade = molotov.GetComponent<AttackConsum>();

		grenade.SetTeam((int)team, playerData);
		grenade.SetPlayerIndex(playerIndex);

		while (elapsedTime < throwDuration)
		{
			float t = elapsedTime / throwDuration;
			float smoothT = Mathf.SmoothStep(0f, 1f, t);
			Vector3 position = Bezier(points[0], points[1], points[2], smoothT);
			grenade.transform.position = position;

			elapsedTime += Time.deltaTime;
			yield return null;
		}

		grenade.transform.position = targetPos;
		grenade.Use();
	}

	public abstract override void SetWeapon(SupportWeaponInfo info);


	protected void SetSpawnThrowWeapon()
	{
		decal.gameObject.SetActive(false);
		lineRendererToTarget.gameObject.SetActive(false);
		lineRendererToRange.gameObject.SetActive(false);
		StartCoroutine(ThrowConsum());
	}
}
