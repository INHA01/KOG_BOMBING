using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ChooseAvatarIcon : ChooseObserver
{
    [SerializeField] Image image;
    [SerializeField] Image topImage;
    [SerializeField] public TextMeshProUGUI nicknameText;
    [SerializeField] public TextMeshProUGUI levelText;
    [SerializeField] Image levelFrame;
    public int level;
    public override void Choosing(int index)
    {
        level = level > 31 ? 31 : level;
        levelFrame.sprite = Managers.Resource.Load<Sprite>("UISettings/Userframe/Gui_icon_userframe_" + level.ToString());
        switch (index)
        {
            case 0:
                image.sprite = Managers.Resource.Load<Sprite>("Prefabs/UIPrefabs/Scene/PlayScene/ChoosePlayer/Crop/Profile_Ned_2");
				topImage.sprite = Managers.Resource.Load<Sprite>("Prefabs/UIPrefabs/Scene/PlayScene/ChoosePlayer/Crop/Top_Profile_Ned_2");
				break;
            case 1:
                Sprite sprite = Managers.Resource.Load<Sprite>("Prefabs/UIPrefabs/Scene/PlayScene/ChoosePlayer/Crop/Profile_Uni_1");
				image.sprite = sprite;
				topImage.sprite = Managers.Resource.Load<Sprite>("Prefabs/UIPrefabs/Scene/PlayScene/ChoosePlayer/Crop/Top_Profile_Uni_1");
                break;
        }
    }
    public void SettingText(string nickname, int level)
    {
        this.level = level;
        nicknameText.text = nickname;
        levelText.text = level.ToString();
    }
}
