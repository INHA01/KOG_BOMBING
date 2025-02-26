using Photon.Pun.Demo.SlotRacer.Utils;
using Semin;
using System.Collections;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine.UIElements;

public class ThrowableWeapon : ThrowableBase
{
	protected override void Awake()
	{
		base.Awake();
		playerData = GetComponent<PlayerData>();
	}

	public override void SetConsum(WeaponType type, PlayerData playerData)
	{
		this.type = type;
		base.SetConsum(type, playerData);

		objectPool = gameObject.AddComponent<ObjectPool>();
		objectPool.SetObjectToPool(Managers.Resource.Load<PooledObject>("Prefabs/SupportWeapon/Molotov"));
		objectPool.SetParentPrefab(Managers.Resource.Load<GameObject>("Prefabs/SupportWeapon/WeaponMagazine"));
		objectPool.initPoolSize = count;
		decal.size = new Vector3(consum.GetComponent<Molotov>().Range, consum.GetComponent<Molotov>().Range, decal.size.z);
	}

	public override void SetWeapon(SupportWeaponInfo info)
	{
		decal.gameObject.SetActive(true);
		lineRendererToTarget.gameObject.SetActive(true);

		if (info is ThrowableWeaponInfo throwableInfo)
			playerData.pv.RPC("SetInfo", RpcTarget.AllBuffered, throwableInfo.CurPosition, throwableInfo.Position, throwableInfo.Angle);
	}

	[PunRPC]
	public void SetInfo(Vector3 curPos, Vector3 targetPos, float angle)
	{
		SetDistanceInfo(curPos, targetPos, angle);
	}

	public override void Use()
	{
		base.Use();
		count--;
		playerData.pv.RPC("SpawnThrowWeapon", RpcTarget.AllBuffered);
		//playerData.pv.RPC("SpawnThrowWeapon", RpcTarget.AllBuffered);
    }

	[PunRPC]
	private void SpawnThrowWeapon()
	{
		SetSpawnThrowWeapon();
	}
}
