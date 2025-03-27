using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;

public class AddressableManager : MonoBehaviour
{
    [SerializeField] AssetReferenceGameObject[] assetReferenceGameObjects;
    [SerializeField] AssetReferenceSprite[] assetReferenceSprites;
    [SerializeField] List<GameObject> gameObjects = new List<GameObject>();
    [SerializeField] List<Sprite> sprites = new List<Sprite>();

    private void Start()
    {
        StartCoroutine(Initialize());
    }
    // 프로젝트 종료시 호출
    void OnApplicationQuit()
    {
        Release();
    }
    IEnumerator Initialize()
    {
        var init = Addressables.InitializeAsync();
        yield return init;
        LoadAsset();
    }
    void LoadAsset()
    {
        for(int i = 0; i < assetReferenceGameObjects.Length; i++)
        {
            assetReferenceGameObjects[i].LoadAssetAsync().Completed += (load) =>
            {
                gameObjects.Add(load.Result);
            };
        }
        for(int i = 0; i < assetReferenceSprites.Length; i++)
        {
            assetReferenceSprites[i].LoadAssetAsync().Completed += (load) =>
            {
                sprites.Add(load.Result);
            };
        }
    }
    public void Release()
    {
        for (int i = 0; i < gameObjects.Count; i++)
        {
            Addressables.ReleaseInstance(gameObjects[i]);
        }
        for (int i = 0; i < sprites.Count; i++)
        {
            Addressables.Release(sprites[i]);
        }

    }
}
