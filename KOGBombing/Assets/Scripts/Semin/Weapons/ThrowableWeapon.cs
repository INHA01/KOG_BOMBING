using Photon.Pun.Demo.SlotRacer.Utils;
using Semin;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UIElements;

public class ThrowableWeapon : SupportWeaponBase
{
	private GameObject decal;
	private LineRenderer lineRenderer;
	private Vector3[] points = new Vector3[4];
	private Vector3 targetPos;
	private Vector3 curPos;
	private int lineCnt = 20;
	private float yPos = 3.0f;
	private float throwDuration = 1f;
	private float maxDistance = 10f;

	public ThrowableWeapon()
	{
	}

	private void Start()
	{
		decal = Instantiate(Resources.Load("Prefabs/SupportWeapon/AttackRagneDecal")) as GameObject;
		lineRenderer = (Instantiate(Resources.Load("Prefabs/SupportWeapon/AttackLineRenderer")) as GameObject).GetComponent<LineRenderer>();
		decal.SetActive(false);
		lineRenderer.gameObject.SetActive(false);
		decal.transform.parent = transform;
		lineRenderer.transform.parent = transform;
		lineRenderer.positionCount = lineCnt;
	}

	public override void SetWeapon(SupportWeaponInfo info)
	{
		decal.SetActive(true);
		lineRenderer.gameObject.SetActive(true);

		if (info is ThrowableWeaponInfo throableInfo)
		{
			if (Vector3.Distance(throableInfo.CurPosition, throableInfo.Position) > maxDistance)
			{
				Vector3 direction = throableInfo.Position - throableInfo.CurPosition;
				Vector3 normalizedDirection = direction.normalized;
				targetPos = throableInfo.CurPosition + normalizedDirection * maxDistance;
				decal.transform.position = Vector3.Lerp(decal.transform.position, targetPos, Time.deltaTime * 20.0f);

				points[0] = throableInfo.CurPosition;
				points[1] = throableInfo.CurPosition + new Vector3(0, yPos, 0);
				points[2] = targetPos + new Vector3(0, yPos - 0.5f, 0);
				points[3] = targetPos;
			}
			else
			{
				decal.transform.position = Vector3.Lerp(decal.transform.position, throableInfo.Position, Time.deltaTime * 20.0f);
				points[0] = throableInfo.CurPosition;
				points[1] = throableInfo.CurPosition + new Vector3(0, yPos, 0);
				points[2] = throableInfo.Position + new Vector3(0, yPos - 0.5f, 0);
				points[3] = throableInfo.Position;
			}
			

			for (int i = 0; i < lineCnt; i++)
			{
				float t;
				if (i == 0)
					t = 0;
				else
					t = (float)i / (lineCnt - 1);

				Vector3 bezier = Bezier(points[0], points[1], points[2], points[3], t);

				lineRenderer.SetPosition(i, bezier);
			}
		}
	}

	public override void Disable()
	{
		decal.SetActive(false);
		lineRenderer.gameObject.SetActive(false);
	}

	public override void Use()
	{
		decal.SetActive(false);
		lineRenderer.gameObject.SetActive(false);
		StartCoroutine(ThrowConsum());
	}

	public Vector3 Bezier(Vector3 p0, Vector3 p1, Vector3 p2, Vector3 p3, float t)
	{
		Vector3 m0 = Vector3.Lerp(p0, p1, t);
		Vector3 m1 = Vector3.Lerp(p1, p2, t);
		Vector3 m2 = Vector3.Lerp(p2, p3, t);

		Vector3 b0 = Vector3.Lerp(m0, m1, t);
		Vector3 b1 = Vector3.Lerp(m1, m2, t);

		return Vector3.Lerp(b0, b1, t);
	}

	IEnumerator ThrowConsum()
	{
		float elapsedTime = 0f;
		GameObject grenade = Instantiate(consum, points[0], Quaternion.identity).gameObject;

		while (elapsedTime < throwDuration)
		{
			float t = elapsedTime / throwDuration;
			Vector3 position = Bezier(points[0], points[1], points[2], points[3], t);
			grenade.transform.position = position;

			elapsedTime += Time.deltaTime;
			yield return null;
		}

		Destroy(grenade);
	}
}
