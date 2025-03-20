using UnityEngine;
using System.Collections.Generic;
using Photon.Pun;
using System.Collections;
using Orpul1;
using BAEK;
public class PlayerController : MonoBehaviour,ITeamUIInitAble, IDestroyAble,IResetAble, ISetGameStateAble, IGetTeamTypeable,ISetAble<bool>
{
	[SerializeField]
    public PlayerBlackBoard blackBoard;
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
    void Awake()
    {
        isInitComplete = false;
        InitPlayerData();
        StartCoroutine("CoMinimapInit");
        if (!playerData.pv.IsMine) return;
        playerData.pv.RPC("SendBlackBoard", RpcTarget.All);
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
        blackBoard.playerTeam = (ETeam)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()];
    }
	[PunRPC]
	private void SendBlackBoard()
	{
        Managers.PunData.AddPlayerBlackBoard(playerData.pv.Owner.NickName, blackBoard);
    }
    IEnumerator WaitSetTeamUI(TeamUIController controller)
	{
        while (Managers.PunData.blackBoardCnt != PhotonNetwork.CurrentRoom.PlayerCount || !isInitComplete) yield return null;
		Debug.Log($"isDataAllGet {Managers.PunData.blackBoardCnt}");
        controller.SetTeamUI(playerShooting);
        blackBoard.updateTeamState = controller;

    }
	public void Init(Camera camera, Vector3 spawnPosi,GameObject roundEventObj)
	{
        blackBoard.viewCamera = camera;
		blackBoard.spawnPoint = spawnPosi;
        blackBoard.setTeam = roundEventObj.GetComponent<ISetTeamCountAble>();
        blackBoard.setBombState = roundEventObj.GetComponent<IBombStateAble>();
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
        Debug.Log($"DestroyPlayer {blackBoard.nickname}");
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
                PlayerBlackBoard player = colliders[i].GetComponent<PlayerBlackBoard>();
                ShowCursor showCursor = Managers.UI.GetPopupUI<ShowCursor>(UIKEY.Play);
                if (player.playerTeam != blackBoard.playerTeam && !player.showSoundEffect)
                {
                    player.showSoundEffect = true;
                    showCursor.ShowSoundCursor(player.transform.position, 2, player);
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
    /*void ConfirmBombInteract()
    {
        bool tagBomb = false;
        Collider[] colliders = Physics.OverlapSphere(blackBoard.transform.position, 1f);
        for(int i = 0; i < colliders.Length; i++)
        {
            if (
                (blackBoard.playerTeam == ETeam.REDTEAM && colliders[i].tag == "BombInteract")
                ||
                (blackBoard.playerTeam == ETeam.BLUETEAM && colliders[i].tag == "Bomb")
               )
            {
                if (blackBoard.inputs[EKey.NUM_2])
                {
                    bombNotify.ActiveCanInteract(true, InteractUI.InteractBomb);
                    tagBomb = true;
                    playerData.isInteract = true;
                }
            }
        }
        
        if (!tagBomb && bombNotify != null)
        {
            bombNotify.ActiveCanInteract(false, InteractUI.InteractBomb);
            playerData.isInteract = false;
        }
    }*/
    public void SetGameState(EGameState state)
    {
        if (EGameState.ROUNDENDWAIT == state)
            blackBoard.playerStatus.canSettingBomb = false;
        
        if (EGameState.ROUNDWAIT == state)
            blackBoard.playerStatus.canSettingBomb = true;
    }

    public ETeam GetTeamType()
    {
        return blackBoard.playerTeam;
    }
    private bool IsAttackTeamInteractBomb(string tag)
    {
        if (blackBoard.playerTeam != ETeam.REDTEAM) return false;
        if (tag != "BombInteract") return false;
        return true;
    }
    private bool IsDefenceTeamInteractBomb(string tag)
    {
        if (blackBoard.playerTeam != ETeam.BLUETEAM) return false;
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
        Debug.Log($"BombInteract False!");
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
        Debug.Log($"canBombInteract {value}");
        if(!value) SetBombInteract(false);
    }
}
