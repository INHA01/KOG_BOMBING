using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Semin;
using Orpul1;
using System.Text;

// TODO : 행동트리의 노드 흐름에 관여되는 것만 저장할 것
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
    public GameObject fieldOfView;
    public GameObject observaTarget;
    public StringBuilder observaTargetNickname = new StringBuilder();
    public GameObject interactUIObj;
    public Vector2 speedValue;
    public SpeedDebuff speedDebuff = new SpeedDebuff();
	public Vector2 mousePos;
    public Vector3 spawnPoint;
    public ETeam playerTeam;
    public ISetTeamCountAble setTeam;
    public IBombStateAble setBombState;
    public IChangeHitCursorAble cursorUI;
    public IUpdateStateAble updateTeamState;
    public string nickname;
    public CharacterType characterType;
    public PlayerStatus SOplayerStatus;
    public bool canRespawn = false;
    public bool isSetScore = false;
    public bool showSoundEffect = false;
	[HideInInspector] public BombInteraction bombInteraction;
	[HideInInspector] public PlayerStatus playerStatus;
    public EGameState currentGameState;
    public int playerIndex;
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
        observaTargetNickname.Clear();

        if (bombInteraction.GetBomb() != null)
        {
			bombInteraction.SetBombInteraction(false);
            bombInteraction.Initialize();
            bombInteraction.SetBomb(null);
        }
    }
}


