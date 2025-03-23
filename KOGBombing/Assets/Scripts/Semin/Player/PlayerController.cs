using UnityEngine;
using System.Collections.Generic;
using Photon.Pun;
using System.Collections;
using Orpul1;
using BAEK;
using PhotonHashTable = ExitGames.Client.Photon.Hashtable;
using Photon.Realtime;
public class PlayerController : MonoBehaviour, ITeamUIInitAble, IDestroyAble, IResetAble, ISetGameStateAble,ISetAble<bool>, ISetAble<Vector3>
{

    [SerializeField] public PlayerBlackBoard blackBoard;
    [SerializeField] PlayerStateData playerStateData = new PlayerStateData();
	public Dictionary<EKey, bool> Inputs { get { return blackBoard.inputs; } }
	public Vector3 SpawnPoint { set { blackBoard.spawnPoint = value; } }
    bool canBombInteract = false;

	public enum EDirection
	{
		Up,
		Down,
		Left,
		Right,
	}
    PlayerShooting playerShooting;
    PlayerData playerData;
	PlayerMaterialController playerMaterialController;
    Interacting bombNotify;

    bool isInitComplete = false;
    int readyPlayerCount = 0;
    void Awake()
    {
        readyPlayerCount = 0;
        isInitComplete = false;
        InitPlayerData();
        StartCoroutine("CoMinimapInit");
        if (!playerData.pv.IsMine) return;
        playerData.pv.RPC("SetStateData", RpcTarget.All);
        PhotonNetwork.LocalPlayer.SetCustomProperties(new PhotonHashTable { { EPropertyType.CHARACTER.ToString(), blackBoard.characterType } });
    }
    IEnumerator CoMinimapInit()
    {
        yield return new WaitForSeconds(5f);
        ETeam team = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];

        if (playerData.pv.IsMine)
        {
            playerData.minimapIcon.GetComponent<SpriteRenderer>().color = Color.green;
        }
        else
        {
            if ((ETeam)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()] == team)
            {
                playerData.minimapIcon.GetComponent<SpriteRenderer>().color = Color.blue;
            }
            else
            {
                Color color = playerData.minimapIcon.GetComponent<SpriteRenderer>().color;
                color.a = 0;
                playerData.minimapIcon.GetComponent<SpriteRenderer>().color = color;
            }
        }
    }

	private void Start()
	{
        ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()];
        if (bombNotify == null)
            bombNotify = Managers.UI.GetPopupUI<Interacting>(UIKEY.Interacting);
        playerData.animator.Init(playerData.playerObj, playerTeam, playerData.shootPos[(int)ShootPos.Start], blackBoard.characterType);
        isInitComplete = true;
        blackBoard.cursorUI = Managers.UI.GetPopupUI<CrossHariUpdater>(UIKEY.CrossHair);
    }

    public void SetTeamUI(TeamUIController controller)
    {
        StartCoroutine(WaitSetTeamUI(controller));
    }
    private void InitPlayerData()
	{
        playerData = GetComponent<PlayerData>();
        playerShooting = GetComponent<PlayerShooting>();
        playerMaterialController = GetComponent<PlayerMaterialController>();
        playerData.rigidBody = GetComponent<Rigidbody>();
        blackBoard.rigidBody = GetComponent<Rigidbody>();
        playerMaterialController.Init(playerData.changeMaterialMeshs, playerData.hitMaterial, playerData);
        blackBoard.playerStatus = Instantiate(blackBoard.SOplayerStatus);
        blackBoard.canRespawn = false;
        blackBoard.nickname = playerData.pv.Owner.NickName;
        blackBoard.playerIndex = (int)playerData.pv.Owner.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
        playerData.playerTeam = (ETeam)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()];

        playerStateData.playerStatus = blackBoard.playerStatus;
        playerStateData.playerTeam = playerData.playerTeam;
        playerStateData.playerIndex = (int)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAMINDEX.ToString()];

    }

	[PunRPC]
	private void SetStateData()
	{
        ETeam mTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        readyPlayerCount++;
        if (mTeam != playerStateData.playerTeam) return;
        Managers.PunData.AddPlayerBlackBoard(playerStateData);
    }
    IEnumerator WaitSetTeamUI(TeamUIController controller)
	{
        blackBoard.updateTeamState = controller;
        int teamCount = (int)PhotonNetwork.CurrentRoom.CustomProperties[playerData.playerTeam.ToString()];
        Debug.Log("TeamUI Wait");
        while (readyPlayerCount != teamCount || !isInitComplete) yield return null;
        Debug.Log("TeamUI Start");
        controller.SetTeamUI(playerShooting);

    }
	public void Initialize(Camera camera, Vector3 spawnPosi,GameObject roundEventObj)
	{
        blackBoard.viewCamera = camera;
		blackBoard.spawnPoint = spawnPosi;
        blackBoard.setTeam = roundEventObj.GetComponent<ISetTeamCountAble>();
        blackBoard.setBombState = roundEventObj.GetComponent<IBombStateAble>();
        playerStateData.spawnPosi = blackBoard.spawnPoint;

    }

    private void Update()
    {
        if (!playerData.pv.IsMine) return;
        
        if (playerData.animator != null)
        {
            if (playerData.isInteract)
				playerData.animator.UpdateAnimation(new Vector2(0, 0), transform);
			else playerData.animator.UpdateAnimation(blackBoard.speedValue * blackBoard.speedDebuff.GetValue(), transform);
        }
        ConfirmBombInteract();
        ConfirmSoundEffect();
    }
    
    
    public void DoDestory()
    {
        if (!playerData.pv.IsMine) return;
        playerData.pv.RPC("DestroyPlayer", RpcTarget.All);
    }

    [PunRPC]
    private void DestroyPlayer()
    {
        playerShooting.DoDestory();
        playerData.supportWeapon.DoDestory();
        playerData.bomb.DoDestory();
        if(playerData.skill is ThrowableSkill ts)
            ts.DoDestory();
        Destroy(gameObject);
    }
    public void DoReset()
    {
        Debug.Log($"Set Respawn");
        blackBoard.canRespawn = true;
    }


    void ConfirmSoundEffect()
    {
        Collider[] colliders = Physics.OverlapSphere(blackBoard.transform.position, 32f);
        for (int i = 0; i < colliders.Length; i++)
        {
            float distance = Vector3.Distance(blackBoard.transform.position, colliders[i].transform.position);
            if (distance < 28f) continue;
            PlayerData playerD = colliders[i].GetComponent<PlayerData>();
            if (colliders[i].tag == "Player" && !playerD.pv.IsMine)
            {
                PlayerData playerData = colliders[i].GetComponent<PlayerData>();
                ShowCursor showCursor = Managers.UI.GetPopupUI<ShowCursor>(UIKEY.Play);
                if (playerData.GetTeamType() != this.playerData.playerTeam && !playerData.showSoundEffect)
                {
                    playerData.showSoundEffect = true;
                    showCursor.ShowSoundCursor(playerData.transform.position, 2, playerData);
                }
            }
        }
    }
    void ConfirmBombInteract()
    {
        bool isActive = (canBombInteract && blackBoard.inputs[EKey.NUM_2]);
        if (isActive == false) return;
        SetBombInteract(isActive);
    }
    private void SetBombInteract(bool isActive)
    {
        bombNotify.ActiveCanInteract(isActive, InteractUI.InteractBomb);
        playerData.isInteract = isActive;
    }
    public void SetGameState(EGameState state)
    {
        if (EGameState.ROUNDENDWAIT == state)
            blackBoard.playerStatus.canSettingBomb = false;
        
        if (EGameState.ROUNDWAIT == state)
            blackBoard.playerStatus.canSettingBomb = true;
    }

    private bool IsAttackTeamInteractBomb(string tag)
    {
        if (playerData.playerTeam != ETeam.REDTEAM) return false;
        if (tag != "BombInteract") return false;
        return true;
    }
    private bool IsDefenceTeamInteractBomb(string tag)
    {
        if (playerData.playerTeam != ETeam.BLUETEAM) return false;
        if (tag != "Bomb") return false;
        return true;
    }
    private void OnCollisionEnter(Collision collision)
    {
        string tag = collision.collider.tag;

        if (IsAttackTeamInteractBomb(tag) || IsDefenceTeamInteractBomb(tag))
            canBombInteract = true;
    }
    private void OnCollisionExit(Collision collision)
    {
        if (collision.collider.tag != "BombInteract" & collision.collider.tag != "Bomb") return;
        canBombInteract = false;
        SetBombInteract(false);
        
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
            Physics.IgnoreCollision(other.GetComponent<Collider>(), GetComponent<Collider>());
    }
    public void SetValue(bool value)
    {
        canBombInteract = value;
        if(!value) SetBombInteract(false);
    }

    public void SetValue(Vector3 spawnPosi)
    {
        transform.position = playerStateData.spawnPosi;
    }
}
