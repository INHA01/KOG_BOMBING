using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using BAEK;

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
        levelFrame.sprite = Managers.Resource.LoadImg(ImgLoaderType.Frame, level - 1);
        switch (index)
        {
            case 0:
                image.sprite = Managers.Resource.LoadImg(ImgLoaderType.ChooseAvatar, (int)ProfileCharacterType.Ned_2);
                topImage.sprite = Managers.Resource.LoadImg(ImgLoaderType.ChooseAvatar, (int)ProfileCharacterType.Ned_2 + (int)ProfileCharacterType.Max);
                break;
            case 1:
				image.sprite = Managers.Resource.LoadImg(ImgLoaderType.ChooseAvatar, (int)ProfileCharacterType.Uni_1);
                topImage.sprite = Managers.Resource.LoadImg(ImgLoaderType.ChooseAvatar, (int)ProfileCharacterType.Uni_1 + (int)ProfileCharacterType.Max);
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
