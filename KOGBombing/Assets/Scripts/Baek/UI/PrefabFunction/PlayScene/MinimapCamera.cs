using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.ProBuilder.Shapes;

public class MinimapCamera : MonoBehaviour
{
    public GameObject target;
    private void FixedUpdate()
    {
        this.transform.position = new Vector3(
            target.transform.position.x,
            target.transform.position.y + 50f,
            target.transform.position.z
            );
    }
}
