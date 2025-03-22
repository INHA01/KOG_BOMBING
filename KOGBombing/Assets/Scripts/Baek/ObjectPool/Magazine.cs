using Orpul1;
using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BAEK;

public abstract class Magazine : ObjectPool
{
    protected override void Init()
    {
        PlayerData playerData = GetComponent<PlayerData>();
        ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()];

        if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()] != playerTeam)
            SetObjectToPool(Managers.Resource.Load<PooledObject>(FactoryType.Attack, (int)AttackPrefab.BulletHide));
        //SetObjectToPool(Managers.Resource.Load<PooledObject>("Prefabs/AttackPrefabs/Bullet/Effect_02ToHide"));
        //parentPrefab = Managers.Resource.Instantiate("AttackPrefabs/Magazine");
        parentPrefab = Managers.Resource.Instantiate(FactoryType.Attack, (int)AttackPrefab.Magazine);
        parent = parentPrefab.transform;
    }
}
