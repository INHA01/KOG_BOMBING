using System.Collections;
using UnityEngine;

public class BulletController : PooledObject
{
    [SerializeField] float moveSpeed;
    //[SerializeField] int damage = 2;

    public Vector3 shootDirection;
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

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.collider.tag == "Player")
        {
            //collision.collider.GetComponent<PlayerController>().Hit(damage);
            Release();
        }
        if (collision.collider.tag == "Target")
        {
            Destroy(collision.gameObject);
            Release();
        }
    }
}
