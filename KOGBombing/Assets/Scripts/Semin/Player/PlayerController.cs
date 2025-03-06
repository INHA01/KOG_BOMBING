using UnityEngine;
using System.Collections.Generic;
using Photon.Pun;
using System.Collections;
using Orpul1;
public class PlayerController : MonoBehaviour,ITeamUIInitAble, IDestroyAble,IResetAble, ISetGameStateAble, IGetTeamTypeable
{
	[SerializeField]
    public PlayerBlackBoard blackBoard;

	public Dictionary<EKey, bool> Inputs { get { return blackBoard.inputs; } }

	public Vector3 SpawnPoint { set { blackBoard.spawnPoint = value; } }

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
    BombNotify bombNotify;

    bool isInitComplete = false;
    void Awake()
    {
        isInitComplete = false;
        InitPlayerData();
        ETeam team = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];

        if (playerData.pv.IsMine)
        {
            playerData.minimapIcon.GetComponent<SpriteRenderer>().color = Color.green;
            playerData.pv.RPC("SendBlackBoard", RpcTarget.AllBuffered);
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

		playerData.animator.Init(playerData.playerObj, playerTeam, playerData.shootStartPos, blackBoard.characterType);
        isInitComplete = true;
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
        playerMaterialController.Init(playerData.changeMaterialMeshs, playerData.hitMaterial);
        playerData.rigidBody = GetComponent<Rigidbody>();
        blackBoard.rigidBody = GetComponent<Rigidbody>();
        blackBoard.playerStatus = Instantiate(blackBoard.SOplayerStatus);
        blackBoard.canRespawn = false;
        if (playerData.pv.IsMine)
        {
            blackBoard.nickname = PhotonNetwork.LocalPlayer.NickName;
            blackBoard.eTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()];
        }
        else
        {
            blackBoard.nickname = playerData.pv.Owner.NickName;
            blackBoard.eTeam = (ETeam)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()];
        }
    }
	[PunRPC]
	private void SendBlackBoard()
	{
        LocalManagers.PunData.AddPlayerBlackBoard(playerData.pv.Owner.NickName, blackBoard);
    }
    IEnumerator WaitSetTeamUI(TeamUIController controller)
	{
        while (LocalManagers.PunData.blackBoardCnt != PhotonNetwork.CurrentRoom.PlayerCount || !isInitComplete) yield return null;
		Debug.Log($"isDataAllGet {LocalManagers.PunData.blackBoardCnt}");
        controller.SetTeamUI(playerShooting);

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
    void ConfirmBombInteract()
    {
        Collider[] colliders = Physics.OverlapSphere(blackBoard.transform.position, 1f);
        bool tagBomb = false;
        for (int i = 0; i < colliders.Length; i++)
        {
            if (
                (blackBoard.eTeam == ETeam.REDTEAM && colliders[i].tag == "BombInteract")
                ||
                (blackBoard.eTeam == ETeam.BLUETEAM && colliders[i].tag == "Bomb")
               )
            {
                if (bombNotify == null)
                    bombNotify = LocalManagers.UI.GetPopupUI<BombNotify>("BombNotifyCanvas");
                if (blackBoard.inputs[EKey.NUM_2])
                {
                    bombNotify.ActiveCanInteractBomb(true);
                    tagBomb = true;
                }
            }
        }
        if (!tagBomb && bombNotify != null)
            bombNotify.ActiveCanInteractBomb(false);
    }
    void ConfirmSoundEffect()
    {
        Collider[] colliders = Physics.OverlapSphere(blackBoard.transform.position, 32f);
        for (int i = 0; i < colliders.Length; i++)
        {
            float distance = Vector3.Distance(blackBoard.transform.position, colliders[i].transform.position);
            if (distance < 16f) continue;
            PlayerData playerD = colliders[i].GetComponent<PlayerData>();
            if (colliders[i].tag == "Player" && !playerD.pv.IsMine)
            {
                PlayerBlackBoard player = colliders[i].GetComponent<PlayerBlackBoard>();
                ShowCursor showCursor = LocalManagers.UI.GetPopupUI<ShowCursor>("PlayCanvas");
                if (player.eTeam != blackBoard.eTeam && !player.showSoundEffect)
                {
                    player.showSoundEffect = true;
                    showCursor.ShowSoundCursor(player.transform.position, 2, player);
                }

            }
        }
    }
    //void OnDrawGizmos()
    //{
    //    Gizmos.color = Color.red;
    //    Gizmos.DrawWireSphere(blackBoard.transform.position, 32f);
    //}

    public void DoDestory()
    {
        if (!playerData.pv.IsMine) return;
        playerData.pv.RPC("DestroyPlayer", RpcTarget.AllBuffered);
    }

    [PunRPC]
    private void DestroyPlayer()
    {
        Debug.Log($"DestroyPlayer {blackBoard.nickname}");
        Destroy(gameObject);
    }
    public void DoReset()
    {
        Debug.Log($"Set Respawn");
        blackBoard.canRespawn = true;
    }
    [PunRPC]
    private void RespawnPlayer()
    {
        Debug.Log($"RespawnPlayer {blackBoard.nickname}");
    }

	private void OnTriggerEnter(Collider other)
	{
		if (other.CompareTag("Player"))
			Physics.IgnoreCollision(other.GetComponent<Collider>(), GetComponent<Collider>());
	}

    public void SetGameState(EGameState state)
    {
        if (EGameState.ROUNDENDWAIT == state)
            blackBoard.playerStatus.canSettingBomb = false;
        
        if (EGameState.ROUNDWAIT == state)
            blackBoard.playerStatus.canSettingBomb = true;
    }

    public ETeam GetTeamType()
    {
        return blackBoard.eTeam;
    }
}
