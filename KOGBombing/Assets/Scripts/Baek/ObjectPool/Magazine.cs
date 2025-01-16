using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Magazine : ObjectPool
{
    protected override void Init()
    {
        GameObject parentInstance = Instantiate(parentPrefab);
        parentInstance.GetComponent<FollowPlayer>().Init(gameObject);
        parent = parentInstance.transform;
    }
    protected override void SetupPool()
    {
        base.SetupPool();
    }
}
