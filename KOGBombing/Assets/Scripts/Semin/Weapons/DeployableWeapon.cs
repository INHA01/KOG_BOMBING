using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeployableWeapon : SupportWeaponBase
{
	private Vector3 position;

	public override void SetWeapon(SupportWeaponInfo info)
	{
		if (consum == null)
			return;

		position = info.Position;
	}

	public override void Use()
	{
        AttackConsum obj = PhotonNetwork.Instantiate("Prefabs/SupportWeapon/Landmine", position, Quaternion.identity)
							.GetComponent<AttackConsum>();
		obj.SetTeam(team);
	}
}
