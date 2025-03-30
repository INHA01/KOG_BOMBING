using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.UI;
using static UnityEngine.Rendering.DebugUI;

public class OptionSetting : MonoBehaviour
{
    [SerializeField] AudioMixer audioMixer;
    [SerializeField] Slider mouseSensitive;
    private void Reset()
    {
        audioMixer = Resources.Load<AudioMixer>("SoundFile/AudioMixer");
    }
    private void Start()
    {
        Managers.CamData.SetSensitive(mouseSensitive.value);
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
