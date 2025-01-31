using Photon.Pun.Demo.SlotRacer.Utils;
using Semin;
using System.Collections;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using Photon.Pun;
using Photon.Realtime;

public class ThrowableWeapon : SupportWeaponBase
{
	private PlayerData playerData;
	private DecalProjector decal;
	private LineRenderer lineRendererToTarget;
	private LineRenderer lineRendererToRange;
	private Vector3[] points = new Vector3[4];
	private Vector3 targetPos;
	private Vector3 curPos;
	private int lineCnt = 20;
	private float yPos = 6.0f;
	private float throwDuration = 0.5f;
	private float maxDistance = 10f;

	public float angleStart = 55; 
	public float angleEnd = 125;
	public int segments = 20;

	private void Awake()
	{
		playerData = GetComponent<PlayerData>();

		decal = Instantiate(Resources.Load("Prefabs/SupportWeapon/AttackRagneDecal")).GetComponent<DecalProjector>();
		lineRendererToTarget = (Instantiate(Resources.Load("Prefabs/SupportWeapon/AttackLineRenderer")) as GameObject).GetComponent<LineRenderer>();
		lineRendererToRange = (Instantiate(Resources.Load("Prefabs/SupportWeapon/AttackRangeLineRenderer")) as GameObject).GetComponent<LineRenderer>();
		decal.gameObject.SetActive(false);
		lineRendererToTarget.gameObject.SetActive(false);
		lineRendererToRange.gameObject.SetActive(false);
		decal.transform.parent = transform;
		lineRendererToTarget.transform.parent = transform;
		lineRendererToRange.transform.parent = transform;
		lineRendererToTarget.positionCount = lineCnt;
	}

    public override void SetConsum(WeaponType type)
	{
		base.SetConsum(type);

		if (consum is Molotov molotov)
			decal.size = new Vector3(molotov.Range, molotov.Range, decal.size.z);
	}

	public override void SetWeapon(SupportWeaponInfo info)
	{
		decal.gameObject.SetActive(true);
		lineRendererToTarget.gameObject.SetActive(true);

		if (info is ThrowableWeaponInfo throableInfo)
		{
			curPos = throableInfo.CurPosition;
			targetPos = throableInfo.Position;
            Vector3 zeroCurPos = curPos;
            zeroCurPos.y = 0;
            float distance = Vector3.Distance(zeroCurPos, targetPos);

			Vector3 direction = targetPos - zeroCurPos;
			Vector3 normalizedDirection = direction.normalized;

            if (distance > maxDistance * 2 / 3)
            {
                lineRendererToRange.gameObject.SetActive(true);
                if (distance >= maxDistance)
                    targetPos = zeroCurPos + normalizedDirection * maxDistance;
            }
            else lineRendererToRange.gameObject.SetActive(false);

            SetLineToTarget(normalizedDirection);
			SetLineToRange(throableInfo.angle);
		}
	}

	public override void Disable()
	{
		decal.gameObject.SetActive(false);
		lineRendererToTarget.gameObject.SetActive(false);
		lineRendererToRange.gameObject.SetActive(false);
	}

	public override void Use()
	{
		decal.gameObject.SetActive(false);
		lineRendererToTarget.gameObject.SetActive(false);
		lineRendererToRange.gameObject.SetActive(false);
        StartCoroutine(ThrowConsum());
		//playerData.pv.RPC("SpawnThrowWeapon", RpcTarget.AllBuffered);
		
    }
	[PunRPC]
	private void SpawnThrowWeapon()
	{
        decal.gameObject.SetActive(false);
        lineRendererToTarget.gameObject.SetActive(false);
        lineRendererToRange.gameObject.SetActive(false);
        StartCoroutine(ThrowConsum());
    }
	
	private void SetLineToTarget(Vector3 direction)
	{
		points[0] = curPos;
		points[1] = curPos + new Vector3(0, yPos, 0);
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

	private void SetLineToRange(float angle)
	{
		lineRendererToRange.positionCount = segments + 1;
		float angleStep = (angleEnd - angleStart) / segments;

		for (int i = 0; i <= segments; i++)
		{
			float currentAngle = angle + angleStart + i * angleStep;
			float x = curPos.x - (maxDistance - decal.size.x / 2) * Mathf.Cos(currentAngle * Mathf.Deg2Rad);
			float z = curPos.z + (maxDistance - decal.size.x / 2) * Mathf.Sin(currentAngle * Mathf.Deg2Rad);
			lineRendererToRange.SetPosition(i, new Vector3(x, curPos.y, z));
		}
	}

	private Vector3 Bezier(Vector3 p0, Vector3 p1, Vector3 p2, float t)
	{
		Vector3 m0 = Vector3.Lerp(p0, p1, t);
		Vector3 m1 = Vector3.Lerp(p1, p2, t);

		return Vector3.Lerp(m0, m1, t);
	}

	IEnumerator ThrowConsum()
	{
		float elapsedTime = 0f;
        GameObject molotov = PhotonNetwork.Instantiate("Prefabs/SupportWeapon/Molotov", points[0], Quaternion.identity);
		AttackConsum grenade = molotov.GetComponent<AttackConsum>();// Instantiate(consum, points[0], Quaternion.identity);

        grenade.SetTeam(team);

		while (elapsedTime < throwDuration)
		{
			float t = elapsedTime / throwDuration;
			float smoothT = Mathf.SmoothStep(0f, 1f, t); 
			Vector3 position = Bezier(points[0], points[1], points[2], smoothT);
			grenade.transform.position = position;

			elapsedTime += Time.deltaTime;
			yield return null;
		}

		grenade.transform.position = Bezier(points[0], points[1], points[2], 1f);
		grenade.Use();
	}
}
