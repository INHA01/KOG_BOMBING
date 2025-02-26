using System.Collections;
using System.Collections.Generic;
using Unity.Burst.CompilerServices;
using UnityEngine;

public class LookCamera : MonoBehaviour
{
    [SerializeField] Transform trCamera;
    bool canStart = false;
    private void Awake()
    {
        //Managers.camData.InitCamera();
        StartCoroutine(CoWaitInit());
    }
    private IEnumerator CoWaitInit()
    {
        GameObject cameraObj = null;
        while (!Managers.camData.IsContainCamera(ECameraType.MAINCAMERA)) 
        {
            yield return null;
        }
        cameraObj = Managers.camData.GetCamera(ECameraType.MAINCAMERA);
        trCamera = cameraObj.transform;
        canStart = true;
    }
    private void LateUpdate()
    {
        if (!canStart) return;
        if (trCamera == null) return;
        transform.rotation = trCamera.rotation;
    }
}
