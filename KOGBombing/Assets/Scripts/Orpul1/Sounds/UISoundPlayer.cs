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
    LOSE,
    START,
    WIN,
    SKILLCOLLDOWN,
    SKILLGEN,
    SKILLREADY,
    WEAPONEMPTYCLICK,
    WEAPONHIT1,
    WEAPONHIT2,
    WEAPONHIT3,
    WEAPONRELOAD,
    WEAPONSHOOTING
}
public class UISoundPlayer : MonoBehaviour
{
    
    [SerializeField] List<AudioClip> uiAudioClips = new List<AudioClip>();
    
    public void PlayUISound(EUiSoundType type)
    {
        SoundManager.Instance.PlayEffect(uiAudioClips[(int)type], EMixerGroup.UISOUND);
    }
}
