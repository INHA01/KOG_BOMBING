using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class CenterPivotTool : MonoBehaviour
{
    [MenuItem("Tools/Center Pivot for Selected Objects")]
    static void CenterPivotsForSelectedObjects()
    {
        GameObject[] selectedObjects = Selection.gameObjects;

        if (selectedObjects.Length == 0)
        {
            Debug.LogWarning("선택된 오브젝트가 없습니다!");
            return;
        }

        Undo.RecordObjects(selectedObjects, "Center Pivot");

        foreach (GameObject obj in selectedObjects)
        {
            CenterPivot(obj);
        }

        Debug.Log($"총 {selectedObjects.Length} 개의 오브젝트 피벗을 중앙으로 이동 완료!");
    }

    static void CenterPivot(GameObject obj)
    {
        MeshFilter meshFilter = obj.GetComponent<MeshFilter>();
        if (meshFilter == null || meshFilter.sharedMesh == null)
        {
            Debug.LogWarning($"{obj.name}에 MeshFilter가 없습니다. 건너뜀.");
            return;
        }

        Mesh mesh = meshFilter.sharedMesh;
        Vector3[] vertices = mesh.vertices;

        // 중앙 계산
        Vector3 center = Vector3.zero;
        foreach (Vector3 vertex in vertices)
        {
            center += vertex;
        }
        center /= vertices.Length;

        // 모든 정점을 중앙 기준으로 이동
        for (int i = 0; i < vertices.Length; i++)
        {
            vertices[i] -= center;
        }
        mesh.vertices = vertices;
        mesh.RecalculateBounds();
        mesh.RecalculateNormals();

        // 원래 위치 유지
        Vector3 worldCenter = obj.transform.TransformPoint(center);
        obj.transform.position = worldCenter;
    }
}