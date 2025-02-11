using Orpul1;
using Photon.Pun;
using Semin;
using System.Collections;
using UnityEngine;

public class BulletController : PooledObject
{
    [SerializeField] float moveSpeed;
    [HideInInspector] public ETeam strTeamBullet;
    [SerializeField] int damage = 20;

   [HideInInspector] public Vector3 shootDirection;
    float destroyDistance;
    float distance;
    public float DestroyDistance { get => destroyDistance; set => destroyDistance = value; }

    void Update()
    {
        transform.Translate(shootDirection * moveSpeed * Time.deltaTime);
        distance += moveSpeed * Time.deltaTime;
        if (distance > destroyDistance)
        {
            distance = 0;
            Release();
        }
    }

    private bool IsOtherTeam(PhotonView pView)
    {
        ETeam mineTeam = (ETeam)pView.Owner.CustomProperties["Team"];
        
        if (mineTeam == strTeamBullet) return false;
        return true;
    }
    private void OnTriggerEnter(Collider other)
    {
        
        if (other.tag == "Player")
        {
            // >> : ÆÀ ±¸ºÐ
            PhotonView pView = other.GetComponent<PhotonView>();
            if (!pView) return;
            if (!IsOtherTeam(pView)) return;
            // << :
            IDamageAble player = other.transform.GetComponent<IDamageAble>();
            if (player != null)
                player.OnDamaged(damage);
            distance = 0;
            Release();
        }
        if (other.tag == "Wall")
        {
            distance = 0;
            Release();
        }
        
    }
}
