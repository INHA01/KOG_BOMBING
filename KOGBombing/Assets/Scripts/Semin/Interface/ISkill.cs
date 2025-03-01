using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface ISkill 
{
    public void Use();
    public void InitializationSkill(PlayerData playerData);
    public void SetSkill(SkillInfo info);
    public bool isUsableSkill();
    public void InitializeCount(int count);
}
