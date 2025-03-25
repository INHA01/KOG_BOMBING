using BAEK;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{
    public class PlayIconLoader : ImgLoaderBase
    {
        [SerializeField] Sprite[] playUISprites = new Sprite[(int)PlayUI.Max];
        public override Sprite LoadImg(int index)
        {
            return playUISprites[index];
        }
    }
}
