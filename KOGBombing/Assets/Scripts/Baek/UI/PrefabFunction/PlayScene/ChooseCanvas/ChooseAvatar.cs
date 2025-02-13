using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChooseAvatar : ChooseObserver
{
    [SerializeField] GameObject[] avatars;
    public override void Choosing(int index)
    {
        if (index == 0)
        {
            avatars[0].SetActive(true);
            avatars[1].SetActive(false);
        }
        else
        {
            avatars[0].SetActive(false);
            avatars[1].SetActive(true);
        }
    }
}
