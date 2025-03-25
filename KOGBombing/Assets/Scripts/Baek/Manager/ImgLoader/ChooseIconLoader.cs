using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{ 
    public class ChooseIconLoader : ImgLoaderBase
    {
        [SerializeField] Sprite[] chooseIconSprites = new Sprite[(int)ProfileCharacterType.Max * 2];

        public void Reset()
        {
            for (int i = 0; i < (int)ProfileCharacterType.Max; i++)
            {
                ProfileCharacterType profileType = (ProfileCharacterType)i;
                chooseIconSprites[i] = Managers.Resource.Load<Sprite>("Prefabs/UIPrefabs/Scene/PlayScene/ChoosePlayer/Crop/Profile_" + profileType.ToString());
                chooseIconSprites[i + (int)ProfileCharacterType.Max] = Managers.Resource.Load<Sprite>("Prefabs/UIPrefabs/Scene/PlayScene/ChoosePlayer/Crop/Top_Profile_" + profileType.ToString());
            }
        }
        public override Sprite LoadImg(int index)
        {
            return chooseIconSprites[index];
        }

    }
}
