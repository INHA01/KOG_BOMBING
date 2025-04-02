using System.Collections.Generic;
using System.Text;
using UnityEngine;

public enum ECameraType
{
    MAINCAMERA,
    MINIMAPCAMERA,
    EFFECTCAMERA,
    MAX
}
public class CameraManager
{
    Dictionary<ECameraType, GameObject> dicCamera = new Dictionary<ECameraType, GameObject>();
    private float sensitive = 1;
    public CameraManager()
    {

    }
    public void SetSensitive(float value)
    {
        sensitive = value;
    }
    public float GetSensitive()
    {
        return sensitive;
    }
    public void AddCamera(GameObject cameraObj, ECameraType eCameraType)
    {
        dicCamera.Add(eCameraType, cameraObj);
    }
    public bool IsContainCamera(ECameraType key)
    {
        if (!dicCamera.ContainsKey(key))
            return false;
        return true;
    }
    public GameObject GetCamera(ECameraType key)
    {
        if (!dicCamera.ContainsKey(key)) return null;
        return dicCamera[key];
    }
    public void RemoveCamera(ECameraType key)
    {
        if (!dicCamera.ContainsKey(key))
        {
            Debug.Log("카메라 삭제 실패 in CameraManager");
            return;
        }
        dicCamera.Remove(key);
    }
    public void InitCamera()
    {
        dicCamera.Clear();
    }
}