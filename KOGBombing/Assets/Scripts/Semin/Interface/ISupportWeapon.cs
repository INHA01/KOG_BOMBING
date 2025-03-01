using System.Collections;
using System.Collections.Generic;
using Orpul1;
using UnityEngine;

public interface ISupportWeapon 
{
	public void Disable();
	public void SetWeapon(SupportWeaponInfo info);
	public void SetTeam(ETeam team, int playerIndex);
	public void Use();
	public void InitializeCount(int count);
}
