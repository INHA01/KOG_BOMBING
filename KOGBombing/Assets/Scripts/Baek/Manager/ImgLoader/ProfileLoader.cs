using BAEK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProfileLoader : ImgLoaderBase
{
    [SerializeField] Sprite[] profileSprites = new Sprite[(int)ProfileCharacterType.Max * 2];
    public override Sprite LoadImg(int index)
    {
        return profileSprites[index];
    }
}
