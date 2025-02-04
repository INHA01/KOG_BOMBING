using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerBlackBoard : MonoBehaviour
{
    public string nickname;
    public float hp;
    public float maxHp;
    public float moveSpeed;
    public Rigidbody rigidBody;
    public Dictionary<EKey, bool> inputs = new Dictionary<EKey, bool>(new EKeyComparer());
    public Vector2 speedValue;
    public Vector2 mousePos;
    public Vector3 spawnPoint;
}
