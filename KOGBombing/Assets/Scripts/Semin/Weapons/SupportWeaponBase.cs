using Orpul1;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class SupportWeaponBase : MonoBehaviour, ISupportWeapon
{
	[SerializeField] public AttackConsum consum;
	protected ETeam team;
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
                consumObj = Managers.Resource.Instantiate("SupportWeapon/Landmine");
				consum = consumObj.GetComponent<AttackConsum>();
				break;
			case WeaponType.MOLOTOV:
				consumObj = Managers.Resource.Instantiate("SupportWeapon/Molotov");
				consum = consumObj.GetComponent<AttackConsum>();
				break;
        }
        consum.type = type;
    }
	public void SetTeam(ETeam team)
	{
		this.team = team;
	}

	public abstract void SetWeapon(SupportWeaponInfo info);
	public abstract void Use();
	public virtual void Disable() { }
}
