using Orpul1;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class SupportWeaponBase : ObjectPool, ISupportWeapon
{
	[SerializeField] public AttackConsum consum;
	protected ETeam team;
	protected float range;
	protected float damage;
	protected int count = 10;
	protected PlayerData playerData;
	public float Damage { get { return damage; } }
	public WeaponType type;
	//public int Count { get { return count; } }

	public virtual void SetConsum(WeaponType type, PlayerData playerData)
	{
		switch (type)
		{
			case WeaponType.LANDMINE:
                consum = Managers.Resource.Load<AttackConsum>("Prefabs/SupportWeapon/Landmine");
				break;
			case WeaponType.MOLOTOV:
				consum = Managers.Resource.Load<AttackConsum>("Prefabs/SupportWeapon/Molotov");
				break;
        }
		this.type = type;
		this.playerData = playerData;
    }
	public void SetTeam(ETeam team)
	{
		this.team = team;
	}

	public abstract void SetWeapon(SupportWeaponInfo info);
	public abstract void Use();
	public virtual void Disable() { }

	public bool isUsable()
	{
		if (count <= 0)
			return false;
		return true;
	}
}
