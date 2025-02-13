using Photon.Pun.Demo.SlotRacer.Utils;
using Semin;
using System.Collections;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine.UIElements;

public class ThrowableWeapon : SupportWeaponBase
{
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
	private float angle;

	public float angleStart = 55; 
	public float angleEnd = 125;
	public int segments = 20;

	ObjectPool objectPool;

	private void Awake()
	{
		playerData = GetComponent<PlayerData>();
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
		objectPool = gameObject.AddComponent<ObjectPool>();
		objectPool.SetObjectToPool(Managers.Resource.Load<PooledObject>("Prefabs/SupportWeapon/Molotov"));
		objectPool.SetParentPrefab(Managers.Resource.Load<GameObject>("Prefabs/SupportWeapon/WeaponMagazine"));
		objectPool.initPoolSize = count;
	}

    public override void SetConsum(WeaponType type, PlayerData playerData)
	{
		base.SetConsum(type, playerData);

		if (consum is Molotov molotov)
			decal.size = new Vector3(molotov.Range, molotov.Range, decal.size.z);
	}

	public override void SetWeapon(SupportWeaponInfo info)
	{
		decal.gameObject.SetActive(true);
		lineRendererToTarget.gameObject.SetActive(true);

		if (info is ThrowableWeaponInfo throwableInfo)
		{
			curPos = throwableInfo.CurPosition;
			targetPos = throwableInfo.Position;
			angle = throwableInfo.Angle;

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
			SetLineToRange(angle);
		}
	}

	[PunRPC]
	public void SetInfo(Vector3 curPos, Vector3 targetPos, float angle)
	{
		this.curPos = curPos;
		this.targetPos = targetPos; 
		this.angle = angle;
		Debug.Log("SetInfo");
	}

	public override void Disable()
	{
		decal.gameObject.SetActive(false);
		lineRendererToTarget.gameObject.SetActive(false);
		lineRendererToRange.gameObject.SetActive(false);
	}

	public override void Use()
	{
		count--;
		playerData.pv.RPC("SpawnThrowWeapon", RpcTarget.AllBuffered);
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
		points[0] = playerData.shootStartPos.position;
		points[1] = playerData.shootStartPos.position + new Vector3(0, yPos, 0);
		points[2] = playerData.consumTargetPos;

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
		//GameObject molotov = PhotonNetwork.Instantiate("Prefabs/SupportWeapon/Molotov", points[0], Quaternion.identity);
		GameObject molotov = objectPool.GetPooledObject().gameObject;
		molotov.transform.position = points[0];
		molotov.transform.rotation = Quaternion.identity;
		AttackConsum grenade = molotov.GetComponent<AttackConsum>();

        grenade.SetTeam((int)team);

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
