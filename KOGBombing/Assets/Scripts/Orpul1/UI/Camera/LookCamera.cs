using System.Collections;
using System.Collections.Generic;
using Unity.Burst.CompilerServices;
using UnityEngine;

public class LookCamera : MonoBehaviour
{
    [SerializeField] Transform trCamera;
    bool canStart = false;
    private void Start()
    {
        Managers.CamData.InitCamera();
        StartCoroutine(CoWaitInit());
    }
    private IEnumerator CoWaitInit()
    {
        GameObject cameraObj = null;
        while (!Managers.CamData.IsContainCamera(ECameraType.MAINCAMERA)) 
        {
            yield return null;
        }
        cameraObj = Managers.CamData.GetCamera(ECameraType.MAINCAMERA);
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
