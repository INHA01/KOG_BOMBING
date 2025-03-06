using System.Collections;
using System.Collections.Generic;
using JetBrains.Annotations;
using Photon.Pun;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using DTT.AreaOfEffectRegions;
using Unity.IO.LowLevel.Unsafe;
using Unity.Collections.LowLevel.Unsafe;

namespace Semin
{
	public class Landmine : AttackConsum
	{
		[Range(0f, 10f), SerializeField] private float interval;
		[Range(1f, 10f), SerializeField] private float attackRange;
		[Range(0f, 10f), SerializeField] private float rigidityTime;
		[Range(1f, 100f), SerializeField] private float damage;
		[Range(0f, 100f), SerializeField] private float activeTime;
		[Range(0f, 1000f), SerializeField] private float hp;
		[SerializeField] SRPCircleRegionProjector decal;
		public override float Damage { get { return damage; } }
		PhotonView pView;
		Coroutine destroyCoroutine;

		private void Awake()
		{
			pView = GetComponent<PhotonView>();
			decal.GenerateProjector();
		}

		public override void Use()
		{
			destroyCoroutine = StartCoroutine(SetTimerToDestroy());
			isActive = true;
		}

		public override void SetTeam(int team, PlayerData playerData)
		{
			base.SetTeam(team, playerData);
			if (attackCollider == null)
				attackCollider = gameObject.GetComponent<SphereCollider>();
			attackCollider.radius = attackRange / 2f;
			attackCollider.isTrigger = true;
			attackCollider.gameObject.SetActive(true);
			LandmineDamage dam = transform.GetChild(0).GetComponent<LandmineDamage>();
			dam.Initialize(this.team, hp);
			SetDecal();
		}


		private void OnTriggerEnter(Collider other)
		{
			if (other.CompareTag("Bullet"))
				return;

			Molotov molotov = other.GetComponent<Molotov>();
			if (molotov != null)
			{
				RPCDestroy();
			}
			if (other.tag == "Player")
			{
				PhotonView otherPv = other.transform.GetComponent<PhotonView>();
				if (!otherPv) return;
				if (!IsOtherTeam(otherPv)) return;

				ActiveWarringArea();
				StartCoroutine(Bomb());
			}
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

		IEnumerator SetTimerToDestroy()
		{
			yield return new WaitForSeconds(activeTime);
			Release();
			isActive = false;
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
		}

		IEnumerator Bomb()
		{
			if (!pView) yield break;
			ShowParticle();
			yield return new WaitForSeconds(interval);
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
					{
						player.OnDamaged(Damage, playerIndex);
						player.OnRigidity(rigidityTime);
					}
				}
			}

			if (destroyCoroutine != null)
				StopCoroutine(destroyCoroutine);
			yield return new WaitForSeconds(0.5f);
			Release();
			isActive = false;
		}
		public void DestroyLandmine()
		{
			RPCDestroy();
		}
		[PunRPC]
		private void RPCDestroy()
		{
            Release();
            isActive = false;
        }
		private void OnDrawGizmos()
		{
			Gizmos.color = Color.red;
			Gizmos.DrawWireSphere(transform.position, attackRange / 2);
		}
	}

}
