using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class movement : BulletController
{
    //public float speed;
    public float fireRate;
    public GameObject muzzlePrefab;
    public GameObject hitPrefab;
    public List<GameObject> leftOver;

    void Awake()
    {
       if (muzzlePrefab != null)
        {
            var muzzleVFX = Instantiate(muzzlePrefab, transform.position, Quaternion.identity);
            muzzleVFX.transform.forward = gameObject.transform.forward;
            var psMuzzle = muzzleVFX.GetComponent<ParticleSystem> ();
            if (psMuzzle != null)
                Destroy(muzzleVFX, psMuzzle.main.duration);
            else
            {
                var psChild = muzzleVFX.transform.GetChild (0).GetComponent<ParticleSystem> ();
                Destroy (muzzleVFX, psChild.main.duration);
            }
        } 
    }


    //void Update()
    //{
    //   if (speed != 0)
    //    {
    //        transform.position += transform.forward * (speed * Time.deltaTime);
    //    }
    //    else
    //    {
    //        Debug.Log("No Speed");
    //    }
    //}
    protected override void OnTriggerEnter(Collider other)
    {
        base.OnTriggerEnter(other);
        if (leftOver.Count > 0)
        {
            for (int i = 0; i < leftOver.Count; i++)
            {
                //leftOver[i].transform.parent = null;
                var ps = leftOver[i].GetComponent<ParticleSystem>();
                if (ps != null)
                {
                    ps.Stop();
                    //StartCoroutine(DeactivateAndReparent(leftOver[i], ps.main.duration + ps.main.startLifetime.constantMax));
                    //Destroy(ps.gameObject, ps.main.duration + ps.main.startLifetime.constantMax);

                }
            }
        }

        //speed = 0;

        //ContactPoint contact = other.contacts[0];
        //Quaternion rot = Quaternion.FromToRotation(Vector3.up, contact.normal);
        //Vector3 pos = contact.point;
        Vector3 contactPoint = other.ClosestPoint(transform.position);
        Quaternion rot = Quaternion.FromToRotation(Vector3.up, other.transform.position - contactPoint);
        Vector3 pos = contactPoint;

        if (hitPrefab != null)
        {
            var hitVFX = Instantiate(hitPrefab, pos, rot);
            var psHit = hitVFX.GetComponent<ParticleSystem>();
            if (psHit != null)
                Destroy(hitVFX, psHit.main.duration);

            else
            {
                var psChild = hitVFX.transform.GetChild(0).GetComponent<ParticleSystem>();
                Destroy(hitVFX, psChild.main.duration);
            }
        }
    }
    private IEnumerator DeactivateAndReparent(GameObject obj, float delay)
    {
        yield return new WaitForSeconds(delay);
        obj.SetActive(false);
        obj.transform.parent = transform;
    }
}
