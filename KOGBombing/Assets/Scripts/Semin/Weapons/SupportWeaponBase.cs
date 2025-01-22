using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class SupportWeaponBase : MonoBehaviour, ISupportWeapon
{
	[SerializeField] public AttackConsum consum;
	protected float range;
	protected float damage;
	protected int count = 10;
	public float Damage { get { return damage; } }
	public int Count { get { return count; } }

	public virtual void SetConsum(GameObject consum)
	{
		if (!consum.GetComponent<AttackConsum>())
			return;

		this.consum = consum.GetComponent<AttackConsum>();
		Debug.Log(consum);
	}

	public abstract void SetWeapon(SupportWeaponInfo info);
	public abstract void Use(); 
}
