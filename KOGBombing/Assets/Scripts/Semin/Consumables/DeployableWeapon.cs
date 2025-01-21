using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeployableWeapon : MonoBehaviour, ISupportWeapon
{
	[SerializeField] public GameObject prefab;
	protected float duration;
	protected float range;
	protected float hp;
	protected float damage;
	protected int count = 1;
	public float Damage { get { return damage; } }
	public int Count { get { return count; } }

	public virtual void Use(UseSupportWeaponInfo info)
	{
		if (prefab == null)
			return;

		if (info is UseDeployableWeaponInfo attackInfo)
		{
			if (count < attackInfo.UseCount)
				return;
			count -= attackInfo.UseCount;
			GameObject obj =Instantiate(prefab, attackInfo.Position, Quaternion.identity);
			Debug.Log(obj);
		}
	}

	public void SetWeapon(GameObject gameObject)
	{
		prefab = gameObject;
	}
}
