using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{ 
    public class ChooseIconLoader : ImgLoaderBase
    {
        [SerializeField] Sprite[] chooseIconSprites = new Sprite[(int)ProfileCharacterType.Max * 2];

        public override IEnumerator Init()
        {
            yield return base.Init();
            for (int i = 0; i < rfSprites.Length; i++)
            {
                var load = rfSprites[i].LoadAssetAsync();
                yield return load;
                chooseIconSprites[i] = load.Result;
            }
        }
        public override Sprite LoadImg(int index)
        {
            return chooseIconSprites[index];
        }

    }
}
