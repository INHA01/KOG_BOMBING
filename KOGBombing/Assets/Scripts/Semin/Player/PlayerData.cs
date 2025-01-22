using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class PlayerData : MonoBehaviour
{
    [Header("Shooting")]
    public Transform shootStartPos;
    public Transform shootEndPos;
    public float maxLength;
    public Vector3 mousePos;

    [Header("AttackRange")]
    [SerializeField] GameObject attackRangePrefab;
    [SerializeField] GameObject noAttackRangePrefab;
    [SerializeField] GameObject maxAttackRangePrefab;

    [Header("Photon")]
    [SerializeField] public PhotonView pv;

    public GameObject AttackRange { get { return Instantiate(attackRangePrefab); } }
    public GameObject NoAttackRange { get { return Instantiate(noAttackRangePrefab); } }
    public GameObject MaxAttackRange { get { return Instantiate(maxAttackRangePrefab); } }
    public LineRenderer SetRenderer(GameObject attackRange) 
    { 
        LineRenderer lineRenderer = attackRange.GetComponent<LineRenderer>();
        lineRenderer.startWidth = 2.0f * transform.localScale.x;
        lineRenderer.endWidth = 2.0f * transform.localScale.x;
        return lineRenderer;
    }
    public void SetDecalProjector(GameObject maxAttackRange)
    {
        DecalProjector decalProjector = maxAttackRange.GetComponent<DecalProjector>();
        decalProjector.size = new Vector3(maxLength, 5, 0.2f);
    }
}
