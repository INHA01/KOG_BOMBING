using Semin;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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
		while (particle.isPlaying)
		{
			yield return null;
		}
		Destroy(gameObject);
	}

	private void OnTriggerEnter(Collider other)
	{
		if (other.tag == "Player")
		{
			PlayerController player = other.GetComponent<PlayerController>();
			if ( player != null )
			{
				player.OnDamaged(Damage);
			}
		}
		Debug.Log(other.name);
	}
}
