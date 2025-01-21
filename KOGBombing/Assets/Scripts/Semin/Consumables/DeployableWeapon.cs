using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeployableWeapon : MonoBehaviour, ISupportWeapon
{
	[SerializeField] public AttackConsum consum;
	protected float duration;
	protected float range;
	protected float hp;
	protected float damage;
	private int count = 10;
	public float Damage { get { return damage; } }

	public virtual void Use(UseSupportWeaponInfo info)
	{
		if (consum == null)
			return;

		if (info is UseDeployableWeaponInfo attackInfo)
		{
			if (count < attackInfo.UseCount)
				return;
			AttackConsum obj = Instantiate(consum.gameObject, attackInfo.Position, Quaternion.identity).GetComponent<AttackConsum>();
			obj.Use();
		}
	}

	public void SetWeapon(GameObject consum)
	{
		if (!consum.GetComponent<AttackConsum>())
			return;

		this.consum = consum.GetComponent<AttackConsum>();
		Debug.Log(consum);
	}
}
