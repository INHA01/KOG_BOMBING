using BAEK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProfileLoader : ImgLoaderBase
{
    [SerializeField] Sprite[] profileSprites = new Sprite[(int)ProfileCharacterType.Max * 2];
    public void Reset()
    {
        for(int i = 0; i < (int)ProfileCharacterType.Max; i++)
        {
            ProfileCharacterType profileType = (ProfileCharacterType)i;
            profileSprites[i] = Managers.Resource.Load<Sprite>("UISettings/CharacterProfile/Crop/Profile_" + profileType.ToString());
            profileSprites[i + (int)ProfileCharacterType.Max] = Managers.Resource.Load<Sprite>("UISettings/CharacterProfile/Profile_" + profileType.ToString());
        }
    }
    public override Sprite LoadImg(int index)
    {
        return profileSprites[index];
    }
}
