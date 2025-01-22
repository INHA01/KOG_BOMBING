using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class ThrowableWeapon : SupportWeaponBase
{
	private GameObject decal;
	private Vector3 targetPos;
	private Vector3 curPos;

	public ThrowableWeapon()
	{
	}

	private void Start()
	{
		decal = Instantiate(Resources.Load("Prefabs/SupportWeapon/AttackRagneDecal")) as GameObject;
		decal.transform.parent = transform;
		decal.SetActive(false);
	}

	public override void SetWeapon(SupportWeaponInfo info)
	{
		decal.SetActive(true);

		if (info is ThrowableWeaponInfo throableInfo)
		{
			decal.transform.position = Vector3.Lerp(decal.transform.position, throableInfo.Position, Time.deltaTime * 20.0f);
		}
	}

	public override void Use()
	{
		decal.SetActive(false);
	}
}
