using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class AttackRange 
{
    GameObject attackRange;
    GameObject noAttackRange;
    GameObject maxAttackRange;

    LineRenderer lineRenderer1;
    LineRenderer lineRenderer2;

    PlayerData playerData;

    public void Init(Transform model , PlayerData playerData)
    {
        if (!playerData.pv.IsMine) return;

        this.playerData = playerData;

        attackRange = playerData.AttackRange;
        lineRenderer1 = playerData.SetRenderer(attackRange);
        attackRange.transform.SetParent(model);

        noAttackRange = playerData.NoAttackRange;
        lineRenderer2 = playerData.SetRenderer(noAttackRange);
        noAttackRange.transform.SetParent(model);

        maxAttackRange = playerData.MaxAttackRange;
        playerData.SetDecalProjector(maxAttackRange);
        maxAttackRange.transform.SetParent(model);
        maxAttackRange.transform.position = (playerData.shootStartPos.position + playerData.shootEndPos.position) / 2;
        maxAttackRange.SetActive(false);
    }
    void SetPoint(LineRenderer area, Vector3 start, Vector3 end)
    {
        area.SetPosition(0, start);
        area.SetPosition(1, end);
    }
    public void ShowAttackArea(bool active)
    {
        if (!playerData.pv.IsMine) return;
        attackRange.SetActive(active);
        noAttackRange.SetActive(active);
        if(!active) return;

        Vector3 direction = playerData.mousePos - playerData.shootStartPos.position;
        if (
            (playerData.playerObj.transform.position - playerData.shootStartPos.position).magnitude
            >
            (playerData.playerObj.transform.position - playerData.mousePos).magnitude
            )
        {
            direction = playerData.shootStartPos.position - playerData.mousePos;
        }
        float mousePosLength = direction.magnitude;

        float attackRangeLength = mousePosLength;

        bool rayHit = false;
        Ray shootRay = new Ray(playerData.shootStartPos.position, direction);
        Vector3 hitPoint = Vector3.zero;
        RaycastHit[] hits = Physics.RaycastAll(shootRay, playerData.maxLength);
        for (int i = 0; i < hits.Length; i++)
        {
            if (hits[i].collider.gameObject.tag != "Bullet" )
            {
                hitPoint = hits[i].point;
                float distance = (hitPoint - playerData.shootStartPos.position).magnitude;
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
            noAttackRange.SetActive(true);
        }
        else
            noAttackRange.SetActive(false);


        Vector3 startPos = playerData.shootStartPos.position;
        startPos.y -= 0.8f;

        Vector3 canAttackPoint = startPos + direction.normalized * attackRangeLength;

        playerData.canAttackPoint = canAttackPoint;
        playerData.shootDirection = direction.normalized;
        SetPoint(lineRenderer1, startPos, canAttackPoint);
        Vector3 canNotAttackPoint = new Vector3(playerData.mousePos.x, canAttackPoint.y, playerData.mousePos.z);
        SetPoint(lineRenderer2, canAttackPoint, canNotAttackPoint);
    }
    public void ShowDistance(bool show)
    {
        if (show)
            maxAttackRange.SetActive(true);
        else
            maxAttackRange.SetActive(false);
    }
}
