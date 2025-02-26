using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.SubsystemsImplementation;

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
    public bool IsNull()
    {
        if (dicOtherAvatar.Count != 0 || dicOtherAvatar != null) 
            return false;
        return true;
    }
    public void RemoveAll()
    {
        dicOtherAvatar.Clear();
    }
    public List<ChooseAvatarIcon> GetPlayerAvatarList()
    {
        List<ChooseAvatarIcon> avatarList = new List<ChooseAvatarIcon>();
        for(int i=0; i<dicOtherAvatar.Count; i++)
        {
            avatarList.Add(dicOtherAvatar.ElementAt(i).Value);
        }
        return avatarList;
    }
}
