using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public enum EUiSoundType
{
    CLICK,
    HOVER,
    MATCHFOUNDCOMBINED,
    MATCHFOUNDCOUNT,
    MATCHFOUNDSET,
    MATCHSTART,
    BOMBLAUNCHED,
    OPENDOOR,
    WIN,
    LOSS,
    ROUNDSTART,
    SKILLCOLLDOWN,
    SKILLREADY,
}
public class UISoundPlayer : MonoBehaviour
{
    
    [SerializeField] List<AudioClip> uiAudioClips = new List<AudioClip>();
    
    public void PlayUISound(EUiSoundType type)
    {
        Managers.Sound.PlayEffect(uiAudioClips[(int)type], EMixerGroup.UISOUND);
    }
}
