using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerData : MonoBehaviour
{
    [Header("Shooting")]
    public Transform shootStartPos;
    public Transform shootEndPos;
    public float maxLength;
    public Vector3 mousePos;

    [Header("Status")]
    [SerializeField] public float hp;
}
