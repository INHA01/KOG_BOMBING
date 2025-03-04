using System.Collections;
using System;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.SceneManagement;

public class SoundManager : SingleTon<SoundManager>
{
    enum ESceneBGM
    {
        LobbyScene,
        MainGame,
        END
    }
    enum EMixerGroup
    {
        BGM,
        EFFECT
    }
    [SerializeField] AudioSource bgmPlayer;
    [SerializeField] AudioClip[] bgmClipList;
    [SerializeField] AudioMixer audioMixer;
    [SerializeField] UISoundPlayer uiSoundPlayer;
    Action<EUiSoundType> playerUISound;
    Dictionary<string, AudioClip> bgmDict = new Dictionary<string, AudioClip>();

    private void Start()
    {
        SceneManager.sceneLoaded += OnLoadScene;
    }

    protected override void Initialize()
    {
        for (int i = 0; i < (int)ESceneBGM.END; i++)
        {
            ESceneBGM eSceneBGM = (ESceneBGM)i;
            bgmDict.Add(eSceneBGM.ToString(), bgmClipList[i]);
        }
        bgmPlayer.outputAudioMixerGroup = audioMixer.FindMatchingGroups(EMixerGroup.BGM.ToString())[0];
        playerUISound -= uiSoundPlayer.PlayUISound;
        playerUISound += uiSoundPlayer.PlayUISound;
    }

    public void OnLoadScene(Scene arg, LoadSceneMode mode)
    {
        if (!bgmDict.ContainsKey(arg.name)) return;
        Debug.Log("Play BGM");
        PlayBGM(bgmDict[arg.name]);
    }
    public void PlayUISound(EUiSoundType uiSoundType)
    {
        playerUISound(uiSoundType);
    }

    public void PlayEffect(AudioClip effect)
    {
        GameObject audioObj = new GameObject();
        AudioSource audioSource = audioObj.AddComponent<AudioSource>();
        audioSource.outputAudioMixerGroup = audioMixer.FindMatchingGroups(EMixerGroup.EFFECT.ToString())[0];
        audioSource.clip = effect;
        audioSource.Play();
        Destroy(audioObj, effect.length);
    }
    public void PlayBGM(AudioClip bgm)
    {
        bgmPlayer.clip = bgm;
        bgmPlayer.loop = true;
        bgmPlayer.volume = 0.1f;
        bgmPlayer.Play();
    }

    
}
