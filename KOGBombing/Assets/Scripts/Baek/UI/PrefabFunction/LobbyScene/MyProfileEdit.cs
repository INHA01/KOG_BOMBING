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
            EmoticonEdit,
            Max
        }
        [SerializeField] GameObject[] profileEditPanel = new GameObject[(int)PanelType.Max];
        [SerializeField] TMPro.TMP_InputField nickName;
        [SerializeField] TMPro.TextMeshProUGUI profileDetail;
        [SerializeField] Image[] profileImage = new Image[(int)ProfileImg.Max];
        ProfileCharacterType profileType;
        [Header("Emoticon")]
        public PingPos pingPos = PingPos.Left;
        EmoticonType emoticonType;
        [SerializeField] Image[] emoticonImage = new Image[(int)PingPos.Max];
        void Start()
        {
            StartCoroutine(InitProfilData());
        }
        void InitProfile()
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
            EmoticonType top = (EmoticonType)Managers.UserData.userData.emoticonT;
            EmoticonType bottom = (EmoticonType)Managers.UserData.userData.emoticonB;
            EmoticonType right = (EmoticonType)Managers.UserData.userData.emoticonR;
            EmoticonType left = (EmoticonType)Managers.UserData.userData.emoticonL;
            emoticonImage[(int)PingPos.Top].sprite = Managers.Resource.Load<Sprite>("UISettings/Emoticon/" + top.ToString());
            emoticonImage[(int)PingPos.Bottom].sprite = Managers.Resource.Load<Sprite>("UISettings/Emoticon/" + bottom.ToString());
            emoticonImage[(int)PingPos.Right].sprite = Managers.Resource.Load<Sprite>("UISettings/Emoticon/" + right.ToString());
            emoticonImage[(int)PingPos.Left].sprite = Managers.Resource.Load<Sprite>("UISettings/Emoticon/" + left.ToString());
        }
        IEnumerator InitProfilData()
        {
            yield return new WaitForSeconds(0.1f);
            InitProfile();
        }

        public void OpenProfile()
        {
            profileEditPanel[(int)PanelType.ProfileEdit].SetActive(true);
        }
        public void CloseProfile()
        {
            ChangeProfileImage(Managers.UserData.userData.profileType);
            StartCoroutine(InitProfilData());
            profileEditPanel[(int)PanelType.ProfileImgEdit].SetActive(false);
            //profileEditPanel[(int)PanelType.ProfileEdit].SetActive(false);
        }
        public void SaveProfile()
        {
            Managers.UserData.SettingNickName(nickName.text);
            Managers.UserData.userData.profileType = (int)profileType;
            Managers.UserData.SaveUserData();
            Lobby lobby = GetComponent<Lobby>();
            lobby.SetNickName(nickName.text);
            CloseProfile();
        }
        public void ProfileImgEditPopup(int type = 1)
        {
            bool isOpen = profileEditPanel[type].activeSelf;
            int anotherType = type == 1 ? 2 : 1;
            profileEditPanel[type].SetActive(!isOpen);
            profileEditPanel[anotherType].SetActive(false);
        }
        public void ChangeProfileImage(int type)
        {
            profileType = (ProfileCharacterType)type;
            profileImage[(int)ProfileImg.Standard].sprite = Managers.Resource.Load<Sprite>("UISettings/CharacterProfile/Crop/Profile_" + profileType.ToString());
            profileImage[(int)ProfileImg.Big].sprite = Managers.Resource.Load<Sprite>("UISettings/CharacterProfile/Profile_" + profileType.ToString());
            //profileEditPanel[(int)PanelType.ProfileImgEdit].SetActive(false);
        }
        public void SelectEmoticon()
        {
            switch (pingPos)
            {
                case PingPos.Top:
                    Managers.UserData.userData.emoticonT = (int)emoticonType;
                    break;
                case PingPos.Bottom:
                    Managers.UserData.userData.emoticonB = (int)emoticonType;
                    break;
                case PingPos.Right:
                    Managers.UserData.userData.emoticonR = (int)emoticonType;
                    break;
                case PingPos.Left:
                    Managers.UserData.userData.emoticonL = (int)emoticonType;
                    break;
            }
            Managers.UserData.SaveUserData();
            Managers.UI.GetPopupUI<Emoticon>(UIKEY.Emoticon).InitImoticon();
            //profileEditPanel[(int)PanelType.EmoticonEdit].SetActive(false);
        }
        public void ChangeEmoticon(int type)
        {
            emoticonType = (EmoticonType)type;
            emoticonImage[(int)pingPos].sprite = Managers.Resource.Load<Sprite>("UISettings/Emoticon/" + emoticonType.ToString());
        }
    }
}

