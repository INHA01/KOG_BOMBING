using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

public class PlayerBehavior : MonoBehaviour
{
    [SerializeField]
    protected PlayerBlackBoard blackBoard;
    [SerializeField]
    protected PlayerAnimation animator;
    [SerializeField]
    protected PlayerData playerData;
    protected virtual void Awake()
    {
        blackBoard = GetComponent<PlayerBlackBoard>();
        playerData = GetComponent<PlayerData>();
    }

    protected void ChangeWeapon(int type)
    {
        for (int i = 0; i < playerData.weapons.Count; i++)
        {
            if (playerData.weapons[i].type == (WeaponType)type)
                playerData.weapons[i].obj.SetActive(true);
            else playerData.weapons[i].obj.SetActive(false);
        }
    }
}
