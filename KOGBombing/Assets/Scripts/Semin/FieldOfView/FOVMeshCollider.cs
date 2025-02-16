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
		if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"] != playerTeam)
			player.blackBoard.hpBar.ShowOtherTeamUI();
	}

	private void OnTriggerStay(Collider other)
	{
		PlayerController player = other.GetComponent<PlayerController>();
		if (player == null) return;
		if (!player.blackBoard.hpBar.IsShowUI())
			player.blackBoard.hpBar.ShowOtherTeamUI();

	}

	private void OnTriggerExit(Collider other)
	{
		PlayerController player = other.GetComponent<PlayerController>();
		if (player == null) return;

		ETeam playerTeam = player.blackBoard.eTeam;
		if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties["Team"] != playerTeam)
			player.blackBoard.hpBar.HideOtherTeamUI();
	}
}
