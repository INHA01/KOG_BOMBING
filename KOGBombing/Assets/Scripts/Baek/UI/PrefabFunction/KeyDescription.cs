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
            Description imgType = type == CharacterType.Ned ? Description.PlayNedSkill : Description.PlayUniSkill;
            backGround.sprite = Managers.Resource.LoadImg(ImgLoaderType.Description, (int)imgType);
        }
    }
}
