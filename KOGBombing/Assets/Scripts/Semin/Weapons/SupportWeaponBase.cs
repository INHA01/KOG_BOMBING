using Orpul1;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class SupportWeaponBase : ObjectPool, ISupportWeapon
{
	[SerializeField] public AttackConsum consum;
	protected ETeam team;
	protected int playerIndex;
	protected float range;
	protected float damage;
	protected int count = 10;
	protected PlayerData playerData;
	public float Damage { get { return damage; } }
	public WeaponType type;
	protected PlayScene playScene;
    //public int Count { get { return count; } }

    public virtual void SetConsum(WeaponType type, PlayerData playerData)
	{
        playScene = Managers.UI.GetPopupUI<UIPopup>("PlayCanvas").GetComponent<PlayScene>();
        switch (type)
		{
			case WeaponType.LANDMINE:
                consum = Managers.Resource.Load<AttackConsum>("Prefabs/SupportWeapon/Landmine");
				playScene.SetSubWeapon(type);
                break;
			case WeaponType.MOLOTOV:
				consum = Managers.Resource.Load<AttackConsum>("Prefabs/SupportWeapon/Molotov");
                playScene.SetSubWeapon(type);
                break;
			case WeaponType.BOMB:
                consum = Managers.Resource.Load<AttackConsum>("Prefabs/SupportWeapon/Bomb");
                break;
        }
		this.type = type;
		this.playerData = playerData;
    }
    public virtual void SetTeam(ETeam team, int playerIndex)
	{
		this.team = team;
		this.playerIndex = playerIndex;
    }

	public abstract void SetWeapon(SupportWeaponInfo info);
	public virtual void Use()
	{
		playScene.subWeaponFades[0].SetActive(true);
    }
	public virtual void Disable() { }

	public bool isUsable()
	{
		if (count <= 0)
			return false;
		return true;
	}

	public void InitializeCount(int count)
	{
		if (count == 1) 
			playScene.subWeaponFades[0].SetActive(false);
        this.count = count;
	}
}
