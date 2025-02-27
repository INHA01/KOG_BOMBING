using UnityEngine;
using System.Collections.Generic;
using Photon.Pun;
using System.Collections;
using Orpul1;
public class PlayerController : MonoBehaviour,ITeamUIInitAble, IDestroyAble,IRespawnAble
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
    
    
    bool isInitComplete = false;
    void Awake()
    {
        isInitComplete = false;
        InitPlayerData();
        ETeam team = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"];

        if (playerData.pv.IsMine)
        {
            playerData.minimapIcon.GetComponent<SpriteRenderer>().color = Color.green;
            playerData.pv.RPC("SendBlackBoard", RpcTarget.AllBuffered);
        }
        else
        {
            if ((ETeam)playerData.pv.Owner.CustomProperties["Team"] == team)
            {
                playerData.minimapIcon.GetComponent<SpriteRenderer>().color = Color.blue;
            }
            else
            {
                playerData.minimapIcon.GetComponent<SpriteRenderer>().color = Color.red;
            }
        }
    }

	private void Start()
	{
        ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties["Team"];

		playerData.animator.Init(playerData.playerObj, playerTeam, playerData.shootStartPos, blackBoard.characterType);
        isInitComplete = true;
        /*if(playerData.pv.IsMine)
		{
			StartCoroutine(WaitSetTeamUI());
		}*/
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
            blackBoard.eTeam = (ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"];
        }
        else
        {
            blackBoard.nickname = playerData.pv.Owner.NickName;
            blackBoard.eTeam = (ETeam)playerData.pv.Owner.CustomProperties["Team"];
        }
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
			else playerData.animator.UpdateAnimation(blackBoard.speedValue * blackBoard.speedDebuffPercent, transform);
        }
    }

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
    public void DoRespawn()
    {
        //TODO: 행동트리 리스폰 관련 작업 추가할 것
        Debug.Log($"Set Respawn");
        blackBoard.canRespawn = true;

        //playerData.pv.RPC("RespawnPlayer", RpcTarget.AllBuffered);
        //blackBoard.canRespawn = true;
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
}
