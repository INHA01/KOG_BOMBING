using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Reflection;
using Unity.VisualScripting;
using UnityEditor.Experimental.GraphView;
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

	public void InitializationSkill(PlayerData playerData)
	{
		this.playerData = playerData;
		skillCooldown = StartCoroutine(Cooldown(3f));
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
		dash = StartCoroutine(Dash());
	}

	public bool IsRunning()
	{
		return isRunning;
	}

	IEnumerator Dash()
	{
		isRunning = true;
		float time = 0;
		Vector3 movement;
		while (time < 0.5f)
		{
			time += Time.deltaTime;
			movement = playerData.animator.transform.forward;
			movement.y = blackboard.rigidBody.velocity.y;
			blackboard.rigidBody.velocity = movement;
			yield return null;
		}
		while (time < 1.5f)
		{
			time += Time.deltaTime;
			movement = playerData.animator.transform.forward * blackboard.playerStatus.moveSpeed * blackboard.speedDebuffPercent * 1.6f;
			movement.y = blackboard.rigidBody.velocity.y;
			blackboard.rigidBody.velocity = movement;
			if (Vector3.Distance(playerData.animator.transform.position, position) < 1f)
			{
				blackboard.rigidBody.velocity = Vector3.zero;
				time = 1.5f;
			}	
			yield return null;
		}
		isRunning = false;
		time = 0;
		blackboard.speedDebuffPercent *= 1.5f;
		while (time < buffTime)
		{ 
			time += Time.deltaTime;
			yield return null;
		}
		blackboard.speedDebuffPercent /= 1.5f;
		dash = null;
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
