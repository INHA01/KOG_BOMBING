using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AttackArea : MonoBehaviour
{
    [SerializeField] float width = 2f;
    LineRenderer area;

    private void Start()
    {
        area = GetComponent<LineRenderer>();
        area.startWidth = width;
        area.endWidth = width;
    }
    public void SetPoint(Vector3 start, Vector3 end)
    {
        area.SetPosition(0, start);
        area.SetPosition(1, end);
    }
}
