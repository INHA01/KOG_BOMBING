using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;

public abstract class FactoryBase : MonoBehaviour
{
    [SerializeField] List<AssetReferenceGameObject> rfPrefabs = new List<AssetReferenceGameObject>();
    public abstract void Init();
    public abstract T GetPrefab<T>(int index);
}
