using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class SupportWeaponBase : MonoBehaviour, ISupportWeapon
{
	public enum WeaponType
	{
		Landmine,
		Molotov,
		Max
	}

	[SerializeField] public AttackConsum consum;
	protected string team;
	protected float range;
	protected float damage;
	protected int count = 10;
	public float Damage { get { return damage; } }
	public int Count { get { return count; } }

	public virtual void SetConsum(WeaponType type)
	{
		GameObject consum;
		switch (type)
		{
			case WeaponType.Landmine:
				consum = Resources.Load("Prefabs/SupportWeapon/Landmine") as GameObject;
				this.consum = consum.GetComponent<AttackConsum>();
				break;
			case WeaponType.Molotov:
				consum = Resources.Load("Prefabs/SupportWeapon/Molotov") as GameObject;
				this.consum = consum.GetComponent<AttackConsum>();
				Debug.Log(this.consum);
				break;
		}

		
	}

	public abstract void SetWeapon(SupportWeaponInfo info);
	public abstract void Use();
	public virtual void Disable() { }
}
