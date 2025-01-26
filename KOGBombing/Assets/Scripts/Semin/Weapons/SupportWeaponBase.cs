using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class SupportWeaponBase : MonoBehaviour, ISupportWeapon
{
	[SerializeField] public AttackConsum consum;
	protected string team;
	protected float range;
	protected float damage;
	protected int count = 10;
	public float Damage { get { return damage; } }
	public int Count { get { return count; } }

	public virtual void SetConsum(WeaponType type)
	{
		GameObject consumObj;
		switch (type)
		{
			case WeaponType.LANDMINE:
				consumObj = Resources.Load("Prefabs/SupportWeapon/Landmine") as GameObject;
				consum = consumObj.GetComponent<AttackConsum>();
				break;
			case WeaponType.MOLOTOV:
				consumObj = Resources.Load("Prefabs/SupportWeapon/Molotov") as GameObject;
				consum = consumObj.GetComponent<AttackConsum>();
				break;
        }
        consum.type = type;
    }
	public void SetTeam(string team)
	{
		this.team = team;
	}

	public abstract void SetWeapon(SupportWeaponInfo info);
	public abstract void Use();
	public virtual void Disable() { }
}
