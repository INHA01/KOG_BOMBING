using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;

public abstract class FactoryBase : MonoBehaviour
{
    [SerializeField] protected AssetReferenceGameObject[] rfPrefabs;
    public virtual IEnumerator Init()
    {
        yield return Addressables.InitializeAsync();
    }
    public abstract T GetPrefab<T>(int index);
}
