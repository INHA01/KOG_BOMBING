using System.Collections;
using System.Collections.Generic;
using JetBrains.Annotations;
using Photon.Pun;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using DTT.AreaOfEffectRegions;
using Unity.IO.LowLevel.Unsafe;

namespace Semin
{
	public class Landmine : AttackConsum
	{
		[Range(0f, 10f), SerializeField] private float interval;
		[Range(1f, 10f), SerializeField] private float attackRange;
		[Range(0f, 10f), SerializeField] private float rigidityTime;
		[Range(1f, 100f), SerializeField] private float damage;
		[Range(0f, 100f), SerializeField] private float activeTime;
		[SerializeField] SRPCircleRegionProjector decal;
		public override float Damage { get { return damage; } }
		PhotonView pView;
		Coroutine destroyCoroutine;

		private void Awake()
		{
			pView = GetComponent<PhotonView>();
		}

		private void Start()
		{
			decal.transform.parent = transform;
			decal.Radius = attackRange;
			decal.GenerateProjector();
			if (attackCollider == null)
			{
				attackCollider = gameObject.GetComponent<SphereCollider>();
				attackCollider.gameObject.SetActive(false);
				attackCollider.radius = attackRange / 2f;
			}
		}

		public override void Use()
		{
			destroyCoroutine = StartCoroutine(SetTimerToDestroy());
		}

		public override void SetTeam(int team)
		{
			base.SetTeam(team);
			if (attackCollider == null)
				attackCollider = gameObject.GetComponent<SphereCollider>();
			attackCollider.radius = attackRange / 2f;
			attackCollider.isTrigger = true;
			attackCollider.gameObject.SetActive(true);
		}

		private void OnTriggerEnter(Collider other)
		{
			if (other.tag == "Player")
			{
				PhotonView otherPv = other.transform.GetComponent<PhotonView>();
				//if (!otherPv) return;
				//if (!IsOtherTeam(otherPv)) return;

				pView.RPC("ActiveWarringArea", RpcTarget.AllBuffered);
			}
		}

		[PunRPC]
		private void ActiveWarringArea()
		{
			StartCoroutine(ShowDecal());
		}

		IEnumerator SetTimerToDestroy()
		{
			yield return new WaitForSeconds(activeTime);
			PhotonNetwork.Destroy(gameObject);
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
			Debug.Log("ASDFSD");
			if (!pView) yield break;
			pView.RPC("ShowParticle", RpcTarget.AllBuffered);
			Collider[] hitColliders = Physics.OverlapSphere(transform.position, attackRange);
			for (int i = 0; i < hitColliders.Length; i++)
			{
				if (hitColliders[i].CompareTag("Player"))
				{
					if (!IsOtherTeam(hitColliders[i].transform.GetComponent<PhotonView>())) continue;
					PlayerController player = hitColliders[i].transform.GetComponent<PlayerController>();
					if (player != null)
					{
						player.OnDamaged(Damage);
						player.OnRigidity(rigidityTime);
					}
				}
			}

			if (destroyCoroutine != null)
				StopCoroutine(destroyCoroutine);
			yield return new WaitForSeconds(0.5f);	// particle 출력 이후 destroy
			PhotonNetwork.Destroy(gameObject);
		}

		private void OnDrawGizmos()
		{
			Gizmos.color = Color.red;
			Gizmos.DrawWireSphere(transform.position, attackRange);
		}
	}

}
