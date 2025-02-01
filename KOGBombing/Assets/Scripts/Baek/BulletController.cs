using Photon.Pun;
using System.Collections;
using UnityEngine;

public class BulletController : PooledObject
{
    [SerializeField] float moveSpeed;
    [HideInInspector] public string strTeamBullet;
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
        string mineTeam = (string)pView.Owner.CustomProperties["Team"];
        
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
            //Rigidbody rigidbody = other.GetComponent<Rigidbody>();
            //rigidbody.AddForce(shootDirection * 10, ForceMode.Impulse);
            PlayerController player = other.transform.GetComponent<PlayerController>();
            if (player != null)
                player.OnDamaged(damage);
            distance = 0;
            Release();
        }
        if (other.tag == "Target")
        {
            distance = 0;
            Release();
        }
    }
}
