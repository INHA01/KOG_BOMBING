using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

namespace Semin
{
	public class Landmine : AttackConsum
	{
		[Range(0f, 10f), SerializeField] private float interval;
		[Range(1f, 10f), SerializeField] private float attackRange;
        [Range(0f, 10f), SerializeField] private float rigidityTime;
		[Range(1f, 100f), SerializeField] private float damage;
		[Range(0f, 100f), SerializeField] private float activeTime;
        public override float Damage { get { return damage; } }
        PhotonView pView;

        private void Awake()
        {
            pView = GetComponent<PhotonView>();
        }

        private void Start()
        {
            attackCollider = gameObject.GetComponent<SphereCollider>();
            attackCollider.isTrigger = true;
        }

        public override void Use()
		{
			StartCoroutine(SetTimerToDestroy());
		}

		IEnumerator SetTimerToDestroy()
		{
			yield return new WaitForSeconds(activeTime);
			PhotonNetwork.Destroy(gameObject);
        }

        private void OnTriggerEnter(Collider other)
        {
            if (other.tag == "Player")
            {
                PhotonView pView = other.transform.GetComponent<PhotonView>();

                if (!pView) return;
                if (!IsOtherTeam(pView)) return;

                StartCoroutine(Bomb());
            }
        }

        IEnumerator Bomb()
        {
            if (!pView) yield break;
            yield return new WaitForSeconds(interval);
            pView.RPC("ShowParticle", RpcTarget.AllBuffered);

            Collider[] hitColliders = Physics.OverlapSphere(transform.position, attackRange);
            for (int i = 0; i < hitColliders.Length; i++)
            {
                if (hitColliders[i].CompareTag("Player"))
                {
                    if (!IsOtherTeam(pView)) continue;
                    PlayerController player = hitColliders[i].transform.GetComponent<PlayerController>();
                    if (player != null)
                    {
                        player.OnDamaged(Damage);
                        player.OnRigidity(rigidityTime);
                    }
                }
            }

            yield return new WaitForSeconds(0.5f);
            PhotonNetwork.Destroy(gameObject);
        }

        private void OnDrawGizmos()
        {
            Gizmos.color = Color.red; 
            Gizmos.DrawWireSphere(transform.position, attackRange);
        }
    }

}
