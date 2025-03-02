using Orpul1;
using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Magazine : ObjectPool
{
    protected override void Init()
    {
        PlayerData playerData = GetComponent<PlayerData>();
        ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties[(int)EPropertyType.TEAM];

        if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties[(int)EPropertyType.TEAM] != playerTeam)
            SetObjectToPool(Managers.Resource.Load<PooledObject>("Prefabs/AttackPrefabs/Bullet/Effect_02ToHide"));
        GameObject parentInstance = Instantiate(parentPrefab);
        parent = parentInstance.transform;
    }
}
