using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Semin;

public class PlayerBlackBoard : MonoBehaviour
{
    public string nickname;
    public float hp;
    public float maxHp;
    public float moveSpeed;
    public float defence;
    public float maxDefence;
    public List<GameObject> playerModels;
    public Collider playerCollider;
    public Rigidbody rigidBody;
    public bool isLive;
    public Dictionary<EKey, bool> inputs = new Dictionary<EKey, bool>(new EKeyComparer());
    public Vector2 speedValue;
    public Vector2 mousePos;
    public Vector3 spawnPoint;
    public GameObject gmlookTarget;
}
