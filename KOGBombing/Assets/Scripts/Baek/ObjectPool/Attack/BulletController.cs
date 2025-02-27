using Orpul1;
using Photon.Pun;
using Semin;
using System.Collections;
using UnityEngine;

public class BulletController : PooledObject
{
    [SerializeField] protected float moveSpeed;
    [HideInInspector] public ETeam eTeamBullet;
    [SerializeField] protected int damage = 20;

   [SerializeField] protected Rigidbody rb;
    protected float destroyDistance;
    protected float distance;
    public float DestroyDistance { get => destroyDistance; set => destroyDistance = value; }
    public float Damage { get { return damage; } }

    protected virtual void FixedUpdate()
    {
        rb.velocity = transform.forward * moveSpeed;
        distance += moveSpeed * Time.deltaTime;
        if (distance > destroyDistance)
        {
            distance = 0;
            Release();
        }
    }

    protected bool IsOtherTeam(PhotonView pView)
    {
        ETeam mineTeam = (ETeam)pView.Owner.CustomProperties["Team"];
        
        if (mineTeam == eTeamBullet) return false;
        return true;
    }
    protected virtual void OnTriggerEnter(Collider other)
	{
		if (other.CompareTag("IgnoreBullet"))
		{
            if (other.GetComponent<Landmine>() != null) return;
		}

		if (other.tag != "Bullet")
        {
            if (other.tag == "Player")
            {
                // >> : �� ����
                PhotonView pView = other.GetComponent<PhotonView>();
                if (!pView) return;
                if (!IsOtherTeam(pView)) return;
                // << :
                IDamageAble player = other.transform.GetComponent<IDamageAble>();
                if (player != null)
                    player.OnDamaged(damage);
            }
            distance = 0;
            Release();
        }
    }
}
