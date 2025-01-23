using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface ISupportWeapon 
{
	public void Disable();
	public void SetWeapon(SupportWeaponInfo info);
	public void Use();
}
