using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Semin;
using Orpul1;

public class PlayerBlackBoard : MonoBehaviour
{
    public Collider playerCollider;
    public Collider playerInteractCollider;
    public Rigidbody rigidBody;
    public Quaternion initRotation;
    public Dictionary<EKey, bool> inputs = new Dictionary<EKey, bool>(new EKeyComparer());
    public Camera viewCamera;
    public UIPopup _uiScene;
    public HpBar hpBar;
    public BombUI bombUI;
    public GameObject fieldOfView;
    public GameObject gmlookTarget;
    public GameObject interactUIObj;
    public Vector2 speedValue;
    public SpeedDebuff speedDebuff = new SpeedDebuff();
	//public float speedDebuffPercent = 1;
	public Vector2 mousePos;
    public Vector3 spawnPoint;
    public ETeam eTeam;
    public ISetTeamCountAble setTeam;
    public IBombStateAble setBombState;
    public string nickname;
    public CharacterType characterType;
    public PlayerStatus SOplayerStatus;
    public bool canRespawn = false;
    public bool isSetScore = false;
    [HideInInspector] public PlayerStatus playerStatus;
    public void Initialize()
    {
        speedDebuff.Initialize();
        playerStatus.hp = playerStatus.maxHp;
        playerStatus.defence = playerStatus.maxDefence;
        playerStatus.isLive = true;
        playerStatus.groggyValue = 150;
        playerStatus.groggyable = true;
        playerStatus.isGroggy = false;
        canRespawn = false;
        isSetScore = false;
        hpBar.SetStopHpUI(false);
        hpBar.InitializeValues();
        hpBar.HideGroggy();
        hpBar.ShowHpUI();
    }
}

