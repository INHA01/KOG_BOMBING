using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterSoundPlayer : MonoBehaviour
{
    public enum ECharacterType
    {
        NED,
        UNI
    }
    [SerializeField] ECharacterType characterType;
    [SerializeField] AudioClip[] characterSounds;
    [SerializeField] bool isActive = false;
    private void Awake()
    {
        gameObject.SetActive(isActive);
    }
    private void OnEnable()
    {
        Managers.Sound.PlayEffect(characterSounds[(int)characterType], EMixerGroup.CHARACTER);
    }
}
