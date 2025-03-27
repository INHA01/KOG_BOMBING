using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;

public abstract class FactoryBase : MonoBehaviour
{
    [SerializeField] protected AssetReferenceGameObject[] rfPrefabs;
    public abstract void Init();
    public abstract T GetPrefab<T>(int index);
}
