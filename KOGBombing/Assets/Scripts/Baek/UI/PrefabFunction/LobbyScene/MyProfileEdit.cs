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
        enum PanelType
        {
            ProfileEdit,
            ProfileImgEdit,
            Max
        }
        [SerializeField] GameObject[] profileEditPanel = new GameObject[(int)PanelType.Max];
        [SerializeField] TMPro.TMP_InputField nickName;
        [SerializeField] TMPro.TextMeshProUGUI profileDetail;
        [SerializeField] Image[] profileImage = new Image[(int)ProfileImg.Max];
        ProfileCharacterType profileType;
        void Start()
        {
            ChangeProfileImage(Managers.UserData.userData.profileType);
            nickName.text = Managers.UserData.userData.nickName;
            profileDetail.text = "level : " + Managers.UserData.userData.level + "\n" +
                                "kill : " + Managers.UserData.userData.kill + "\n" +
                                "death : " + Managers.UserData.userData.death + "\n" +
                                "assist : " + Managers.UserData.userData.assist + "\n" +
                                "mission : " + Managers.UserData.userData.mission + "\n" +
                                "win : " + Managers.UserData.userData.win + "\n" +
                                "lose : " + Managers.UserData.userData.lose + "\n";
            StartCoroutine(InitProfilImg());
        }
        IEnumerator InitProfilImg()
        { 
            yield return new WaitForSeconds(0.1f);
            ChangeProfileImage(Managers.UserData.userData.profileType);
        }

        public void OpenProfile()
        {
            profileEditPanel[(int)PanelType.ProfileEdit].SetActive(true);
        }
        public void CloseProfile()
        {
            ChangeProfileImage(Managers.UserData.userData.profileType);
            nickName.text = Managers.UserData.userData.nickName;
            profileEditPanel[(int)PanelType.ProfileImgEdit].SetActive(false);
            profileEditPanel[(int)PanelType.ProfileEdit].SetActive(false);
        }
        public void SaveProfile()
        {
            Managers.UserData.SettingNickName(nickName.text);
            Managers.UserData.userData.profileType = (int)profileType;
            Managers.UserData.SaveUserData();
            CloseProfile();
        }
        public void ProfileImgEditPopup()
        { 
            bool isOpen = profileEditPanel[(int)PanelType.ProfileImgEdit].activeSelf;
            profileEditPanel[(int)PanelType.ProfileImgEdit].SetActive(!isOpen);
        }
        public void ChangeProfileImage(int type)
        { 
            profileType = (ProfileCharacterType)type;
            profileImage[(int)ProfileImg.Standard].sprite = Managers.Resource.Load<Sprite>("UISettings/CharacterProfile/Crop/Profile_" + profileType.ToString());
            profileImage[(int)ProfileImg.Big].sprite = Managers.Resource.Load<Sprite>("UISettings/CharacterProfile/Profile_" + profileType.ToString());
            ProfileImgEditPopup();
        }
    }
}
