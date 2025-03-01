using Knife.Effects.SimpleController;
using Orpul1;
using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ThrowableSkill : ThrowableBase, ISkill
{
	bool bisUsableSkill;
	float skillDeltaTime;
    protected override void Start()
	{
        bisUsableSkill = true;
    }

	IEnumerator Cooldown(float time)
	{
        skillDeltaTime = 0f;
		playScene.SetSkillActive(false);
        while (!bisUsableSkill)
        {
            skillDeltaTime += Time.deltaTime;
            playScene.skillFade.fillAmount = skillDeltaTime / time;
            playScene.skillCount.text = ((int)(time - skillDeltaTime)).ToString();

            if (skillDeltaTime > time)
            {
                playScene.skillFade.fillAmount = 0;
                playScene.skillCount.text = "";
                bisUsableSkill = true;
                playScene.SetSkillActive(true);
            }
            yield return null;
		}
	}
	public void InitializationSkill(PlayerData playerData)
	{
        playScene = Managers.UI.GetPopupUI<UIPopup>("PlayCanvas").GetComponent<PlayScene>();
        playScene.SetSkillIcon(CharacterType.Ned);

        consum = Managers.Resource.Load<AttackConsum>("Prefabs/SupportWeapon/Skill/ShockGrenade");
		type = WeaponType.SHOCK_GRENADE;
		this.playerData = playerData;

		objectPool = gameObject.AddComponent<ObjectPool>();
		objectPool.SetObjectToPool(Managers.Resource.Load<PooledObject>("Prefabs/SupportWeapon/Skill/ShockGrenade"));
		objectPool.SetParentPrefab(Managers.Resource.Load<GameObject>("Prefabs/SupportWeapon/WeaponMagazine"));
		objectPool.initPoolSize = count;
		decal.size = new Vector3(consum.GetComponent<ShockGrenade>().Range, consum.GetComponent<ShockGrenade>().Range, decal.size.z);

		team = (ETeam)playerData.pv.Owner.CustomProperties["Team"];
	}

	public void SetSkill(SkillInfo info)
	{
		decal.gameObject.SetActive(true);
		lineRendererToTarget.gameObject.SetActive(true);

		if (info is ThrowableSkillInfo throwableInfo)
			playerData.pv.RPC("SetInfoSkill", RpcTarget.AllBuffered, throwableInfo.CurPosition, throwableInfo.Position, throwableInfo.Angle);
	}

	[PunRPC]
	public void SetInfoSkill(Vector3 curPos, Vector3 targetPos, float angle)
	{
		SetDistanceInfo(curPos, targetPos, angle);
	}

	public bool isUsableSkill()
	{
		return bisUsableSkill;
	}

	public override void Use()
	{
        playerData.pv.RPC("SpawnThrowWeaponSkill", RpcTarget.AllBuffered);
		//playerData.pv.RPC("SpawnThrowWeapon", RpcTarget.AllBuffered);
		skillDeltaTime = 0;
		bisUsableSkill = false;
        StartCoroutine(Cooldown(3f));
    }

	public override void SetWeapon(SupportWeaponInfo info)
	{
		throw new System.NotImplementedException();
	}

	[PunRPC]
	private void SpawnThrowWeaponSkill()
	{
		SetSpawnThrowWeapon();
	}

    public void LoadSkillIcon()
    {
        playScene.SetSkillIcon(CharacterType.Ned);
    }
}
