using BAEK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DescriptionLoader : ImgLoaderBase
{
    [SerializeField] Sprite[] descriptionSprites = new Sprite[(int)Description.Max];

    public override Sprite LoadImg(int index)
    {
        return descriptionSprites[index];
    }
}
