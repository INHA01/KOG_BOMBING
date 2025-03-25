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

        [SerializeField] Animator skillStoryAnimator;

        void Start()
        {
            currentStatus = lobbyPlayerStatus[(int)CharacterType.Ned];
            LoadPlayerStatus();
            rot = lobbyPlayer.transform.localEulerAngles;
            lobbyPlayerTypes[(int)CharacterType.Ned].SetActive(true);
            lobbyPlayerTypes[(int)CharacterType.Uni].SetActive(false); 
            skillStoryAnimator.Play("Close Description", -1, 0);
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
			skillStoryAnimator.Play("Start", -1, 0);
            //StartCoroutine(StartChangePlayer(type));
            OpenPanel(type);
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
        void OpenPanel(int type)
        {
            if(!skillStoryAnimator.GetCurrentAnimatorStateInfo(0).IsName("Close Description"))
            {
                ClosePanel();
                return;
			}
            Debug.Log($"Open Panel, type: {type.ToString()}");

			for (int i = 0; i < (int)CharacterType.Max; i++)
			{
				if (i == type)
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
			//descriptionParent.SetActive(true);
			skillStoryAnimator.Play("Click Skill", -1, 0);
			skillStoryAnimator.Play("Open Description", -1, 0);
			detailPanel[(int)Panel.Common].SetActive(true);
            detailPanel[(int)Panel.Story].SetActive(false);
			//detailPanel[(int)Panel.SkillDetail].SetActive(false);
        }
        void ClosePanel()
        {
			//descriptionParent.SetActive(false);
			skillStoryAnimator.Play("Close Description", -1, 0);
		}
        public void SwitchPanel(int type)
        {
            Managers.Sound.PlayUISound(EUiSoundType.CLICK);

            switch (type)
            {
                case (int)Panel.Common:
                    detailPanel[(int)Panel.Common].SetActive(true);
					detailPanel[(int)Panel.Story].SetActive(false);
                    //detailPanel[(int)Panel.SkillDetail].SetActive(false);
					switchButtons[(int)Button.Common].sprite = Managers.Resource.LoadImg(ImgLoaderType.Description, (int)Description.Common_Select);
                    switchButtons[(int)Button.Story].sprite = Managers.Resource.LoadImg(ImgLoaderType.Description, (int)Description.Story);
                    skillStoryAnimator.Play("Click Skill", -1, 0);
					break;
                case (int)Panel.Story:
					detailPanel[(int)Panel.Common].SetActive(false);
					detailPanel[(int)Panel.Story].SetActive(true);
					//detailPanel[(int)Panel.SkillDetail].SetActive(false);
					switchButtons[(int)Button.Story].sprite = Managers.Resource.LoadImg(ImgLoaderType.Description, (int)Description.Story_Select);
                    switchButtons[(int)Button.Common].sprite = Managers.Resource.LoadImg(ImgLoaderType.Description, (int)Description.Common);
                    skillStoryAnimator.Play("Click Story", -1, 0);
					break;
            }
        }

        public void LoadSkillDetail(int type)
        {
            skillDescription.text = currentStatus.description[type];
            skillName.text = currentStatus.skillName[type];
            skillIcon.sprite = currentStatus.skillIcon[type];
            videoPlayer.clip = currentStatus.skillVideoClip[type];
            //detailPanel[(int)Panel.SkillDetail].SetActive(true);

			if (!skillStoryAnimator.GetCurrentAnimatorStateInfo(0).IsName("Show Sill Info"))
				skillStoryAnimator.Play("Show Sill Info", -1, 0);

		}
        #endregion
    }
}
