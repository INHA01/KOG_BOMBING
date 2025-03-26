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

}
