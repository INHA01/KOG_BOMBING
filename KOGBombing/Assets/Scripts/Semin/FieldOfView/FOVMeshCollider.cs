using Orpul1;
using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using static UnityEngine.Rendering.DebugUI;

public class FOVMeshCollider : MonoBehaviour
{
	public BoxCollider boxCollider;
	
	private void Awake()
	{
		boxCollider = GetComponent<BoxCollider>();
	}
	private bool IsSameTeam(Collider other)
	{
        IGetTeamTypeable team = other.GetComponent<PlayerData>();
        if (team == null)
            return false;

        ETeam playerTeam = team.GetTeamType();

        if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()] == playerTeam)
            return false;

		return true;
    }
	private void SetSpriteColor(PlayerData playerData, int value)
	{
        Color color = playerData.minimapIcon.GetComponent<SpriteRenderer>().color;
        color.a = 1;
        playerData.minimapIcon.GetComponent<SpriteRenderer>().color = color;
    }
	private void OnTriggerEnter(Collider other)
	{
		if (!IsSameTeam(other)) return;

        PlayerData playerData = other.GetComponent<PlayerData>();
        if (playerData.pv.IsMine)
            return;

		SetSpriteColor(playerData, 1);
    }
    private void OnTriggerExit(Collider other)
	{
        if (!IsSameTeam(other)) return;

        PlayerData playerData = other.GetComponent<PlayerData>();
		if (playerData.pv.IsMine) 
			return;

        SetSpriteColor(playerData, 0);
    }
}
