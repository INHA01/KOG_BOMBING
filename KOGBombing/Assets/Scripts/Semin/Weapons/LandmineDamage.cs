using Orpul1;
using Semin;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;

public class LandmineDamage : MonoBehaviour
{
    [SerializeField] Landmine landmine;
    private ETeam team;
    private float hp;
    private float maxHp;

    public void Initialize(ETeam team, float hp)
    {
        this.team = team;
		maxHp = hp;
		this.hp = hp;
    }       

	public void OnDamage(float damage)
	{
		hp -= damage;

        if (hp <= 0) 
            landmine.DestroyLandmine();
    }

	private void OnTriggerEnter(Collider other)
	{
		if (other.CompareTag("Bullet"))
		{
			if (other.GetComponent<movement>() is movement mov)
			{
				if (mov.eTeamBullet != team)
					OnDamage(mov.Damage);
			}
		}
	}
}
