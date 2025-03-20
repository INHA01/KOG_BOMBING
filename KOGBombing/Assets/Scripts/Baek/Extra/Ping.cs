using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class Ping : MonoBehaviour
{
    VisualEffect[] visualEffects;
    public void Init()
    {
        visualEffects = this.gameObject.GetComponentsInChildren<VisualEffect>();
    }
    public Vector3 GetPingPos(Vector2 pos)
    {
        Ray ray;
        RaycastHit hit;
        ray = Camera.main.ScreenPointToRay(pos);
        if (Physics.Raycast(ray, out hit, 100f, LayerMask.GetMask("BackGroundObj")))
        {
            return hit.point;
        }
        return Vector3.zero;
    }
    public void ShowEffect(Vector3 pos)
    {
        this.gameObject.transform.position = pos;
        for (int i = 0; i < visualEffects.Length; i++)
        {
            visualEffects[i].SendEvent("Click");
        }
    }
}
