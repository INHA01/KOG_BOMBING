using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PhotonChooseAvatar
{
    Dictionary<int, ChooseAvatarIcon> dicOtherAvatar = new Dictionary<int, ChooseAvatarIcon>();
    public void AddPlayerAvatar(int key, ChooseAvatarIcon value)
    {
        if (dicOtherAvatar.ContainsKey(key)) return;
        dicOtherAvatar.Add(key, value);
    }
    public ChooseAvatarIcon GetPlayerAvatar(int key)
    {
        if (!dicOtherAvatar.ContainsKey(key)) return null;
        return dicOtherAvatar[key];
    }
}
