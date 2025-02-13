using Knife.Effects.SimpleController;
using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeployableWeapon : SupportWeaponBase
{
	private Vector3 position;
	ObjectPool objectPool;

	private void Awake()
	{
		count = 1;
		objectPool = gameObject.AddComponent<ObjectPool>();
		objectPool.SetObjectToPool(Managers.Resource.Load<PooledObject>("Prefabs/SupportWeapon/Landmine"));
		objectPool.SetParentPrefab(Managers.Resource.Load<GameObject>("Prefabs/SupportWeapon/WeaponMagazine"));
		objectPool.initPoolSize = count;
	}

	public override void SetWeapon(SupportWeaponInfo info)
	{
		if (consum == null)
			return;

		position = info.Position;
	}

	public override bool Use()
	{
		// Landmine landmine = PhotonNetwork.Instantiate("Prefabs/SupportWeapon/Landmine", position, Quaternion.identity)
		//.GetComponent<Landmine>();
		if (count <= 0) 
			return false;
		count--;
		playerData.pv.RPC("PutConsum", RpcTarget.AllBuffered);
		return true;
	}

	[PunRPC]
	public void PutConsum()
	{
		Landmine landmine = objectPool.GetPooledObject().GetComponent<Landmine>();
		landmine.transform.position = playerData.ConsumPos.position;
		landmine.SetTeam((int)team);
		landmine.Use();
	}
}
