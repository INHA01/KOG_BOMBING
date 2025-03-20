using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using BAEK;
using DTT.AreaOfEffectRegions;

public class PlayerData : MonoBehaviour
{
    [Header("Shooting")]
    public Transform[] shootPos = new Transform[(int)ShootPos.Max];
    public Vector3 canAttackPoint;
    public Vector3 shootDirection;
    public float maxLength;
    public Vector3 mousePos;
    public PlayerSoundData playerSound;

    [Header("Photon")]
    public PhotonView pv;

    [Header("Player Info")]
    public Rigidbody rigidBody;
	public float timeWithoutDamage;
    public GameObject minimapIcon;
    public SRPCircleRegionProjector pivot;

	[Header("Model Anim")]
    public GameObject playerObj;
    public Transform playerLookObj;
    public PunAnimation punAnimator;
    public PlayerAnimation animator;

	[Header("Hide Material")]
    public List<GameObject> changeMaterialMeshs = new List<GameObject>();
    public List<Material> changeMaterials = new List<Material>();
    public Material hitMaterial;

    [Header("Weapon")]
    public List<WeaponData> weapons = new List<WeaponData>();
    public ISupportWeapon supportWeapon;
    public ISupportWeapon bomb;
    public Vector3 consumTargetPos;
    [SerializeField] public Transform ConsumPos;

    [Header("Interact")]
    public bool isInteract = false;
    public bool isGroggyInteracting = false;

    [Header("Skill")]
    public ISkill skill;

    public GameObject AttackRange { get { return Managers.Resource.Instantiate("AttackPrefabs/AttackRange"); } }
    public GameObject NoAttackRange { get { return Managers.Resource.Instantiate("AttackPrefabs/NoAttackRange"); } }
    public GameObject MaxAttackRange { get { return Managers.Resource.Instantiate("AttackPrefabs/MaxAttackRange"); } }
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

    public void InitializeCount()
    {
        if (supportWeapon is DeployableWeapon)
			supportWeapon.Initialize(2);
		else supportWeapon.Initialize(1);
        bomb.Initialize(1);
    }
}
