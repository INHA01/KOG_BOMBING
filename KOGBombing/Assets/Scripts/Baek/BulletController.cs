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
    protected virtual void OnCollisionEnter(Collision collision)
    {
        if (collision.collider.tag == "Player")
        {
            // >> : �� ����
            PhotonView pView = collision.collider.GetComponent<PhotonView>();
            if (!pView) return;
            if (!IsOtherTeam(pView)) return;
            // << :
            IDamageAble player = collision.collider.transform.GetComponent<IDamageAble>();
            if (player != null)
                player.OnDamaged(damage);
        }
        distance = 0;
        Release();
    }
}
