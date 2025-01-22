using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class AttackRange : MonoBehaviour
{
    [Header("AttackRange")]
    [SerializeField] GameObject attackRangePrefab;
    [SerializeField] GameObject noAttackRangePrefab;
    [SerializeField] GameObject maxAttackRangePrefab;

    GameObject attackRange;
    GameObject noAttackRange;
    GameObject maxAttackRange;

    LineRenderer lineRenderer1;
    LineRenderer lineRenderer2;
    DecalProjector decalProjector;

    PlayerData playerData;

    #region Attack area
    public void Init(Transform model)
    {
        playerData = GetComponent<PlayerData>();

        attackRange = Instantiate(attackRangePrefab);
        lineRenderer1 = attackRange.GetComponent<LineRenderer>();
        lineRenderer1.startWidth = 2.0f * this.transform.localScale.x;
        lineRenderer1.endWidth = 2.0f * this.transform.localScale.x;
        attackRange.transform.SetParent(model);

        noAttackRange = Instantiate(noAttackRangePrefab);
        lineRenderer2 = noAttackRange.GetComponent<LineRenderer>();
        lineRenderer2.startWidth = 2.0f * this.transform.localScale.x;
        lineRenderer2.endWidth = 2.0f * this.transform.localScale.x;
        noAttackRange.transform.SetParent(model);

        maxAttackRange = Instantiate(maxAttackRangePrefab);
        maxAttackRange.transform.SetParent(model);
        maxAttackRange.transform.position = (playerData.shootStartPos.position + playerData.shootEndPos.position) / 2;
        maxAttackRange.SetActive(false);
        decalProjector = maxAttackRange.GetComponent<DecalProjector>();
        decalProjector.size = new Vector3(playerData.maxLength, 5, 0.2f);
    }
    public void SetPoint(LineRenderer area, Vector3 start, Vector3 end)
    {
        area.SetPosition(0, start);
        area.SetPosition(1, end);
    }
    public void ShowAttackArea(PlayerData playerData)
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
    #endregion
}
