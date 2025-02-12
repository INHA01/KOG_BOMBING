using UnityEngine;
using System.Collections.Generic;
using Photon.Pun;
using System.Collections;
using Orpul1;
public class PlayerController : MonoBehaviour
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
        blackBoard.isLive = true;
        playerData = GetComponent<PlayerData>();
        playerShooting = GetComponent<PlayerShooting>();
		playerMaterialController = GetComponent<PlayerMaterialController>();
		playerMaterialController.Init(playerData.changeMaterialMeshs, playerData.hitMaterial);
		blackBoard.hp = blackBoard.maxHp;
		blackBoard.defence = blackBoard.maxDefence;

        playerData.rigidBody = GetComponent<Rigidbody>();
        blackBoard.rigidBody = GetComponent<Rigidbody>();
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


	private void Start()
	{
        ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties["Team"];

		playerData.animator.Init(playerData.playerObj, playerTeam, playerData.shootStartPos);
		playerMaterialController.SaveCurrentMaterial();

		if(playerData.pv.IsMine)
		{
			playerData.pv.RPC("SendBlackBoard", RpcTarget.AllBuffered);
			StartCoroutine(WaitSetTeamUI());
		}
	}
	[PunRPC]
	private void SendBlackBoard()
	{
        Managers.PunData.AddPlayerBlackBoard(playerData.pv.Owner.NickName, blackBoard);
    }
    IEnumerator WaitSetTeamUI()
	{
        while (!Managers.PunData.IsDataAllGet) yield return null;
		teamUIController.SetTeamUI(playerShooting);

    }
	public void Init(Camera camera, Vector3 spawnPosi)
	{
        blackBoard.viewCamera = camera;
		blackBoard.spawnPoint = spawnPosi;
	}

    private void Update()
    {
        if (!playerData.pv.IsMine) return;

        if (playerData.animator != null)
            playerData.animator.UpdateAnimation(blackBoard.speedValue, transform);
    }
}
