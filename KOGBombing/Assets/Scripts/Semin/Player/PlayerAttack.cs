using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Semin;
using UnityEngine.InputSystem;
using Orpul1;
using ExitGames.Client.Photon.StructWrapping;
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
        InitSkill();
    }
    private void Update()
    {
        if (!playerData.pv.IsMine) return;
        if (attackRange != null)
            attackRange.ShowAttackArea();
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
                break;
        }
    }
    IEnumerator WaitForChangeAnim(float waitTime, WeaponType type)
    {
        isChangableAnim = false;
        yield return new WaitForSeconds(waitTime);

        animChange = null;
        ChangeWeapon(type);
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
            if (!isChangableAnim)
            {
                float waitTime = 5.0f;
                if (blackBoard.inputs[EKey.LMOUSEBUTTON] && (bombInteractTime < waitTime))
                {
                    bombInteractTime += Time.deltaTime;
                    // 여기에 공격팀은 폭탄 설치  , 수비팀은 해제 애니메이션 추가
                    return INode.ENodeState.Running;
                }
                else
                {
                    if (bombInteractTime >= waitTime)
                    {
                        if((ETeam)playerData.pv.Owner.CustomProperties["Team"] == ETeam.REDTEAM)
                            playerData.bomb.Use();
                        else
                        {
                            // playerData.bomb.Use();에 해당 코드를 통일하였으나 2개 선언된다 문제생김
                            // 추측상으로는 지뢰에 use와 pun함수가 겹쳐져 발생하는 듯
                            blackBoard.playerStatus.isBombDefuse = true;
                        }
                    }
                    isChangableAnim = true;
                    bombInteractTime = 0;
                    blackBoard.inputs[EKey.NUM_2] = false;
                    blackBoard.playerStatus.isBombInteract = false;
                    ChangeWeapon(WeaponType.GUN);
                    return INode.ENodeState.Success;
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
                        bombInteractTime = 0;
                        isChangableAnim = false;
                        blackBoard.playerStatus.isBombInteract = true;
                        blackBoard.playerStatus.isBombDefuse = false;
                    }
                }
            }
        }
        return INode.ENodeState.Running;
    }
    public INode.ENodeState LayingLandmine()
    {
        if (playerData.supportWeapon is DeployableWeapon deploy)
        {
            if (isChangableAnim)
            {
                playerData.supportWeapon.Use();
                ChangeWeapon(WeaponType.NONE);
                animChange = StartCoroutine(WaitForChangeAnim(1.5f, WeaponType.GUN));
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
                playerData.supportWeapon.SetWeapon(new ThrowableWeaponInfo(playerData.shootStartPos.position - new Vector3(0, 1.6f, 0), hit.point,
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
        switch (blackBoard.characterType)
        {
            case CharacterType.Ned:
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
                    playerData.skill.SetSkill(new ThrowableSkillInfo(playerData.shootStartPos.position - new Vector3(0, 1.6f, 0), hit.point,
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
            case CharacterType.Uni:
                break;
        }
        return INode.ENodeState.Running;
    }
    public void OnUseBomb(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        if (blackBoard.playerStatus.groggyable == false) return;
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
                if((ETeam)playerData.pv.Owner.CustomProperties["Team"] == ETeam.REDTEAM)
                    weaponType = WeaponType.BOMB;
                else
                    weaponType = WeaponType.NONE;
            }
        }
        else
        {
            //playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Bomb, false);
            //playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Cancel);
            playerData.bomb.Disable();
        }
        ChangeWeapon(weaponType);
    }

    public void OnUseAttackConsum(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        if (blackBoard.playerStatus.groggyable == false) return;
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

        ChangeWeapon(weaponType);
    }


    public void OnUseSkill(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        if (blackBoard.playerStatus.groggyable == false) return;
        if (!playerData.skill.isUsableSkill()) return;

        isChangableAnim = true;
        WeaponType weaponType = WeaponType.GUN;
        blackBoard.inputs[EKey.Q] = !blackBoard.inputs[EKey.Q];

        if (blackBoard.inputs[EKey.Q])
        {
            playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Skill, true);
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
