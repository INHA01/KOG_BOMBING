using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Reflection;
using Photon.Pun;
using Unity.VisualScripting;
using UnityEngine;
using Semin;

public class DashSkill : MonoBehaviour, ISkill
{
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


	PlayScene playScene;
	public void InitializationSkill(PlayerData playerData)
	{
		if(playerData.pv.IsMine)
		{
			playScene = Managers.UI.GetPopupUI<PlayScene>("PlayCanvas");
			playScene.SetSkillIcon(CharacterType.Uni);
		}

        bisUsableSkill = true;
        this.playerData = playerData;
		particle.gameObject.SetActive(false);
	}

	public void Initialize(int count)
	{

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
        StartCoroutine(Cooldown(3f));
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
		CapsuleCollider collider = playerData.gameObject.GetComponent<CapsuleCollider>();

		// >> Managers.PunData를 통해 플레이어의 blackBoard를 가져오는 방식으로 변경
		PlayerBlackBoard blackBoard = Managers.PunData.GetPlayerBlackBoard(playerData.pv.Owner.NickName);
		playerData.isInteract = true;
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
			movement = playerData.animator.transform.forward * blackBoard.playerStatus.moveSpeed * blackBoard.speedDebuff.GetValue();
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
		playerData.isInteract = false;
		particle.gameObject.SetActive(false);
        isRunning = false;
		time = 0;
        blackBoard.speedDebuff.skillValue = 1.5f;
		playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.DashEnd);
		playerData.animator.ResetAnimTrigger(PlayerAnimation.AnimType.Skill);
		while (time < buffTime)
		{ 
			time += Time.deltaTime;
			yield return null;
		}
		blackBoard.speedDebuff.skillValue = 1f;
		playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.DashEnd);
		playerData.animator.ResetAnimTrigger(PlayerAnimation.AnimType.Skill);
		dash = null;
		// << :
	}

	IEnumerator Cooldown(float time)
	{
        skillDeltaTime = 0f;
		playScene.SetSkillActive(false);
        while (!bisUsableSkill)
		{
            skillDeltaTime += Time.deltaTime;
            playScene.skillFade.fillAmount = skillDeltaTime / time;
            playScene.skillCount.text = ((int)(time - skillDeltaTime)).ToString();
            if (skillDeltaTime > time)
            {
                playScene.skillFade.fillAmount = 0;
                playScene.skillCount.text = "";
                bisUsableSkill = true;
				playScene.SetSkillActive(true);
            }
            yield return null;
		}
	}
	public void LoadSkillIcon()
	{
        playScene.SetSkillIcon(CharacterType.Uni);
    }
}
