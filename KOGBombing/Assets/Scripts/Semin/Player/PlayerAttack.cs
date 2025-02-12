using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Semin;
using UnityEngine.InputSystem;
using Orpul1;
public class PlayerAttack : PlayerBehavior
{
    ISupportWeapon supportWeapon;
    AttackRange attackRange;
    [SerializeField]
    PlayerShooting playerShooting;
    bool isChangableAnim;
    Coroutine animChange;
    protected override void Awake()
    {
        base.Awake();
        attackRange = new AttackRange();
        attackRange.Init(playerData.playerObj.transform, playerData);
        playerShooting.Init(playerData.animator, attackRange);
    }
    private void Start()
    {
        ETeam playerTeam = (ETeam)playerData.pv.Owner.CustomProperties["Team"];
        SetSupportWeapon((int)playerTeam);
        playerData.supportWeapon.SetTeam(playerTeam);
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


    void SetSupportWeapon(int team)
    {
        if (team == (int)ETeam.REDTEAM)
        {
            playerData.supportWeapon = gameObject.AddComponent<ThrowableWeapon>();
            if (playerData.supportWeapon is SupportWeaponBase support)
                support.SetConsum(WeaponType.MOLOTOV);
        }
        else
        {
            playerData.supportWeapon = gameObject.AddComponent<DeployableWeapon>();
            if (playerData.supportWeapon is SupportWeaponBase support)
                support.SetConsum(WeaponType.LANDMINE);
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
    public INode.ENodeState LayingLandmine()
    {
        if (playerData.supportWeapon is DeployableWeapon deploy)
        {
            if (isChangableAnim)
            {
                ChangeWeapon(WeaponType.NONE);
                animChange = StartCoroutine(WaitForChangeAnim(1.5f, WeaponType.GUN));
                playerData.supportWeapon.SetWeapon(new SupportWeaponInfo(transform.position));
                playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Landmine);
                playerData.supportWeapon.Use();
            }
            if (animChange != null)
            {
                return INode.ENodeState.Running;
            }
            else
            {
                isChangableAnim = true;
                blackBoard.inputs[EKey.NUM_2] = false;
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
                    Debug.Log("End anim");
                    blackBoard.inputs[EKey.LMOUSEBUTTON] = false;
                    blackBoard.inputs[EKey.NUM_2] = false;
                    playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Granade, false);
                    playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Cancel);
                    playerData.animator.ResetAnimTrigger(PlayerAnimation.AnimType.Cancel);
                    isChangableAnim = true;
                    return INode.ENodeState.Success;
                }
            }

            if (Physics.Raycast(cameraRay, out hit))
            {
                Vector3 targetPoint = hit.point;
                playerData.supportWeapon.SetWeapon(new ThrowableWeaponInfo(playerData.shootStartPos.position, targetPoint,
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
    public void OnUseAttackConsum(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        if (blackBoard.playerStatus.groggyable == false) return;

        isChangableAnim = true;
        WeaponType weaponType = WeaponType.GUN;
        blackBoard.inputs[EKey.NUM_2] = !blackBoard.inputs[EKey.NUM_2];

        if (blackBoard.inputs[EKey.NUM_2])
        {
            playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Granade, true);
            if (playerData.supportWeapon is SupportWeaponBase baseWeapon)
                weaponType = baseWeapon.consum.type;
        }
        else
        {
            playerData.animator.SetAnimBool(PlayerAnimation.AnimType.Granade, false);
            playerData.animator.SetAnimTrigger(PlayerAnimation.AnimType.Cancel);
            playerData.supportWeapon.Disable();
        }

        ChangeWeapon(weaponType);
    }
   
}
