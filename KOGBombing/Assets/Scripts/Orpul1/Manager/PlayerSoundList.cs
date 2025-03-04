using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum EGenralSound
{
    CRAWL,
    FOOTSTEP,
    LOWHP
}

public class PlayerSoundList : MonoBehaviour
{
    public List<AudioClip> GeneralList = new List<AudioClip>();
    public List<AudioClip> HitDeathList = new List<AudioClip>();
    public List<AudioClip> PingList = new List<AudioClip>();
    public List<AudioClip> SkillList = new List<AudioClip>();
}
