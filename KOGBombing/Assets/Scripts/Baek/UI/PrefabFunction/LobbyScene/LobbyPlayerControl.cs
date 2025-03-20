using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using Semin;
using TMPro;
using UnityEngine.Video;

namespace BAEK
{
    public class LobbyPlayerControl : MonoBehaviour, IDragHandler
    {
        enum Button
        { 
            Common,
            Story,
            Max
        }
        enum Panel
        {
            Common,
            Story,
            SkillDetail,
            Max
        }
        [Header("LobbyPlayerControl")]
        [SerializeField] GameObject lobbyPlayer;
        [SerializeField] GameObject[] lobbyPlayerTypes = new GameObject[(int)CharacterType.Max];
        [SerializeField] float rotateSpeed = 10f;
        Vector3 rot;
        [Header("Detail")]
        [SerializeField] GameObject descriptionParent;
        [SerializeField] GameObject[] detailPanel = new GameObject[(int)Panel.Max];
        [SerializeField] LobbyPlayerStatus[] lobbyPlayerStatus = new LobbyPlayerStatus[(int)CharacterType.Max];
        [SerializeField] Image[] switchButtons = new Image[(int)Button.Max];
        [SerializeField] TextMeshProUGUI skillDescription;
        [SerializeField] TextMeshProUGUI skillName;
        [SerializeField] Image skillIcon;
        [SerializeField] VideoPlayer videoPlayer;
        [SerializeField] Image[] detailImgs = new Image[(int)SpriteType.Max];
        LobbyPlayerStatus currentStatus;

        void Start()
        {
            currentStatus = lobbyPlayerStatus[(int)CharacterType.Ned];
            LoadPlayerStatus();
            rot = lobbyPlayer.transform.localEulerAngles;
            lobbyPlayerTypes[(int)CharacterType.Ned].SetActive(true);
            lobbyPlayerTypes[(int)CharacterType.Uni].SetActive(false);
        }
        #region LobbyPlayerControl
        public void OnDrag(PointerEventData eventData)
        {
            rot.y += eventData.delta.x * rotateSpeed * Time.deltaTime;
            lobbyPlayer.transform.localEulerAngles = -rot;
        }
        public void ChangePlayer(int type)
        {
            Managers.Sound.PlayUISound(EUiSoundType.CLICK);
            for(int i = 0; i < (int)CharacterType.Max; i++)
            {
                if(i == type)
                {
                    lobbyPlayerTypes[i].SetActive(true);
                }
                else
                {
                    lobbyPlayerTypes[i].SetActive(false);
                }
            }
            currentStatus = lobbyPlayerStatus[type];
            LoadPlayerStatus();
            OpenPanel();
        }
        #endregion
        #region Detail
        void LoadPlayerStatus()
        {
            for (int i = 0; i < (int)SpriteType.Max; i++)
            {
                detailImgs[i].sprite = currentStatus.sprites[i];
            }
        }
        void OpenPanel()
        {
            if(descriptionParent.activeSelf)
            {
                ClosePanel();
                return;
            }
            descriptionParent.SetActive(true);
            detailPanel[(int)Panel.Common].SetActive(true);
            detailPanel[(int)Panel.Story].SetActive(false);
            detailPanel[(int)Panel.SkillDetail].SetActive(false);
        }
        void ClosePanel()
        {
            descriptionParent.SetActive(false);
        }
        public void SwitchPanel(int type)
        {
            Managers.Sound.PlayUISound(EUiSoundType.CLICK);
            Panel panel = (Panel)type;
            for (int i = 0; i < (int)Panel.Max; i++)
            {
                if (i == type)
                {
                    detailPanel[i].SetActive(true);
                    if (i < (int)Button.Max)
                        switchButtons[i].sprite = Managers.Resource.Load<Sprite>("UISettings/CharacterDescription/Character_Description_Button_" + panel.ToString() + "_Select");
                }
                else
                {
                    detailPanel[i].SetActive(false);
                    if(i < (int)Button.Max)
                        switchButtons[i].sprite = Managers.Resource.Load<Sprite>("UISettings/CharacterDescription/Character_Description_Button_" + panel.ToString());
                }
            }
        }
        public void LoadSkillDetail(int type)
        {
            skillDescription.text = currentStatus.description[type];
            skillName.text = currentStatus.skillName[type];
            skillIcon.sprite = currentStatus.skillIcon[type];
            videoPlayer.clip = currentStatus.skillVideoClip[type];
            detailPanel[(int)Panel.SkillDetail].SetActive(true);
        }
        #endregion
    }
}
