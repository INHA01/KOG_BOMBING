using Photon.Pun;
using Semin;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;

public class Molotov : AttackConsum
{
	[SerializeField] ParticleSystem particle;
	[Range(1f, 100f), SerializeField] private float range;
	[Range(1f, 100f), SerializeField] private float damage;
	[Range(0f, 100f), SerializeField] private float effectTime;
	private SphereCollider attackCollider;
	public override float Damage { get { return damage; } }
	public float Range { get { return range; } }

	private void Start()
	{
		attackCollider = gameObject.GetComponent<SphereCollider>();
		attackCollider.radius = range / 2;
		attackCollider.enabled = false;
	}

	public override void Attack(GameObject gameObject)
	{
		throw new System.NotImplementedException();
	}

	public override void Use()
	{
		StartCoroutine(PlayParticle());
	}

	IEnumerator PlayParticle()
	{
		particle.Play();
		attackCollider.enabled = true;
		attackCollider.isTrigger = true;
		yield return new WaitForSeconds(0.5f);
        attackCollider.enabled = false;
        yield return new WaitForSeconds(4f);
		Destroy(gameObject);
	}

	private void OnTriggerEnter(Collider other)
	{
		if (other.tag == "Player")
		{
			PhotonView pView = other.transform.GetComponent<PhotonView>();

			if (!pView) return;
			if (!IsOtherTeam(pView)) return;
			Debug.Log("OtherTeam");

			PlayerController player = other.transform.GetComponent<PlayerController>();
			if ( player != null )
				player.OnDamaged(Damage);
		}
		Debug.Log(other.name);
	}

	private bool IsOtherTeam(PhotonView pView)
	{
		string otherTeam = (string)pView.Owner.CustomProperties["Team"];

		Debug.Log($"mineTeam: {team} : otherTeam: {otherTeam}");

		if (team == otherTeam) return false;
		return true;
	}
}