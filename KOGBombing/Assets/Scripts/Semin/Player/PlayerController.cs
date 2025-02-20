using UnityEngine;
using System.Collections.Generic;
using Photon.Pun;
using System.Collections;
using Orpul1;
public class PlayerController : MonoBehaviour,IDestroyAble,IRespawnAble
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
	TeamUIController teamUIController = new TeamUIController();
    void Awake()
	{
        InitPlayerData();

        if (playerData.pv.IsMine)
            playerData.pv.RPC("SendBlackBoard", RpcTarget.AllBuffered);
    }

	private void Start()
	{
        ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties["Team"];

		playerData.animator.Init(playerData.playerObj, playerTeam, playerData.shootStartPos, blackBoard.characterType);

		if(playerData.pv.IsMine)
		{
			StartCoroutine(WaitSetTeamUI());
		}
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
    IEnumerator WaitSetTeamUI()
	{
		while (Managers.PunData.blackBoardCnt != PhotonNetwork.CurrentRoom.PlayerCount) yield return null;
		Debug.Log($"isDataAllGet {Managers.PunData.blackBoardCnt}");
		teamUIController.SetTeamUI(playerShooting);

    }
	public void Init(Camera camera, Vector3 spawnPosi,ISetTeamCountable team)
	{
        blackBoard.viewCamera = camera;
		blackBoard.spawnPoint = spawnPosi;
        blackBoard.setTeam = team;
	}

    private void Update()
    {
        if (!playerData.pv.IsMine) return;

        if (playerData.animator != null)
            playerData.animator.UpdateAnimation(blackBoard.speedValue * blackBoard.speedDebuffPercent, transform);
    }

    public void DoDestory()
    {
        if (!playerData.pv.IsMine) return;
        //>> TODO: 플레이어 제거 작업 수행
        playerData.pv.RPC("DestroyPlayer", RpcTarget.AllBuffered);
    }

    [PunRPC]
    private void DestroyPlayer()
    {
        Debug.Log($"DestroyPlayer {blackBoard.nickname}");
        blackBoard = null;
        playerData = null;
        Destroy(gameObject);
    }
    public void DoRespawn()
    {
        //TODO: 행동트리 리스폰 관련 작업 추가할 것
        Debug.Log($"Set Respawn");
        blackBoard.canRespawn = true;
    }
}
