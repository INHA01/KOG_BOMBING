using Photon.Pun;
using Semin;
using System.Collections;
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
		ESkillSound mineSound = (ESkillSound)((int)playerData.characterType * 2) + (int)ESkillSound.NED_MINE;
		EMixerGroup eMixer = playerData.characterType == CharacterType.Ned ? EMixerGroup.EXTRA_ATKSOUND : EMixerGroup.ATTACKSOUND;
		playerData.playerSound.skillSound.ActiveSound(transform, mineSound, eMixer);
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
