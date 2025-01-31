using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Magazine : ObjectPool
{
    protected override void Init()
    {
        GameObject parentInstance = Instantiate(parentPrefab);
        parent = parentInstance.transform;
    }
}
