using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using BAEK;
public class AttackRange 
{
    GameObject[] attackRange = new GameObject[(int)Range.Max];

    LineRenderer[] lineRenderer = new LineRenderer[2];

    PlayerData playerData;

    public void Init(Transform model , PlayerData playerData)
    {
        if (!playerData.pv.IsMine) return;

        this.playerData = playerData;

        attackRange[(int)Range.Attack] = playerData.AttackRange;
        lineRenderer[0] = playerData.SetRenderer(attackRange[(int)Range.Attack]);
        attackRange[(int)Range.Attack].transform.SetParent(model);

        attackRange[(int)Range.NoAttack] = playerData.NoAttackRange;
        lineRenderer[1] = playerData.SetRenderer(attackRange[(int)Range.NoAttack]);
        attackRange[(int)Range.NoAttack].transform.SetParent(model);

        attackRange[(int)Range.MaxAttack] = playerData.MaxAttackRange;
        playerData.SetDecalProjector(attackRange[(int)Range.MaxAttack]);
        attackRange[(int)Range.MaxAttack].transform.SetParent(model);
        attackRange[(int)Range.MaxAttack].transform.position = (playerData.shootPos[(int)ShootPos.Start].position + playerData.shootPos[(int)ShootPos.End].position) / 2;
        attackRange[(int)Range.MaxAttack].SetActive(false);
    }
    void SetPoint(LineRenderer area, Vector3 start, Vector3 end)
    {
        area.SetPosition(0, start);
        area.SetPosition(1, end);
    }
    public void ShowAttackArea(bool active)
    {
        if (!playerData.pv.IsMine) return;
        attackRange[(int)Range.Attack].SetActive(active);
        attackRange[(int)Range.NoAttack].SetActive(active);
        if(!active) return;

        Vector3 direction = playerData.mousePos - playerData.shootPos[(int)ShootPos.Start].position;
        if (
            (playerData.playerObj.transform.position - playerData.shootPos[(int)ShootPos.Start].position).magnitude
            >
            (playerData.playerObj.transform.position - playerData.mousePos).magnitude
            )
        {
            direction = playerData.shootPos[(int)ShootPos.Start].position - playerData.mousePos;
        }
        float mousePosLength = direction.magnitude;

        float attackRangeLength = mousePosLength;

        bool rayHit = false;
        Ray shootRay = new Ray(playerData.shootPos[(int)ShootPos.Start].position, direction);
        Vector3 hitPoint = Vector3.zero;
        RaycastHit[] hits = Physics.RaycastAll(shootRay, playerData.maxLength);
        for (int i = 0; i < hits.Length; i++)
        {
            if (hits[i].collider.gameObject.tag != "Bullet" )
            {
                hitPoint = hits[i].point;
                float distance = (hitPoint - playerData.shootPos[(int)ShootPos.Start].position).magnitude;
                if (distance < attackRangeLength)
                    attackRangeLength = distance;
                rayHit = true;
                break;
            }
        }

        if (attackRangeLength > playerData.maxLength || rayHit)
        {
            if(!rayHit)
                attackRangeLength = playerData.maxLength;
            attackRange[(int)Range.NoAttack].SetActive(true);
        }
        else
            attackRange[(int)Range.NoAttack].SetActive(false);


        Vector3 startPos = playerData.shootPos[(int)ShootPos.Start].position;
        startPos.y -= 0.8f;

        Vector3 canAttackPoint = startPos + direction.normalized * attackRangeLength;

        playerData.canAttackPoint = canAttackPoint;
        playerData.shootDirection = direction.normalized;
        SetPoint(lineRenderer[0], startPos, canAttackPoint);
        Vector3 canNotAttackPoint = new Vector3(playerData.mousePos.x, canAttackPoint.y, playerData.mousePos.z);
        SetPoint(lineRenderer[1], canAttackPoint, canNotAttackPoint);
    }
    public void ShowDistance(bool show)
    {
        if (show)
            attackRange[(int)Range.MaxAttack].SetActive(true);
        else
            attackRange[(int)Range.MaxAttack].SetActive(false);
    }
}
