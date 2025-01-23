using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static UnityEngine.Rendering.HableCurve;

public class RangeLineRenderer : MonoBehaviour
{
    private LineRenderer lineRenderer;
	public int segments = 100; 
	public float radius = 5f; 
	public float visibilityDistance = 3f; 
	public float angle = 70f; 


	void Start()
    {
        lineRenderer = GetComponent<LineRenderer>();
	}
	void Update()
    {
		lineRenderer.positionCount = segments + 1;
		float startAngle = -angle / 2; // 시작 각도
		float angleStep = angle / segments; // 각 세그먼트의 각도

		for (int i = 0; i <= segments; i++)
		{
			float currentAngle = startAngle + i * angleStep;
			float x = Mathf.Cos(currentAngle * Mathf.Deg2Rad) * radius;
			float z = Mathf.Sin(currentAngle * Mathf.Deg2Rad) * radius;
			lineRenderer.SetPosition(i, new Vector3(x, 0, z));
		}
	}
}
