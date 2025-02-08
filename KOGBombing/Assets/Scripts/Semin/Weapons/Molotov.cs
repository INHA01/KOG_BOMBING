using Photon.Pun;
using Semin;
using System.Collections;
using UnityEngine;

public class Molotov : AttackConsum
{
	[Range(1f, 100f), SerializeField] private float range;
	[Range(1f, 100f), SerializeField] private float damage;
	[Range(0f, 100f), SerializeField] private float effectTime;
	public override float Damage { get { return damage; } }
	public float Range { get { return range; } }
	PhotonView pView;

    private void Awake()
    {
        pView = GetComponent<PhotonView>();
    }

    private void Start()
	{
		attackCollider = gameObject.GetComponent<SphereCollider>();
		attackCollider.radius = range / 2;
		attackCollider.enabled = false;
	}

	public override void Use()
	{
		StartCoroutine(PlayParticle());
	}

	IEnumerator PlayParticle()
	{
		pView.RPC("ShowParticle", RpcTarget.AllBuffered);
		attackCollider.enabled = true;
		attackCollider.isTrigger = true;
		yield return new WaitForSeconds(0.5f);
        attackCollider.enabled = false;
        yield return new WaitForSeconds(4f);
		PhotonNetwork.Destroy(gameObject);
	}

	private void OnTriggerEnter(Collider other)
	{
        if (other.tag == "Player")
		{
			PhotonView pv = other.transform.GetComponent<PhotonView>();

			if (!pView) return;
			if (!IsOtherTeam(pv)) return;

			PlayerController player = other.transform.GetComponent<PlayerController>();
			if (player != null)
				player.OnDamaged(Damage);
		}
	}
}