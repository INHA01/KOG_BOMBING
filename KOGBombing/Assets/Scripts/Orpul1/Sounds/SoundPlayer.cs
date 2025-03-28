using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

[RequireComponent(typeof(AudioSource))]
public class SoundPlayer : MonoBehaviour
{
    [SerializeField] AudioSource audioSource;
    [SerializeField] AudioMixer audioMixer;
    [SerializeField] AudioClip audioClip;
    bool isPlaying = false;
    private void Reset()
    {
        audioSource = GetComponent<AudioSource>();
        audioMixer = Resources.Load<AudioMixer>("SoundFile/AudioMixer");
    }
    public void SetSound(AudioClip audioClip, EMixerGroup mixerGroup = EMixerGroup.EFFECT, Transform parent = null, float spatialBlend = 0, float minDistance = 0, float maxDistance = 1)
    {
        if (isPlaying) 
            return;
        this.audioClip = audioClip;
        isPlaying = true;
        transform.parent = parent;
        transform.localPosition = Vector3.zero;
        audioSource.spatialBlend = spatialBlend;
        audioSource.rolloffMode = AudioRolloffMode.Linear;
        audioSource.minDistance = minDistance;
        audioSource.maxDistance = maxDistance;
        audioSource.outputAudioMixerGroup = audioMixer.FindMatchingGroups(mixerGroup.ToString())[0];
        audioSource.clip = audioClip;
    }
    public void PlaySound()
    {
        if (isPlaying)
            return;

        isPlaying = true;
        audioSource.Play();
        CoWaitEndAudio(audioClip.length);
    }
    IEnumerator CoWaitEndAudio(float audioLength)
    {
        float time = Time.time + audioLength;

        while (Time.time < time) 
            yield return null;

        isPlaying = false;
    }
}
