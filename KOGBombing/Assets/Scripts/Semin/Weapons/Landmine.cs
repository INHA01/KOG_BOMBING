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
        Coroutine destroyCoroutine;

        private void Awake()
        {
            pView = GetComponent<PhotonView>();
        }

        private void Start()
        {
            if (attackCollider == null)
            {
                attackCollider = gameObject.GetComponent<SphereCollider>();
                attackCollider.isTrigger = false;
            }
        }

        public override void Use()
		{
            destroyCoroutine = StartCoroutine(SetTimerToDestroy());
		}

        public override void SetTeam(string team)
        {
            base.SetTeam(team);
            if (attackCollider == null)
                attackCollider = gameObject.GetComponent<SphereCollider>();
            attackCollider.isTrigger = true;
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
                PhotonView otherPv = other.transform.GetComponent<PhotonView>();

                if (!otherPv) return;
                if (!IsOtherTeam(otherPv)) return;

                StartCoroutine(Bomb(otherPv));
            }
        }

        IEnumerator Bomb(PhotonView otherPv)
        {
            if (!pView) yield break;
            yield return new WaitForSeconds(interval);
            pView.RPC("ShowParticle", RpcTarget.AllBuffered);
            Debug.Log("터지냐");

            Collider[] hitColliders = Physics.OverlapSphere(transform.position, attackRange);
            for (int i = 0; i < hitColliders.Length; i++)
            {
                if (hitColliders[i].CompareTag("Player"))
                {
                    if (!IsOtherTeam(otherPv)) continue;
                    PlayerController player = hitColliders[i].transform.GetComponent<PlayerController>();
                    if (player != null)
                    {
                        Debug.Log("맞음");
                        player.OnDamaged(Damage);
                        player.OnRigidity(rigidityTime);
                    }
                }
            }

            if (destroyCoroutine != null) 
                StopCoroutine(destroyCoroutine);
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
