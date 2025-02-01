using System.Collections;
using System.Collections.Generic;
using Photon.Pun;
using UnityEngine;

namespace Semin
{
	public class Landmine : AttackConsum
	{
		[Range(1f, 100f), SerializeField] private float attackRange;
		[Range(0f, 10f), SerializeField] private float interval;
		[Range(1f, 100f), SerializeField] private float damage;
		[Range(0f, 100f), SerializeField] private float time;
		public override float Damage { get { return damage; } }

		public override void Attack(GameObject gameObject)
		{
			Debug.Log("attack");
		}

		public override void Use()
		{
			StartCoroutine(SetTimer());
		}

		IEnumerator SetTimer()
		{
			yield return new WaitForSeconds(time);
			PhotonNetwork.Destroy(gameObject);
			//Destroy(gameObject);
		}
	}

}
