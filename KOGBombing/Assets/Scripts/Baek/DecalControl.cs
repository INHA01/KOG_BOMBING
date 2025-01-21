using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class DecalControl : MonoBehaviour
{
    [SerializeField] Vector3 pivot;
    [SerializeField] float width;
    
    DecalProjector decalProjector;
    void Start()
    {
        decalProjector = GetComponent<DecalProjector>();
    }

    void Update()
    {
        decalProjector.pivot = pivot;
        decalProjector.size = new Vector2(width, 1);

    }
}
