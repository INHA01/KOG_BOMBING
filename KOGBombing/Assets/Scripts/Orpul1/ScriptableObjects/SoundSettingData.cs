using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public enum EAudioPlay
{
    BGM,
    FOOTSTEP,
    GENERAL,
    HITDEATH,
    PING,
    SELECTION_READY,
    PLAYERSKILL,
    INTERACTION,
    MISSION,
    CURSOR_UI,
    EMOTICON_UI,
    MATCH_UI,
    POPUP_UI,
    ROUND_UI,
    SKILL_UI,
    WEAPON,
    END,
}

public enum EBGMSound
{
    BATTLE,
    THEME,
    END,
}
public enum EFootSound
{
    FOOTSTEP_1= 1,
    FOOTSTEP_11= 10,
    END,
}
public enum EGeneralSound
{
    CRAWL,
    FOOTSTEP,
    LOWHP,
    END,
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
    END,
}
public enum EPingSound
{
    NED_DANGER,
    NED_ENEMY,
    NED_HELP,
    NED, LOCATION,
    NED_MOVE,
    UNI_DANGER,
    UNI_ENEMY,
    UNI_HELP,
    UNI_LOCATION,
    UNI_MOVE,
    END,
}
public enum ESelectionReadySound
{
    NED_READY,
    NED_SELECT,
    UNI_READY,
    UNI_SELECT,
    END,
}
public enum ESkillSound
{
    NED_FLASH,
    NED_MINE,
    UNI_DASH,
    UNI_MINE,
    GREN,
    END,
}
public enum EInteractSound
{
    DOOR_INTERACT,
    DOOR_OPEN,
    INTER_GENERAL,
    END,
}

public enum EMissionSound
{
    BOMB_EXPLOSION,
    BOMB_BEEP,
    MISSION_BOMB_EXPLOSION,
    MISSOIN_BOMB_LAUNCHING,
    MISSION_BOMB_NARRATION,
    END,
}
public enum ECursorUISound
{
    CURSOR_CLICK,
    CURSOR_HOVER,
    END,
}
public enum EEmoticonSound
{
    COMMON1,
    COMMON2,
    ELVACIA1,
    NED1,
    TAU1,
    UNI1,
    UNI2,
    US1,
    END,
}
public enum EMatchUISound
{
    MATCH_FOUND_COUNT,
    MATCH_FOUND_SET,
    MATCH_START,
    END,
}

public enum EPopupUISound
{
    POPUP_BOMBLAUNCHED,
    POPUP_DOOR,
    END,
}

public enum ERoundUISound
{
    ROUND_LOSE,
    ROUND_START,
    ROUND_WIN,
    END,
}

public enum ESkillUISound
{
    SKILL_COOLDOWN,
    SKILL_GEN,
    SKILL_READY,
    END,
}
public enum EWeaponSound
{
    EMPTYCLICK,
    HIT1,
    HIT2,
    HIT3,
    RELOAD,
    SHOOTING,
    EXPLOSION,
    END,
}
[Serializable]
public class SoundInfo
{
    public EMixerGroup mixerGroup = EMixerGroup.EFFECT;
    public float spatialBlend = 0;
    public float minDistance = 0;
    public float maxDistance = 1;
}
[Serializable]
public class AudioClipList
{
    public List<AudioClip> bgm = new List<AudioClip>();
    public List<AudioClip> footStep = new List<AudioClip>();
    public List<AudioClip> general = new List<AudioClip>();
    public List<AudioClip> hitDeath = new List<AudioClip>();
    public List<AudioClip> ping = new List<AudioClip>();
    public List<AudioClip> selectionReady = new List<AudioClip>();
    public List<AudioClip> skill = new List<AudioClip>();
    public List<AudioClip> interaction = new List<AudioClip>();
    public List<AudioClip> mission = new List<AudioClip>();
    public List<AudioClip> cursorUI = new List<AudioClip>();
    public List<AudioClip> emoticonUI = new List<AudioClip>();
    public List<AudioClip> matchUI = new List<AudioClip>();
    public List<AudioClip> popupUI = new List<AudioClip>();
    public List<AudioClip> roundUI = new List<AudioClip>();
    public List<AudioClip> skillUI = new List<AudioClip>();
    public List<AudioClip> weapon = new List<AudioClip>();
}
[CreateAssetMenu(fileName = "SoundSettingData", menuName = "Datas/SoundSettingData")]
public class SoundSettingData : ScriptableObject
{
    public List<SoundInfo> soundInfoList = new List<SoundInfo>();
    public List<AudioClipList> audioClipList = new List<AudioClipList>();

}
