using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Reflection;
using Photon.Pun;
using UnityEngine;

public class DashSkill : MonoBehaviour, ISkill
{
	Coroutine skillCooldown;
	Coroutine dash;
	PlayerData playerData;
	bool bisUsableSkill;
	float skillDeltaTime;
	PlayerBlackBoard blackboard;
	float buffTime;
	Vector3 position;
	Vector3 direction;
	bool isRunning = false;
	[SerializeField] ParticleSystem particle;

	public void InitializationSkill(PlayerData playerData)
	{
		this.playerData = playerData;
		skillCooldown = StartCoroutine(Cooldown(3f));
		particle.gameObject.SetActive(false);
	}

	public bool isUsableSkill()
	{
		return bisUsableSkill;
	}

	public void SetSkill(SkillInfo info)
	{
		if (info is DashSkillInfo dash)
		{
			blackboard = dash.Blackboard;
			position = dash.Position;
			direction = dash.Direction;
			buffTime = dash.BuffTime;
		}
	}

	public void Use()
	{
		skillDeltaTime = 0;
		bisUsableSkill = false;
        playerData.pv.RPC("StartDash", RpcTarget.AllBuffered);
    }

	public bool IsRunning()
	{
		return isRunning;
	}

	[PunRPC]
	void StartDash()
    {
        dash = StartCoroutine(Dash());
    }


	IEnumerator Dash()
	{
		isRunning = true;
		float time = 0;
		Vector3 movement;

		// >> Managers.PunData를 통해 플레이어의 blackBoard를 가져오는 방식으로 변경
		PlayerBlackBoard blackBoard = Managers.PunData.GetPlayerBlackBoard(playerData.pv.Owner.NickName);
		while (time < 0.5f)
		{
			time += Time.deltaTime;
			movement = playerData.animator.transform.forward;
			movement.y = blackBoard.rigidBody.velocity.y;
            blackBoard.rigidBody.velocity = movement;
			yield return null;
        }
        particle.gameObject.SetActive(true);
        particle.Play();
		while (time < 1.5f)
		{
			time += Time.deltaTime;
			movement = playerData.animator.transform.forward * blackBoard.playerStatus.moveSpeed * blackBoard.speedDebuffPercent * 1.6f;
			movement.y = blackBoard.rigidBody.velocity.y;
            blackBoard.rigidBody.velocity = movement;
			if (Vector3.Distance(playerData.animator.transform.position, position) < 1f)
			{
                blackBoard.rigidBody.velocity = Vector3.zero;
				time = 1.5f;
			}	
			yield return null;
		}
		particle.Stop();
        particle.gameObject.SetActive(false);
        isRunning = false;
		time = 0;
        blackBoard.speedDebuffPercent *= 1.5f;
		while (time < buffTime)
		{ 
			time += Time.deltaTime;
			yield return null;
		}
        blackBoard.speedDebuffPercent /= 1.5f;
		dash = null;
		// << :
	}

	IEnumerator Cooldown(float time)
	{
		skillDeltaTime = 0f;
		while (true)
		{
			if (skillDeltaTime < time)
			{
				skillDeltaTime += Time.deltaTime;
				if (skillDeltaTime > time)
					bisUsableSkill = true;
			}
			yield return null;
		}
	}
}
