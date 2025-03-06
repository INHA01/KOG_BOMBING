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

        switch (type)
		{
			case WeaponType.LANDMINE:
                consum = LocalManagers.Resource.Load<AttackConsum>("Prefabs/SupportWeapon/Landmine");
                break;
			case WeaponType.MOLOTOV:
				consum = LocalManagers.Resource.Load<AttackConsum>("Prefabs/SupportWeapon/Molotov");
                break;
			case WeaponType.BOMB:
                consum = LocalManagers.Resource.Load<AttackConsum>("Prefabs/SupportWeapon/Bomb");
                break;
        }
		this.type = type;
		this.playerData = playerData;
		if(playerData.pv.IsMine)
		{
			if(playScene == null)
				playScene = LocalManagers.UI.ShowPopupUI<UIPopup>("PlayCanvas").GetComponent<PlayScene>();
			else
				playScene = LocalManagers.UI.GetPopupUI<PlayScene>("PlayCanvas");
			if(type != WeaponType.BOMB)
				playScene.SetSubWeaponIcon(type);
		}
    }
    public virtual void SetTeam(ETeam team, int playerIndex)
	{
		this.team = team;
		this.playerIndex = playerIndex;
    }

	public abstract void SetWeapon(SupportWeaponInfo info);
	public virtual void Use()
	{
		if(playerData.pv.IsMine)
			playScene.subWeaponFades[0].SetActive(true);
    }
	public virtual void Disable() { }

	public bool isUsable()
	{
		if (count <= 0)
			return false;
		return true;
	}

	public virtual void Initialize(int count)
	{
		if (count > 0 && playerData.pv.IsMine) 
			playScene.subWeaponFades[0].SetActive(false);
        this.count = count;
	}

    public virtual void LoadWeaponIcon()
    {
        playScene.SetSubWeaponIcon(type);
    }
}
