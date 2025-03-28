using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static Cinemachine.DocumentationSortingAttribute;

namespace BAEK
{ 
    public class FrameLoader : ImgLoaderBase
    {
        [SerializeField] Sprite[] frameSprites = new Sprite[34];

        public override IEnumerator Init()
        {
            yield return base.Init();
            for (int i = 0; i < rfSprites.Length; i++)
            {
                var load = rfSprites[i].LoadAssetAsync();
                yield return load;
                frameSprites[i] = load.Result;
            }
        }
        public override Sprite LoadImg(int index)
        {
            return frameSprites[index];
        }

    }
}
