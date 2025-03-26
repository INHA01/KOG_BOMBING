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
    NED_MINE,
    UNI_DASH,
    UNI_MINE,
    GREN,
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
public enum EMissionSound
{
    BOMBLAUNCHING,
    BOMBNARRATION,
}
[Serializable]
public class FootSound
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

[Serializable]
public class SkillSound
{
    public List<AudioClip> SkillList;
    public void ActiveSound(Transform transform, ESkillSound soundType, EMixerGroup eMixer = EMixerGroup.ATTACKSOUND)
    {
        AudioClip skillSound = SkillList[(int)soundType];
        Managers.Sound.PlayEffect(skillSound, eMixer, transform, 1, 0, 30);
    }
}
[Serializable]
public class MissionSound
{
    public List<AudioClip> BombSound;
    public void ActiveSound(Transform transform, EMissionSound soundType)
    {
        AudioClip bombSound = BombSound[(int)soundType];
        Managers.Sound.PlayEffect(bombSound, EMixerGroup.CHARACTER, transform, 1, 0, 30);
    }
}
[Serializable]
public class WeaponSound
{
    public List<AudioClip> WeaponSoundList;
    public bool isPlayingSound;
    public void ActiveOneShotSound(Transform transform, EWeaponSound soundType)
    {
        Managers.Sound.StopRecentSound();
        AudioClip bombSound = WeaponSoundList[(int)soundType];
        Managers.Sound.PlayEffect(bombSound, EMixerGroup.ATTACKSOUND, transform, 1, 0, 30);
    }
    public IEnumerator CoOneShotSound(Transform transform, EWeaponSound soundType)
    {
        Debug.Log("PlayOneShot Sound");
        AudioClip bombSound = WeaponSoundList[(int)soundType];
        Managers.Sound.PlayEffect(bombSound, EMixerGroup.ATTACKSOUND, transform, 1, 0, 30);
        yield return new WaitForSeconds(bombSound.length);
        isPlayingSound = false;
    }
    public void ActiveSound(Transform transform, EWeaponSound soundType, EMixerGroup eMixer = EMixerGroup.ATTACKSOUND)
    {
        AudioClip bombSound = WeaponSoundList[(int)soundType];
        Managers.Sound.PlayEffect(bombSound, eMixer, transform, 1, 0, 30);
    }
}
[Serializable]
public class PingSound
{
    public List<AudioClip> PingSoundList;
    public void ActiveSound(Transform transform, EPingSound soundType)
    {
        AudioClip bombSound = PingSoundList[(int)soundType];
        Managers.Sound.PlayEffect(bombSound, EMixerGroup.CHARACTER, transform, 1, 0, 30);
    }
}
[Serializable]
public class HitDeathSound
{
    public List<AudioClip> HitDeathList;
    public void ActiveSound(Transform transform, EHitDeathSound soundType)
    {
        AudioClip bombSound = HitDeathList[(int)soundType];
        Managers.Sound.PlayEffect(bombSound, EMixerGroup.CHARACTER, transform, 1, 0, 30);
    }
}
[Serializable]
public class GeneralSound
{
    public List<AudioClip> GeneralList;
    public void ActiveSound(Transform transform, EGenralSound soundType)
    {
        AudioClip bombSound = GeneralList[(int)soundType];
        Managers.Sound.PlayEffect(bombSound, EMixerGroup.CHARACTER, transform, 1, 0, 30);
    }
}

public class PlayerSoundData : MonoBehaviour
{
    public GeneralSound generalSound = new GeneralSound();
    public HitDeathSound hitDeathSound = new HitDeathSound();
    public PingSound pingSound = new PingSound();
    public WeaponSound weaponSound = new WeaponSound();
    public FootSound footSound = new FootSound();
    public SkillSound skillSound = new SkillSound();
    public MissionSound missionSound = new MissionSound();
}
