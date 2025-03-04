using DTT.AreaOfEffectRegions;
using Orpul1;
using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShockGrenade : AttackConsum
{
	[Range(0f, 10f), SerializeField] private float interval;
	[Range(1f, 100f), SerializeField] private float range;
	[Range(1f, 10f), SerializeField] private float attackRange;
	[Range(1f, 100f), SerializeField] private float damage;
	[Range(0f, 100f), SerializeField] private float effectTime;
	public override float Damage { get { return damage; } }
	public float Range { get { return range; } }
	
	SRPCircleRegionProjector decal;
    [SerializeField] SRPCircleRegionProjector myTeamDecal;
    [SerializeField] SRPCircleRegionProjector otherTeamDecal;
    PhotonView pView;


	private void Awake()
	{
		pView = GetComponent<PhotonView>();
		myTeamDecal.gameObject.SetActive(false);
		otherTeamDecal.gameObject.SetActive(false);
	}

	public override void SetTeam(int team)
	{
		base.SetTeam(team);
		if ((ETeam)PhotonNetwork.LocalPlayer.CustomProperties[EPropertyType.TEAM.ToString()] != (ETeam)team)
			decal = otherTeamDecal;
		else decal = myTeamDecal;
		if (attackCollider == null)
			attackCollider = gameObject.GetComponent<SphereCollider>();
		attackCollider.radius = attackRange / 2f;
		attackCollider.isTrigger = true;
		attackCollider.gameObject.SetActive(true);
		SetDecal();

    }

	public override void Use()
	{
		ActiveWarringArea();
	}

	private void ActiveWarringArea()
	{
		StartCoroutine(ShowDecal());
	}

	private void SetDecal()
	{
		decal.transform.parent = transform;
		decal.Radius = attackRange;
		decal.GenerateProjector();
		decal.UpdateProjectors();
		decal.gameObject.SetActive(false);
	}

	IEnumerator ShowDecal()
	{
		float time = 0;
		decal.gameObject.SetActive(true);

		while (time < interval)
		{
			time += Time.deltaTime;
			decal.FillProgress = time / interval;
			decal.GenerateProjector();
			yield return null;
		}

		StartCoroutine(Bomb());
	}

	IEnumerator Bomb()
	{
		if (!pView) yield break;
		ShowParticle();
		Collider[] hitColliders = Physics.OverlapSphere(transform.position, attackRange / 2);
		for (int i = 0; i < hitColliders.Length; i++)
		{
			if (hitColliders[i].CompareTag("Player"))
			{
				PhotonView pView = hitColliders[i].GetComponent<PhotonView>();
				if (!pView) continue;
				if (!IsOtherTeam(pView)) continue;

				IDamageAble player = hitColliders[i].GetComponent<IDamageAble>();
				if (player != null)
					player.OnDamaged(Damage, playerIndex);
			}
		}

		yield return new WaitForSeconds(0.5f);
		Release();
	}

	private void OnDrawGizmos()
	{
		Gizmos.color = Color.red;
		Gizmos.DrawWireSphere(transform.position, attackRange / 2);
	}
}
