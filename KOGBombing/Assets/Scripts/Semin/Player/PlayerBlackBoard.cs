using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Semin;
using Orpul1;

public class PlayerBlackBoard : MonoBehaviour
{
    public Collider playerCollider;
    public Rigidbody rigidBody;
    public Dictionary<EKey, bool> inputs = new Dictionary<EKey, bool>(new EKeyComparer());
    public Camera viewCamera;
    public UIPopup _uiScene;
    public HpBar hpBar;
    public GameObject fieldOfView;
    public GameObject gmlookTarget;
    public Vector2 speedValue;
    public Vector2 mousePos;
    public Vector3 spawnPoint;
    public ETeam eTeam;
    public string nickname;
    public float hp;
    public float maxHp;
    public float moveSpeed;
    public float defence;
    public float maxDefence;
    public float reviveInterval;
    public bool isLive;
	public bool isGroggy;
	public bool groggyable;
}

