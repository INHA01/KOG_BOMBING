using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum EGenralSound
{
    CRAWL,
    FOOTSTEP,
    LOWHP
}
public enum EHitDeathSound
{
    NED_DEATH,
    NED_HIT1,
    NED_HIT2,
    NED_HIT3,
    UNI_DEATH,
    UNI_HIT1,
    UNI_HIT2,
    UNI_HIT3,
    PLAYERKILL,
}
public enum EPingSound
{
    NED_DANGER,
    NED_ENEMY,
    NED_HELP,
    NED,LOCATION,
    NED_MOVE,
    UNI_DANGER,
    UNI_ENEMY,
    UNI_HELP,
    UNI_LOCATION,
    UNI_MOVE,
}
public enum ESkillSound
{
    NED_FLASH,
    NED_GREN,
    UNI_DASH,
    UNI_GREN,
    UNI_MINE
}
public enum EWeaponSound
{
    EMPTYCLICK,
    HIT1,
    HIT2,
    HIT3,
    RELOAD,
    SHOOTING,
    EXPLOSION
}

[Serializable]
public struct FootSound
{
    enum EFootStepSound
    {
        FOOTSTEP1 = 0,
        FOOTSTEP11 = 10,
    }
    public List<AudioClip> FootStepList;
    public float activeSoundTime;
    float time;
    int footIndex;
    public void ActiveSound(Transform transform)
    {
        time += Time.deltaTime;
        if (time <= activeSoundTime) return;
        footIndex++;
        AudioClip footStep = FootStepList[footIndex % (int)EFootStepSound.FOOTSTEP11];
        Managers.Sound.PlayEffect(footStep, EMixerGroup.EFFECT, transform, 1, 0, 30);
        time = 0;
    }
}
public class PlayerSoundData : MonoBehaviour
{
    public List<AudioClip> GeneralList = new List<AudioClip>();
    public List<AudioClip> HitDeathList = new List<AudioClip>();
    public List<AudioClip> PingList = new List<AudioClip>();
    public List<AudioClip> SkillList = new List<AudioClip>();
    public List<AudioClip> WeaponList = new List<AudioClip>();
    public FootSound footSound;
}
