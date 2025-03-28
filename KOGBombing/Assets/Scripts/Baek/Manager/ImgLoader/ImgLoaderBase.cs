using BAEK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;

public abstract class ImgLoaderBase : MonoBehaviour
{
    [SerializeField] protected AssetReferenceSprite[] rfSprites;
    public virtual IEnumerator Init()
    {
        yield return Addressables.InitializeAsync();
    }
    public abstract Sprite LoadImg(int index);
}
