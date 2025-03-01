using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeployableBomb : DeployableBase
{
    Vector3 position;
    ObjectPool objectPool;
    public BombInteraction bombInteraction;
	public override void SetTeam(ETeam team, int playerIndex)
	{
        base.SetTeam(team, playerIndex);

		if (team == ETeam.REDTEAM)
		{
            bombInteraction = GetComponent<BombInteraction>();
			count = 1;
			objectPool = gameObject.AddComponent<ObjectPool>();
			PooledObject child = Managers.Resource.Load<PooledObject>("Prefabs/SupportWeapon/Bomb");
			objectPool.SetObjectToPool(child);
			objectPool.SetParentPrefab(Managers.Resource.Load<GameObject>("Prefabs/SupportWeapon/WeaponMagazine"));
			objectPool.initPoolSize = count;
		}
	}
    public override void InitializeCount(int count)
    {
        if (count > 0)
            playScene.subWeaponFades[1].SetActive(false);
        this.count = count;
    }

    public override void Use()
    {
        count--;
        PlayScene playScene = Managers.UI.GetPopupUI<UIPopup>("PlayCanvas").GetComponent<PlayScene>();
        playScene.subWeaponFades[1].SetActive(true);
        playerData.pv.RPC("PutBomb", RpcTarget.AllBuffered);
    }

    [PunRPC]
    public virtual void PutBomb()
    {
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
        yield return null;
		if ((ETeam)playerData.pv.Owner.CustomProperties["Team"] == ETeam.REDTEAM)
        {
		    Bomb bomb = objectPool.GetPooledObject().GetComponent<Bomb>();
            bomb.transform.position = playerData.ConsumPos.position;
            bomb.Notify();
            bomb.SetTeam((int)team);
            bomb.Use();
            GameObject[] players = GameObject.FindGameObjectsWithTag("Player");
            for (int i = 0; i < players.Length; i++)
                players[i].GetComponent<BombInteraction>().SetBomb(bomb);
		}
		else
		{
            PlayerBlackBoard blackBoard = this.GetComponent<PlayerBlackBoard>();
			blackBoard.playerStatus.isBombDefuse = true;
		}
	}
}
