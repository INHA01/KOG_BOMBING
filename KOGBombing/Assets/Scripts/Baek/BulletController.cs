using System.Collections;
using UnityEngine;

public class BulletController : PooledObject
{
    [SerializeField]
    float moveSpeed;

    [SerializeField]
    int damage = 2;

    float destroyTime = 5f;

    float span = 0;

    public float DestroyTime { get => destroyTime; set => destroyTime = value; }
    void Update()
    {
        span += Time.deltaTime;
        transform.Translate(new Vector3(0, 0, moveSpeed) * Time.deltaTime);
        if (span > destroyTime)
        {
            span = 0;
            Release();
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.collider.tag == "Player")
        {
            //collision.collider.GetComponent<PlayerController>().Hit(damage);
            span = 0;
            Release();
        }
    }
}
