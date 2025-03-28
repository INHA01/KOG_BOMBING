using BAEK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{
    public class PlayIconLoader : ImgLoaderBase
    {
        [SerializeField] Sprite[] playUISprites = new Sprite[(int)PlayUI.Max];

        public override IEnumerator Init()
        {
            yield return base.Init();
            for (int i = 0; i < rfSprites.Length; i++)
            {
                var load = rfSprites[i].LoadAssetAsync();
                yield return load;
                playUISprites[i] = load.Result;
            }
        }
        public override Sprite LoadImg(int index)
        {
            return playUISprites[index];
        }
    }
}
