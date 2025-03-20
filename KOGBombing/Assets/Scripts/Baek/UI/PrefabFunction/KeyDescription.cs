using System.Collections;
using System.Collections.Generic;
using Semin;
using UnityEngine;
using UnityEngine.UI;

namespace BAEK
{ 
    public class KeyDescription : UIPopup
    {
        [SerializeField] Image backGround;
        public void LoadImg(CharacterType type)
        {
            backGround.sprite = Managers.Resource.Load<Sprite>("UISettings/KeyDescription/SkillDescription_" + type.ToString());
        }
    }
}
