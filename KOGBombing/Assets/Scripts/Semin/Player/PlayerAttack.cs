using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Semin;
using UnityEngine.InputSystem;
using Orpul1;
using ExitGames.Client.Photon.StructWrapping;
using Photon.Pun;
public class PlayerAttack : PlayerBehavior
{
    ISupportWeapon supportWeapon;
    AttackRange attackRange;
    [SerializeField]
    PlayerShooting playerShooting;
    bool isChangableAnim;
    Coroutine animChange;
    float bombInteractTime;

    protected override void Awake()
    {
        base.Awake();
        bombInteractTime = 0;
        attackRange = new AttackRange();
        attackRange.Init(playerData.playerObj.transform, playerData);
        playerShooting.Init(playerData.animator, attackRange);
    }
    private void Start()
    {
        ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties["Team"];
        SetSupportWeapon((int)playerTeam);
        playerData.supportWeapon.SetTeam(playerTeam);
        playerData.bomb.SetTeam(playerTeam);
        InitSkill();
    }
    private void Update()
    {
        if (!playerData.pv.IsMine) return;
        if (attackRange != null)
            attackRange.ShowAttackArea();
	}

	[PunRPC]
    private void ChangeWeaponAttack(int type)
    {
        ChangeWeapon(type);
    }


	public bool IsAttackTeam()
    {
        return (ETeam)playerData.pv.Owner.CustomProperties["Team"] == ETeam.REDTEAM;
    }

    public bool IsDefenceTeam()
    {
        return (ETeam)playerData.pv.Owner.CustomProperties["Team"] == ETeam.BLUETEAM;
    }

    public bool IsUni()
    {
        return (blackBoard.characterType == CharacterType.Uni);
    }

    public bool IsNed()
    {
        return (blackBoard.characterType == CharacterType.Ned);
    }


    void SetSupportWeapon(int team)
    {
        playerData.bomb = gameObject.AddComponent<DeployableBomb>();
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

    void InitSkill()
    {
        switch (blackBoard.characterType)
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
		playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.AllBuffered, (int)type);
    }

    public INode.ENodeState ShootBullet()
    {
        playerShooting.Shoot();
        return INode.ENodeState.Success;
    }
    public INode.ENodeState BombInteract()
    {
        if (playerData.bomb is DeployableBomb)
        {
            Ray cameraRay = blackBoard.viewCamera.ScreenPointToRay(playerData.shootStartPos.position);
            RaycastHit hit;
            if (playerData.animator.GetAnimBool(PlayerAnimation.AnimType.BombDefuse) == true)
            {
                float waitTime = 5.0f;
                if (blackBoard.inputs[EKey.LMOUSEBUTTON] && (bombInteractTime < waitTime))
                {
                    bombInteractTime += Time.deltaTime;
                    blackBoard.bombUI.BombInteracting(bombInteractTime / waitTime);
                    return INode.ENodeState.Running;
                }
                else
                {
                    if (!blackBoard.inputs[EKey.LMOUSEBUTTON] && bombInteractTime < waitTime)   // 중간에 취소
					{
						blackBoard.bombUI.ActiveInteract(false);
						isChangableAnim = true;
						bombInteractTime = 0;
						blackBoard.inputs[EKey.NUM_2] = false;
						blackBoard.playerStatus.isBombInteract = false;
						playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.AllBuffered, (int)WeaponType.GUN);
						playerData.animator.SetAnimBool(PlayerAnimation.AnimType.BombDefuse, false);
						return INode.ENodeState.Fail;
                    }
                    if (isChangableAnim && bombInteractTime >= waitTime)
					{
						playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.BombPlant);
						animChange = StartCoroutine(WaitForChangeAnim(0.7f, WeaponType.GUN));
					}
					if (animChange == null)
					{
						playerData.bomb.Use();
						blackBoard.bombUI.ActiveInteract(false);
						isChangableAnim = true;
						bombInteractTime = 0;
						blackBoard.inputs[EKey.NUM_2] = false;
                        blackBoard.inputs[EKey.LMOUSEBUTTON] = false;
						blackBoard.playerStatus.isBombInteract = false;
						playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.AllBuffered, (int)WeaponType.GUN);
						playerData.animator.SetAnimBool(PlayerAnimation.AnimType.BombDefuse, false);
						//playerData.animator.ResetAnimTrigger(PlayerAnimation.AnimType.BombPlant);
						return INode.ENodeState.Success;
					}
					return INode.ENodeState.Running;
                }
            }
            if (Physics.Raycast(cameraRay, out hit, 100f, LayerMask.GetMask("BackGroundObj")))
            {
                playerData.bomb.SetWeapon(new SupportWeaponInfo(hit.point));
            }
            if (blackBoard.inputs[EKey.LMOUSEBUTTON])
            {
                Collider[] colliders = Physics.OverlapSphere(blackBoard.transform.position, 1f);
				for (int i = 0; i < colliders.Length; i++)
                {
                    if (
                        (
                            ((ETeam)playerData.pv.Owner.CustomProperties["Team"] == ETeam.REDTEAM)
                            && colliders[i].CompareTag("BombInteract")
                        )
                        ||
                        (
                            ((ETeam)playerData.pv.Owner.CustomProperties["Team"] == ETeam.BLUETEAM)
                            && colliders[i].CompareTag("Bomb")
                        )
                       ) 
                    {
                        if(colliders[i].CompareTag("Bomb"))
                        {
                            Vector3 lookDir = colliders[i].transform.position - gameObject.transform.position;
                            playerData.playerObj.transform.rotation = Quaternion.LookRotation(lookDir);
						}
                        playerData.animator.SetAnimBool(PlayerAnimation.AnimType.BombDefuse, true);
                        blackBoard.bombUI.ActiveInteract(true);
                        bombInteractTime = 0;
                        blackBoard.playerStatus.isBombInteract = true;
                        blackBoard.playerStatus.isBombDefuse = false;
                        return INode.ENodeState.Running;
                    }
				}
				playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.AllBuffered, (int)WeaponType.GUN);
			}

        }
        return INode.ENodeState.Fail;
    }
    public INode.ENodeState LayingLandmine()
    {
        if (playerData.supportWeapon is DeployableWeapon deploy)
        {
            if (isChangableAnim)
            {
                playerData.supportWeapon.Use();
				playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.AllBuffered, (int)WeaponType.NONE);
				animChange = StartCoroutine(WaitForChangeAnim(1.5f, (int)WeaponType.GUN));
                playerData.supportWeapon.SetWeapon(new SupportWeaponInfo(transform.position));
                playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Landmine);
            }
            if (animChange != null)
            {
                return INode.ENodeState.Running;
            }
            else
            {
                isChangableAnim = true;
                blackBoard.inputs[EKey.NUM_1] = false;
                playerData.animator.ResetAnimTrigger(PlayerAnimation.AnimType.Landmine);
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
                    playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Granade, false);
                    playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Cancel);
                    playerData.animator.ResetAnimTrigger(PlayerAnimation.AnimType.Cancel);
                    isChangableAnim = true;
                    return INode.ENodeState.Success;
                }
            }

            if (Physics.Raycast(cameraRay, out hit, 100f, LayerMask.GetMask("BackGroundObj")))
            {
                //playerData.consumTargetPos = hit.point;
                playerData.supportWeapon.SetWeapon(new ThrowableWeaponInfo(playerData.shootStartPos.position - new Vector3(0, 1.22f, 0), hit.point,
                    playerData.playerObj.transform.eulerAngles.y));
            }

            if (blackBoard.inputs[EKey.LMOUSEBUTTON])
            {
                animChange = StartCoroutine(WaitForChangeAnim(0.5f, WeaponType.GUN));
                playerData.supportWeapon.Use();
                playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Throw);
                return INode.ENodeState.Success;
            }
            return INode.ENodeState.Running;
        }

        return INode.ENodeState.Running;
    }

    public INode.ENodeState SetSkill()
    {
        if (blackBoard.characterType != CharacterType.Ned) 
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
                playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Skill, false);
                playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Cancel);
                playerData.animator.ResetAnimTrigger(PlayerAnimation.AnimType.Cancel);
                isChangableAnim = true;
                return INode.ENodeState.Success;
            }
        }

        if (Physics.Raycast(cameraRay, out hit, 100f, LayerMask.GetMask("BackGroundObj")))
        {
            playerData.skill.SetSkill(new ThrowableSkillInfo(playerData.shootStartPos.position - new Vector3(0, 1.22f, 0), hit.point,
                playerData.playerObj.transform.eulerAngles.y));
        }

        if (blackBoard.inputs[EKey.LMOUSEBUTTON])
        {
            animChange = StartCoroutine(WaitForChangeAnim(0.5f, WeaponType.GUN));
            playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Skill);
            playerData.skill.Use();
            return INode.ENodeState.Success;
        }
        return INode.ENodeState.Running;
    }

    public INode.ENodeState DashSkill()
    {
        if (blackBoard.characterType != CharacterType.Uni)
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
				playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.AllBuffered, (int)WeaponType.NONE);
				animChange = StartCoroutine(WaitForChangeAnim(1.5f, WeaponType.GUN));
                blackBoard.speedDebuffPercent *= 1.5f;
				playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Skill);
			}
			if (animChange != null)
			{
                if (!dash.IsRunning())
                {
                    StopCoroutine(animChange);
					animChange = null;
					playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.AllBuffered, (int)WeaponType.GUN);
				}
				return INode.ENodeState.Running;
			}
			else
			{
				isChangableAnim = true;
				blackBoard.inputs[EKey.Q] = false;
                blackBoard.speedDebuffPercent /= 1.5f;

				playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.DashEnd);
				playerData.animator.ResetAnimTrigger(PlayerAnimation.AnimType.Skill);
				return INode.ENodeState.Success;
			}
		}
		return INode.ENodeState.Fail;
    }


    public void OnUseBomb(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        if (blackBoard.playerStatus.groggyable == false) return;
        if (blackBoard.inputs[EKey.Q] || blackBoard.inputs[EKey.NUM_1]) return;
		if (playerData.bomb is SupportWeaponBase weapon)
            if (weapon.isUsable() == false) return;
        isChangableAnim = true;
        WeaponType weaponType = WeaponType.GUN;
        blackBoard.inputs[EKey.NUM_2] = !blackBoard.inputs[EKey.NUM_2];

        if (blackBoard.inputs[EKey.NUM_2])
        {
            //playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Bomb, true);
            if (playerData.bomb is SupportWeaponBase baseWeapon)
            {
                // 공격팀인 경우 폭탄장착, 수비팀에 경우 해제이므로 맨손
                if ((ETeam)playerData.pv.Owner.CustomProperties["Team"] == ETeam.REDTEAM)
                    weaponType = WeaponType.BOMB;
                else
                    weaponType = WeaponType.NONE;
            }
        }
        else
        {
            playerData.animator.SetAnimBool(PlayerAnimation.AnimType.BombDefuse, false);
            playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Cancel);
            playerData.bomb.Disable();
		}
		playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.AllBuffered, (int)weaponType);
	}
    public void OnUseAttackConsum(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        if (blackBoard.playerStatus.groggyable == false) return;
		if (blackBoard.inputs[EKey.NUM_2] || blackBoard.inputs[EKey.Q]) return;
		if (playerData.supportWeapon is SupportWeaponBase weapon)
            if (weapon.isUsable() == false) return;

        isChangableAnim = true;
        WeaponType weaponType = WeaponType.GUN;
        blackBoard.inputs[EKey.NUM_1] = !blackBoard.inputs[EKey.NUM_1];

        if (blackBoard.inputs[EKey.NUM_1])
        {
            playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Granade, true);
            if (playerData.supportWeapon is SupportWeaponBase baseWeapon)
                weaponType = baseWeapon.type;
        }
        else
        {
            playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Granade, false);
            playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Cancel);
            playerData.supportWeapon.Disable();
        }

		playerData.pv.RPC("ChangeWeaponAttack", RpcTarget.AllBuffered, (int)weaponType);
	}


    public void OnUseSkill(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        if (blackBoard.playerStatus.groggyable == false) return;
		if (blackBoard.inputs[EKey.NUM_2] || blackBoard.inputs[EKey.NUM_1]) return;
		if (!playerData.skill.isUsableSkill()) return;

        isChangableAnim = true;
        WeaponType weaponType = WeaponType.GUN;
        blackBoard.inputs[EKey.Q] = !blackBoard.inputs[EKey.Q];

		if (blackBoard.inputs[EKey.Q])
		{
			playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Skill, true);
            playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Skill); // Uni Test
			if (playerData.skill is ThrowableSkill baseWeapon)
				weaponType = baseWeapon.type;
		}
		else
		{
			playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Skill, false);
			playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Cancel);
			if (playerData.skill is ThrowableSkill skill)
				skill.Disable();
		}
	}
}
