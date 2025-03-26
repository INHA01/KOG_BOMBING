using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static Cinemachine.DocumentationSortingAttribute;

namespace BAEK
{ 
    public class FrameLoader : ImgLoaderBase
    {
        [SerializeField] Sprite[] frameSprites = new Sprite[34];

        public void Reset()
        {
            for(int i = 0; i < 31; i++)
            {
                frameSprites[i] = Managers.Resource.Load<Sprite>("UISettings/Userframe/Gui_icon_userframe_" + (i+1).ToString());
            }
            for(int i = 31; i < 34; i++)
            {
                frameSprites[i] = Managers.Resource.Load<Sprite>("UISettings/End/End_UI_BayLeaf_" + (i - 31) + "_Icon");
            }
        }
        public override Sprite LoadImg(int index)
        {
            return frameSprites[index];
        }

    }
}
