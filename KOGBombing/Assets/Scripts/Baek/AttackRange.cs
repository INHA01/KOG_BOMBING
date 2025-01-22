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
    public void ShowAttackArea()
    {
        Vector3 direction = playerData.mousePos - new Vector3(playerData.shootStartPos.position.x, playerData.mousePos.y, playerData.shootStartPos.position.z);
        float mousePosLength = direction.magnitude;
        float attackRangeLength = mousePosLength;

        bool rayHit = false;
        Ray shootRay = new Ray(playerData.shootStartPos.position, direction);
        RaycastHit[] hits = Physics.RaycastAll(shootRay, playerData.maxLength);
        Vector3 hitPoint = Vector3.zero;
        for (int i = 0; i < hits.Length; i++)
        {
            if (hits[i].collider.tag != "Bullet")
            {
                float distance = (hits[i].point - playerData.shootStartPos.position).magnitude;
                if (distance < attackRangeLength)
                    attackRangeLength = distance;
                rayHit = true;
                hitPoint = hits[i].point;
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

        Vector3 canAttackPoint = playerData.shootStartPos.position + direction.normalized * attackRangeLength;
        SetPoint(lineRenderer1, playerData.shootStartPos.position, canAttackPoint);
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
