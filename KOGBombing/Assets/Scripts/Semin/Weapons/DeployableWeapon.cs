using Knife.Effects.SimpleController;
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
        Landmine landmine = PhotonNetwork.Instantiate("Prefabs/SupportWeapon/Landmine", position, Quaternion.identity)
							.GetComponent<Landmine>();
		landmine.SetTeam(team);
        landmine.Use();
    }
}
