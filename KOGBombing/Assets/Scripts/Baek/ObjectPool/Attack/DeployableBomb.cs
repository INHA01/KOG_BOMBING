using Orpul1;
using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeployableBomb : DeployableBase
{
    Vector3 position;
    ObjectPool objectPool;
    private void Awake()
    {
        count = 1;
        objectPool = gameObject.AddComponent<ObjectPool>();
        objectPool.SetObjectToPool(Managers.Resource.Load<PooledObject>("Prefabs/SupportWeapon/Bomb"));
        objectPool.SetParentPrefab(Managers.Resource.Load<GameObject>("Prefabs/SupportWeapon/WeaponMagazine"));
        objectPool.initPoolSize = count;
    }
    public override void SetWeapon(SupportWeaponInfo info)
    {
        if (consum == null)
            return;

        position = info.Position;
    }
    [PunRPC]
    public override void PutConsum()
    {
        StartCoroutine(PutAfterAnim());
    }
    protected override IEnumerator PutAfterAnim()
    {
        yield return null;
        if ((ETeam)playerData.pv.Owner.CustomProperties["Team"] == ETeam.REDTEAM)
        {
            Bomb bomb = objectPool.GetPooledObject().GetComponent<Bomb>();
            bomb.transform.position = playerData.ConsumPos.position;
            bomb.SetTeam((int)team);
            bomb.Use();
        }
        else
        {
            // ÆøÅº ÇØÁ¦
            gameObject.GetComponent<PlayerBlackBoard>().playerStatus.isBombDefuse = true;
        }
    }
}
