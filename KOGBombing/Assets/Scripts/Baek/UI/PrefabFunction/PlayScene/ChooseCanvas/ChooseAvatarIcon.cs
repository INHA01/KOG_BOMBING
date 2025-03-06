using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ChooseAvatarIcon : ChooseObserver
{
    [SerializeField] Image image;
    public override void Choosing(int index)
    {
        switch(index)
        {
            case 0:
                image.sprite = LocalManagers.Resource.Load<Sprite>("Prefabs/UIPrefabs/Scene/PlayScene/ChoosePlayer/Avatar_Ned");
                break;
            case 1:
                Sprite sprite = LocalManagers.Resource.Load<Sprite>("Prefabs/UIPrefabs/Scene/PlayScene/ChoosePlayer/Avatar_Uni");
                image.sprite = sprite;
                break;
        }
    }
}
