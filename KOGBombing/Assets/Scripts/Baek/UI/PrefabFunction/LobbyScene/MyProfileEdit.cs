using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
namespace BAEK
{
    public class MyProfileEdit : MonoBehaviour
    {
        enum ProfileImg
        {
            Standard,
            Big,
            Max
        }
        [SerializeField] GameObject profileEditPanel;
        [SerializeField] TMPro.TMP_InputField nickName;
        [SerializeField] Image[] profileImage = new Image[(int)ProfileImg.Max];
        ProfileCharacterType profileType;
        void Start()
        {
            ChangeProfileImage((ProfileCharacterType)Managers.UserData.userData.profileType);
            nickName.text = Managers.UserData.userData.nickName;
        }

        public void OpenProfile()
        {
            profileEditPanel.SetActive(true);
        }
        public void CloseProfile()
        {
            ChangeProfileImage((ProfileCharacterType)Managers.UserData.userData.profileType);
            nickName.text = Managers.UserData.userData.nickName;
            profileEditPanel.SetActive(false);
        }
        public void SaveProfile()
        {
            Managers.UserData.userData.profileType = (int)profileType;
            Managers.UserData.SettingNickName(nickName.text);
        }
        public void ChangeProfileImage(ProfileCharacterType type)
        { 
            profileType = type;
            profileImage[(int)ProfileImg.Standard].sprite = Managers.Resource.Load<Sprite>("UISettings/CharacterProfile/Crop/Profile_" + type.ToString());
            profileImage[(int)ProfileImg.Big].sprite = Managers.Resource.Load<Sprite>("UISettings/CharacterProfile/Profile_" + type.ToString());
        }
    }
}
