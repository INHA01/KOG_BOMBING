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
        transform.Translate(shootDirection *moveSpeed * Time.deltaTime);
        distance += moveSpeed * Time.deltaTime;
        if (distance > destroyDistance)
        {
            distance = 0;
            Release();
        }
    }

    // >> : 추가된 코드(다른 팀인지 확인)
    private bool IsOtherTeam(PhotonView pView)
    {
        string mineTeam = (string)pView.Owner.CustomProperties["Team"];
        
        Debug.Log($"mineTeam: {mineTeam} : otherTeam: {strTeamBullet}");
        
        if (mineTeam == strTeamBullet) return false;
        return true;
    }
    // << :
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.collider.tag == "Player")
        {
            // >> : 추가된 코드
            PhotonView pView = collision.transform.GetComponent<PhotonView>();
            if (!pView) return;
            if (!IsOtherTeam(pView)) return;
            Debug.Log("OtherTeam");
            // << :
            Rigidbody rigidbody = collision.collider.GetComponent<Rigidbody>();
            rigidbody.AddForce(shootDirection * 10, ForceMode.Impulse);
            distance = 0;
            Release();
        }
        if (collision.collider.tag == "Target")
        {
            //Destroy(collision.gameObject);
            distance = 0;
            Release();
        }
    }
}
