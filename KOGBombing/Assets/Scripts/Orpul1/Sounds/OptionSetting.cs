using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Audio;

public class OptionSetting : MonoBehaviour
{
    [SerializeField] AudioMixer audioMixer;
    private void Reset()
    {
        audioMixer = Resources.Load<AudioMixer>("SoundFile/AudioMixer");
    }
    public void SetVolume(float value)
    {

        Debug.Log($"value {value}");
        audioMixer.SetFloat(EMixerGroup.Master.ToString(),value);
    }
    public void SetCameraSensitive(float value)
    {
        Managers.CamData.SetSensitive(value);
    }
}
