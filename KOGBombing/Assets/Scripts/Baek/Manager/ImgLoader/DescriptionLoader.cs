using BAEK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DescriptionLoader : ImgLoaderBase
{
    [SerializeField] Sprite[] descriptionSprites = new Sprite[(int)Description.Max];

    public override IEnumerator Init()
    {
        yield return base.Init();
        for (int i = 0; i < rfSprites.Length; i++)
        {
            var load = rfSprites[i].LoadAssetAsync();
            yield return load;
            descriptionSprites[i] = load.Result;
        }
    }

    public override Sprite LoadImg(int index)
    {
        return descriptionSprites[index];
    }
}
