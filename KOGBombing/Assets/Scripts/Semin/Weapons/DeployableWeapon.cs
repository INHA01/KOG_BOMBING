using Knife.Effects.SimpleController;
using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeployableWeapon : DeployableBase
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

	public override void Use()
	{
		count--;
		playerData.pv.RPC("PutConsum", RpcTarget.AllBuffered);
	}
    protected override IEnumerator PutAfterAnim()
	{
		yield return new WaitForSeconds(1.3f);
		Landmine landmine = objectPool.GetPooledObject().GetComponent<Landmine>();
		landmine.transform.position = playerData.ConsumPos.position;
		landmine.SetTeam((int)team);
		landmine.Use();
	}
}
