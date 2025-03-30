using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Semin;
using UnityEngine.InputSystem;
using Orpul1;
using BAEK;
using ExitGames.Client.Photon.StructWrapping;
using Photon.Pun;
using System.Text;
public class PlayerAttack : PlayerBehavior
{
    ISupportWeapon supportWeapon;
    AttackRange attackRange;
    [SerializeField]
    PlayerShooting playerShooting;
    bool isChangableAnim;
    bool isSetBomb = false;
    Coroutine animChange;
    float bombInteractTime;
    Interacting bombNotify;
    PlayerMaterialController materialController;

	protected override void Awake()
    {
        base.Awake();
        bombInteractTime = 0;
        attackRange = new AttackRange();
        attackRange.Init(playerData.playerObj.transform, playerData);
        playerShooting.Init(playerData.animator, attackRange, GetPlayerInfo());
        blackBoard.bombInteraction = gameObject.AddComponent<BombInteraction>();
        materialController = GetComponent<PlayerMaterialController>();
    }
    
    private void Start()
    {
        ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()];
        int playerIndex = (int)playerData.pv.Owner.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
        SetSupportWeapon((int)playerTeam);
        playerData.supportWeapon.SetTeam(playerTeam, playerIndex);
        playerData.bomb.SetTeam(playerTeam, playerIndex);
        InitSkill();
    }
    private PlayerInfo GetPlayerInfo()
    {
        StringBuilder name = new StringBuilder(playerData.pv.Owner.NickName);
        ETeam teamType = (ETeam)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()];
        int teamIndex = (int)playerData.pv.Owner.CustomProperties[EPropertyType.TEAMINDEX.ToString()];
        PlayerInfo playerInfo = new PlayerInfo(name,teamType,teamIndex);
        return playerInfo;
    }
    private void Update()
    {
        if (!playerData.pv.IsMine) return;
        if (attackRange != null)
            attackRange.ShowAttackArea(blackBoard.playerStatus.isLive);
	}

	[PunRPC]
    private void ChangeWeaponAttack(int type)
    {
        animator.ChangeWeapon(playerData, type);
    }


	public bool IsAttackTeam()
    {
        return (ETeam)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()] == ETeam.REDTEAM;
    }

    public bool IsDefenceTeam()
    {
        return (ETeam)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()] == ETeam.BLUETEAM;
    }

    public bool IsUni()
    {
        return (playerData.characterType == CharacterType.Uni);
    }

    public bool IsNed()
    {
        return (playerData.characterType == CharacterType.Ned);
    }


    void SetSupportWeapon(int team)
    {
        playerData.bomb = gameObject.AddComponent<DeployableBomb>();
        
        GetComponent<DeployableBomb>().Defendency(GetBombData());

        if (team == (int)ETeam.REDTEAM)
        {
            if (playerData.bomb is SupportWeaponBase bomb)
                bomb.SetConsum(WeaponType.BOMB, playerData);
            playerData.supportWeapon = gameObject.AddComponent<ThrowableWeapon>();
            if (playerData.supportWeapon is SupportWeaponBase support)
                support.SetConsum(WeaponType.MOLOTOV, playerData);
        }
        else
        {
            if (playerData.bomb is SupportWeaponBase bomb)
                bomb.SetConsum(WeaponType.NONE, playerData);
            playerData.supportWeapon = gameObject.AddComponent<DeployableWeapon>();
            if (playerData.supportWeapon is SupportWeaponBase support)
                support.SetConsum(WeaponType.LANDMINE, playerData);
        }
    }

    private BombData GetBombData()
    {
        BombData bombData = new BombData()
        {
            nickname = blackBoard.nickname,
            bombState = blackBoard.setBombState
        };
        return bombData;
    }
    void InitSkill()
    {
        switch (playerData.characterType)
        {
            case CharacterType.Ned:
                playerData.skill = gameObject.AddComponent<ThrowableSkill>();
                playerData.skill.InitializationSkill(playerData);
                break;
            case CharacterType.Uni:
				playerData.skill = gameObject.GetComponent<DashSkill>();
				playerData.skill.InitializationSkill(playerData);
				break;
        }
    }
    IEnumerator WaitForChangeAnim(float waitTime, WeaponType type)
    {
        isChangableAnim = false;
        yield return new WaitForSeconds(waitTime);

        animChange = null;
		playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.All, (int)type);
    }

    public INode.ENodeState ShootBullet()
    {
        playerShooting.Shoot();
        return INode.ENodeState.Success;
    }

	private void CancelBomb()
	{
        playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.BombDefuse, false);
        playerData.punAnimator.SetAnimationTrigger(PlayerAnimation.AnimType.Cancel,playerData.mousePos);
        playerData.punAnimator.ResetAnimTrigger(PlayerAnimation.AnimType.Cancel);
        playerData.punAnimator.ResetAnimTrigger(PlayerAnimation.AnimType.Skill);

		playerData.bomb.Disable();
	}
    /*public INode.ENodeState ResetAttackData()
    {
        //if (playerData.bomb is DeployableBomb bomb)
        //    bomb.RoundReset();
        playerShooting.RoundChange();
        return INode.ENodeState.Success;
    }*/
    public INode.ENodeState BombInteract()
    {
        if((blackBoard.playerStatus.isLive == false)|| (blackBoard.playerStatus.isGroggy == true) || (blackBoard.playerStatus.canSettingBomb == false))
        {
            return INode.ENodeState.Fail;
        }
        if (playerData.bomb is DeployableBomb)
        {
            if (bombNotify == null)
            { 
                bombNotify = Managers.UI.GetPopupUI<Interacting>(UIKEY.Interacting);
            }
            if (playerData.animator.GetAnimBool(PlayerAnimation.AnimType.BombDefuse) == true)
            {
                float waitTime = 5.0f;
                if (blackBoard.inputs[EKey.LMOUSEBUTTON] && (bombInteractTime < waitTime)) // 폭탄 설치
                {
                    blackBoard.rigidBody.velocity = Vector2.zero;
                    bombInteractTime += Time.deltaTime;
                    bombNotify.Interact(bombInteractTime / waitTime);

                    playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.BombDefuse, true);
                    if(!isSetBomb)
                    {
                        isSetBomb = true;
                        playerData.pv.RPC("PunBombSound", RpcTarget.All, (int)EMissionSound.BOMBLAUNCHING);
                    }
                    return INode.ENodeState.Running;
                }
                else // 폭탄 설치 취소 or 완료
                {
                    isSetBomb = false;

                    if (!blackBoard.inputs[EKey.LMOUSEBUTTON] && bombInteractTime < waitTime)   // Cancel
					{
                        bombNotify.ActiveCanInteract(false, InteractUI.InteractBomb);
                        bombNotify.SwitchGuide(false);
                        playerData.isInteract = false;
						isChangableAnim = true;
						bombInteractTime = 0;
						blackBoard.inputs[EKey.NUM_2] = false;
						blackBoard.playerStatus.isBombInteract = false;
						playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.All, (int)WeaponType.GUN);
                        playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.BombDefuse, false);

                        if (blackBoard.bombInteraction.GetBomb() != null)
							blackBoard.bombInteraction.SetBombInteraction(false);
						return INode.ENodeState.Fail;
                    }
                    if (isChangableAnim && bombInteractTime >= waitTime)
					{
                        playerData.punAnimator.SetAnimationTrigger(PlayerAnimation.AnimType.BombPlant, playerData.mousePos);
                        playerData.pv.RPC("PunBombSound", RpcTarget.All, (int)EMissionSound.BOMBNARRATION);
                        animChange = StartCoroutine(WaitForChangeAnim(0.7f, WeaponType.GUN));
					}
					if (animChange == null)
					{
						playerData.bomb.Use();
                        bombNotify.gameObject.SetActive(true);
                        bombNotify.ActiveCanInteract(false, InteractUI.InteractBomb);
                        bombNotify.SwitchGuide(false);
                        isChangableAnim = true;
						bombInteractTime = 0;
						blackBoard.inputs[EKey.NUM_2] = false;
                        blackBoard.inputs[EKey.LMOUSEBUTTON] = false;
						blackBoard.playerStatus.isBombInteract = false;
						playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.All, (int)WeaponType.GUN);
                        playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.BombDefuse, false);

						playerData.isInteract = false;
						return INode.ENodeState.Success;
					}

                    return INode.ENodeState.Running;
                }
            }
            if (blackBoard.inputs[EKey.LMOUSEBUTTON])
            {
                if(playerData.isInteract == true)
                {
                    if (playerData.playerTeam == ETeam.BLUETEAM)
                    {
                        if (blackBoard.bombInteraction.GetBomb() != null)
                            blackBoard.bombInteraction.SetBombInteraction(true);
                    }
                    blackBoard.rigidBody.velocity = Vector2.zero;
                    playerData.animator.SetAnimBool(PlayerAnimation.AnimType.BombDefuse, true);
                    //playerData.isInteract = true;
                    bombInteractTime = 0;
                    blackBoard.playerStatus.isBombInteract = true;
                    blackBoard.playerStatus.isBombDefuse = false;
                    return INode.ENodeState.Running;
                }
                bombNotify.SwitchGuide(false);
                playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.All, (int)WeaponType.GUN);
			}

        }
        return INode.ENodeState.Fail;
    }

    [PunRPC]
    private void PunBombSound(int soundType)
    {
        playerData.playerSound.missionSound.ActiveSound(transform, (EMissionSound)soundType);
    }
    private void CancelSupportWeapon()
	{
        playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Granade, false);
        playerData.punAnimator.SetAnimationTrigger(PlayerAnimation.AnimType.Cancel, playerData.mousePos);
		playerData.supportWeapon.Disable();
	}

    public INode.ENodeState LayingLandmine()
    {
        if (playerData.supportWeapon is DeployableWeapon deploy)
        {
            if (isChangableAnim)
            {
                playerData.supportWeapon.Use();
				playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.All, (int)WeaponType.NONE);
				animChange = StartCoroutine(WaitForChangeAnim(1.5f, (int)WeaponType.GUN));
                playerData.supportWeapon.SetWeapon(new SupportWeaponInfo(transform.position));
                playerData.punAnimator.SetAnimationTrigger(PlayerAnimation.AnimType.Landmine, playerData.mousePos);
            }
            if (animChange != null)
            {
                return INode.ENodeState.Running;
            }
            else
            {
                isChangableAnim = true;
                blackBoard.inputs[EKey.NUM_1] = false;
                playerData.punAnimator.ResetAnimTrigger(PlayerAnimation.AnimType.Landmine);
                return INode.ENodeState.Success;
            }
        }
        return INode.ENodeState.Fail;
    }

    public INode.ENodeState SetSupportWeapon()
    {
        if (playerData.supportWeapon is ThrowableWeapon throwable)
        {
            Ray cameraRay = blackBoard.viewCamera.ScreenPointToRay(blackBoard.mousePos);
            RaycastHit hit;

            if (!isChangableAnim)
            {
                if (animChange != null)
                    return INode.ENodeState.Running;
                else
                {
                    blackBoard.inputs[EKey.LMOUSEBUTTON] = false;
                    blackBoard.inputs[EKey.NUM_1] = false;
                    CancelSupportWeapon();
                    playerData.punAnimator.ResetAnimTrigger(PlayerAnimation.AnimType.Cancel);
                    isChangableAnim = true;
                    return INode.ENodeState.Success;
                }
            }

            if (Physics.Raycast(cameraRay, out hit, 100f, LayerMask.GetMask("BackGroundObj")))
            {
                //playerData.consumTargetPos = hit.point;
                playerData.supportWeapon.SetWeapon(new ThrowableWeaponInfo(playerData.shootPos[(int)ShootPos.Start].position - new Vector3(0, 1.22f, 0), hit.point,
                    playerData.playerObj.transform.eulerAngles.y));
            }

            if (blackBoard.inputs[EKey.LMOUSEBUTTON])
            {
                animChange = StartCoroutine(WaitForChangeAnim(0.5f, WeaponType.GUN));
                playerData.supportWeapon.Use();
                playerData.punAnimator.SetAnimationTrigger(PlayerAnimation.AnimType.Throw, playerData.mousePos);
                return INode.ENodeState.Success;
            }
            return INode.ENodeState.Running;
        }

        return INode.ENodeState.Running;
    }

    private void CancelSkill()
    {
        playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Skill, false);
        playerData.punAnimator.SetAnimationTrigger(PlayerAnimation.AnimType.Cancel, playerData.mousePos);
        if (playerData.skill is ThrowableSkill skill)
			skill.Disable();
	}

    public INode.ENodeState SetSkill()
    {
        if (playerData.characterType != CharacterType.Ned) 
            return INode.ENodeState.Fail;

        Ray cameraRay = blackBoard.viewCamera.ScreenPointToRay(blackBoard.mousePos);
        RaycastHit hit;

        if (!isChangableAnim)
        {
            if (animChange != null)
                return INode.ENodeState.Running;
            else
            {
                blackBoard.inputs[EKey.LMOUSEBUTTON] = false;
                blackBoard.inputs[EKey.Q] = false;
                playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Skill, false);
                playerData.punAnimator.SetAnimationTrigger(PlayerAnimation.AnimType.Cancel, playerData.mousePos);
                playerData.punAnimator.ResetAnimTrigger(PlayerAnimation.AnimType.Cancel);
                isChangableAnim = true;
                return INode.ENodeState.Success;
            }
        }

        if (Physics.Raycast(cameraRay, out hit, 100f, LayerMask.GetMask("BackGroundObj")))
        {
            playerData.skill.SetSkill(new ThrowableSkillInfo(playerData.shootPos[(int)ShootPos.Start].position - new Vector3(0, 1.22f, 0), hit.point,
                playerData.playerObj.transform.eulerAngles.y));
        }

        if (blackBoard.inputs[EKey.LMOUSEBUTTON])
        {
            animChange = StartCoroutine(WaitForChangeAnim(0.5f, WeaponType.GUN));
            playerData.punAnimator.SetAnimationTrigger(PlayerAnimation.AnimType.Skill, playerData.mousePos);
            playerData.skill.Use();
            return INode.ENodeState.Success;
        }
        return INode.ENodeState.Running;
    }

    public INode.ENodeState DashSkill()
    {
        if (playerData.characterType != CharacterType.Uni)
            return INode.ENodeState.Fail;

		if (playerData.skill is DashSkill dash)
		{
			if (isChangableAnim)
			{
				Vector3 direction = playerData.mousePos - playerData.animator.transform.position;
				direction.y = 0;
				Quaternion targetRotation = Quaternion.LookRotation(direction);
				playerData.animator.transform.rotation = targetRotation;
				playerData.playerObj.transform.LookAt(playerData.mousePos);

                playerData.skill.SetSkill(new DashSkillInfo(playerData.canAttackPoint, transform.forward, 2f, blackBoard));
				playerData.skill.Use();
				materialController.ChangeMaterialToDashSkill();
				playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.All, (int)WeaponType.NONE);
				animChange = StartCoroutine(WaitForChangeAnim(1.5f, WeaponType.GUN));
                blackBoard.speedDebuff.skillValue = 2f;
                playerData.punAnimator.SetAnimationTrigger(PlayerAnimation.AnimType.Skill, playerData.mousePos);
			}
			if (animChange != null)
			{
                if (!dash.IsRunning())
                {
                    StopCoroutine(animChange);
					animChange = null;
					playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.All, (int)WeaponType.GUN);
				}
				return INode.ENodeState.Running;
			}
			else
			{
				isChangableAnim = true;
				blackBoard.inputs[EKey.Q] = false;

                playerData.punAnimator.SetAnimationTrigger(PlayerAnimation.AnimType.DashEnd, playerData.mousePos);
                playerData.punAnimator.ResetAnimTrigger(PlayerAnimation.AnimType.Skill);
				return INode.ENodeState.Success;
			}
		}
		return INode.ENodeState.Fail;
    }


    public void OnUseBomb(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        if (blackBoard.playerStatus.isGroggy) return;
		if (playerData.bomb is SupportWeaponBase weapon)
            if (weapon.isUsable() == false) return;

        if ((ETeam)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()] == ETeam.REDTEAM)
        {   // Red팀인데 이미 설치된 폭탄이 있다면 2번 못 누름
            Bomb myBomb = gameObject.GetComponent<BombInteraction>().GetBomb();
		    if (myBomb != null)
			    return;            
        }

		ResetAttackInput(EKey.NUM_2);

		isChangableAnim = true;
        WeaponType weaponType = WeaponType.GUN;
        blackBoard.inputs[EKey.NUM_2] = !blackBoard.inputs[EKey.NUM_2];
        if(bombNotify == null)
        {
            bombNotify = Managers.UI.GetPopupUI<Interacting>(UIKEY.Interacting);
        }

        if (blackBoard.inputs[EKey.NUM_2])
        {
            bombNotify.SwitchGuide(true);
            if (playerData.bomb is SupportWeaponBase baseWeapon)
            {
                // �������� ��� ��ź����, �������� ��� �����̹Ƿ� �Ǽ�
                if ((ETeam)playerData.pv.Owner.CustomProperties[EPropertyType.TEAM.ToString()] == ETeam.REDTEAM)
                    weaponType = WeaponType.BOMB;
                else
                    weaponType = WeaponType.NONE;
            }
        }
        else
        {
            bombNotify.SwitchGuide(false);
            playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.BombDefuse, false);
            playerData.punAnimator.SetAnimationTrigger(PlayerAnimation.AnimType.Cancel, playerData.mousePos);
            playerData.bomb.Disable();
		}
		playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.All, (int)weaponType);
	}
    public void OnUseAttackConsum(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        if (blackBoard.playerStatus.isGroggy) return;
		if (playerData.supportWeapon is SupportWeaponBase weapon)
            if (weapon.isUsable() == false) return;
		ResetAttackInput(EKey.NUM_1);

		isChangableAnim = true;
        WeaponType weaponType = WeaponType.GUN;
        blackBoard.inputs[EKey.NUM_1] = !blackBoard.inputs[EKey.NUM_1];

        if (blackBoard.inputs[EKey.NUM_1])
        {
            playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Granade, true);
            if (playerData.supportWeapon is SupportWeaponBase baseWeapon)
                weaponType = baseWeapon.type;
        }
        else
        {
            CancelSupportWeapon();
        }

		playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.All, (int)weaponType);
	}


    public void OnUseSkill(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        if (blackBoard.playerStatus.isGroggy) return;
		if (!playerData.skill.isUsableSkill()) return;
        ResetAttackInput(EKey.Q);

		isChangableAnim = true;
        WeaponType weaponType = WeaponType.GUN;
        blackBoard.inputs[EKey.Q] = !blackBoard.inputs[EKey.Q];

		if (blackBoard.inputs[EKey.Q])
		{
            playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Skill, true);
            //playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Skill); // Uni Test
			if (playerData.skill is ThrowableSkill baseWeapon)
				weaponType = baseWeapon.type;
		}
		else
		{
            playerData.punAnimator.SetAnimationBool(PlayerAnimation.AnimType.Skill, false);
            playerData.punAnimator.SetAnimationTrigger(PlayerAnimation.AnimType.Cancel, playerData.mousePos);
			if (playerData.skill is ThrowableSkill skill)
				skill.Disable();
		}

		playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.All, (int)weaponType);
	}

    public void ResetAttackInput(EKey input)
	{
		if (input != EKey.NUM_2 && blackBoard.inputs[EKey.NUM_2])
		{
			CancelBomb();
			blackBoard.inputs[EKey.NUM_2] = false;
		}
		if (input != EKey.NUM_1 && blackBoard.inputs[EKey.NUM_1])
		{
			CancelSupportWeapon();
			blackBoard.inputs[EKey.NUM_1] = false;
		}
		if (input != EKey.Q && blackBoard.inputs[EKey.Q])
		{
			CancelSkill();
			blackBoard.inputs[EKey.Q] = false;
		}
	}
}
