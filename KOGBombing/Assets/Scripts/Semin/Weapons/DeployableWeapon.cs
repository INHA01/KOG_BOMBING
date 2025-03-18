using Knife.Effects.SimpleController;
using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeployableWeapon : DeployableBase
{
	Vector3 position;
	Landmine landmine;
	protected override void Init()
	{
		count = 2;
		base.Init();
	}

	public override void Initialize(int count)
    {
        base.Initialize(count);
		if (landmine != null && landmine.isActive)
			landmine.Release();
    }

    public override void Use()
    {
        count--;
        base.Use();
        playerData.pv.RPC("PutConsum", RpcTarget.All);
    }

    [PunRPC]
    public virtual void PutConsum()
    {
        playerData.playerSound.skillSound.ActiveSound(transform, ESkillSound.UNI_MINE);
        StartCoroutine(PutAfterAnim());
    }

    public override void SetWeapon(SupportWeaponInfo info)
	{
		if (consum == null)
			return;

		position = info.Position;
	}

    protected override IEnumerator PutAfterAnim()
	{
		yield return new WaitForSeconds(1.3f);
		landmine = GetPooledObject().GetComponent<Landmine>();
		landmine.transform.position = playerData.ConsumPos.position;
		landmine.SetTeam((int)team, playerData);
		landmine.SetPlayerIndex(playerIndex);
		landmine.Use();
	}
}
