using BAEK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProfileLoader : ImgLoaderBase
{
    [SerializeField] Sprite[] profileSprites = new Sprite[(int)ProfileCharacterType.Max * 2];
    
    public override IEnumerator Init()
    {
        yield return base.Init();
        for (int i = 0; i < rfSprites.Length; i++)
        {
            var load = rfSprites[i].LoadAssetAsync();
            yield return load;
            profileSprites[i] = load.Result;
        }
    }
    public override Sprite LoadImg(int index)
    {
        return profileSprites[index];
    }
}
