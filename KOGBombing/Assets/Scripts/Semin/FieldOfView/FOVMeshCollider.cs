using Orpul1;
using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class FOVMeshCollider : MonoBehaviour
{
	public BoxCollider boxCollider;
	
	private void Awake()
	{
		boxCollider = GetComponent<BoxCollider>();
	}

	private void Update()
	{
		if (boxCollider != null)
		{
			//Debug.Log(collider.size);
		}
	}
	private void OnTriggerEnter(Collider other)
	{
		PlayerController player = other.GetComponent<PlayerController>();
		if (player == null) return;

		ETeam playerTeam = player.blackBoard.eTeam;
		if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties[(int)EPropertyType.TEAM] != playerTeam)
		{
			PlayerData playerData = other.GetComponent<PlayerData>();
			if (!playerData.pv.IsMine)
			{
				Color color = playerData.minimapIcon.GetComponent<SpriteRenderer>().color;
				color.a = 1;
				playerData.minimapIcon.GetComponent<SpriteRenderer>().color = color;
			}
			//player.blackBoard.hpBar.ShowOtherTeamUI();
			//if (player.blackBoard.playerStatus.isGroggy)
			//	player.blackBoard.hpBar.ShowGroggy();
		}
	}

	private void OnTriggerStay(Collider other)
	{
		PlayerController player = other.GetComponent<PlayerController>();
		if (player == null) return;
		if (!player.blackBoard.hpBar.IsShowUI())
		{
			PlayerData playerData = other.GetComponent<PlayerData>();
			if (!playerData.pv.IsMine)
			{
				Color color = playerData.minimapIcon.GetComponent<SpriteRenderer>().color;
				color.a = 1;
				playerData.minimapIcon.GetComponent<SpriteRenderer>().color = color;
			}
			//player.blackBoard.hpBar.ShowOtherTeamUI();
			//if (player.blackBoard.playerStatus.isGroggy)
			//	player.blackBoard.hpBar.ShowGroggy();
		}
	}

	private void OnTriggerExit(Collider other)
	{
		PlayerController player = other.GetComponent<PlayerController>();
		if (player == null) return;

		ETeam playerTeam = player.blackBoard.eTeam;
		if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties[(int)EPropertyType.TEAM] != playerTeam)
		{
			PlayerData playerData = other.GetComponent<PlayerData>();
			if (!playerData.pv.IsMine)
			{
				Color color = playerData.minimapIcon.GetComponent<SpriteRenderer>().color;
				color.a = 0;
				playerData.minimapIcon.GetComponent<SpriteRenderer>().color = color;
			}
			//player.blackBoard.hpBar.HideOtherTeamUI();
		}
	}
}
