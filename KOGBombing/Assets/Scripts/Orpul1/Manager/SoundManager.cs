using System.Collections;
using System;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.SceneManagement;

public enum EMixerGroup
{
    BGM,
    EFFECT,
    UISOUND,
    CHARACTER,
    ATTACKSOUND,
    EXTRA_ATKSOUND,
}
public class SoundManager : MonoBehaviour
{
    enum ESceneBGM
    {
        LobbyScene,
        MainGame,
        END
    }
    [SerializeField] GameObject audioPlayerPrefab;
    [SerializeField] SoundSettingData soundData;
    List<SoundPlayer> soundPlayers = new List<SoundPlayer>();
    public void Init()
    {
        for (int i = 0; i < (int)EAudioPlay.END; i++)
        {

            SetSoundObj((EAudioPlay)i);
        }
    }
    private void SetSoundObj(EAudioPlay playType)
    {
        soundData.audioClipList[(int)playType].bgm
        for(int i=0; i<)
        {
            SoundPlayer soundPlayer = Instantiate(audioPlayerPrefab, transform).GetComponent<SoundPlayer>();
            soundPlayer.SetSound(soundData.audioClipList[])
            soundPlayers.Add(soundPlayer);
        }
            
    }
}
