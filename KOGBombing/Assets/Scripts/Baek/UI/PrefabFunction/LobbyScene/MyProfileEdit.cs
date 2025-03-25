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
        EmoticonType[] emoticonType = new EmoticonType[(int)PingPos.Max];
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
            for(int i = 0; i < (int)PingPos.Max; i++)
            {
                emoticonType[i] = (EmoticonType)Managers.UserData.userData.emoticon[i];
                emoticonImage[i].sprite = Managers.Resource.Load<Image>(FactoryType.Emoticon, (int)emoticonType[i]).sprite;
            }
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
            //profileEditPanel[(int)PanelType.ProfileImgEdit].SetActive(false);
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
            profileImage[(int)ProfileImg.Standard].sprite = Managers.Resource.LoadImg(ImgLoaderType.Profile, (int)profileType);
            profileImage[(int)ProfileImg.Big].sprite = Managers.Resource.LoadImg(ImgLoaderType.Profile, (int)profileType + (int)ProfileCharacterType.Max);
            //profileEditPanel[(int)PanelType.ProfileImgEdit].SetActive(false);
        }
        public void SelectEmoticon()
        {
            for(int i = 0; i < (int)PingPos.Max; i++)
            {
                Managers.UserData.userData.emoticon[i] = (int)emoticonType[i];
            }
            Managers.UI.GetPopupUI<Emoticon>(UIKEY.Emoticon).InitImoticon();
            Managers.UserData.SaveUserData();
        }
        public void ChangeEmoticon(int type)
        {
            EmoticonType eType = (EmoticonType)type;
            emoticonType[(int)pingPos] = (EmoticonType)type;
            emoticonImage[(int)pingPos].sprite = Managers.Resource.Load<Image>(FactoryType.Emoticon, (int)eType).sprite;
        }
    }
}

