using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;


public class FixMeshToPivot : MonoBehaviour
{    [MenuItem("Tools/Save Mesh for Selected Objects")]
    static void SaveMeshesForSelectedObjects()
    {
        GameObject[] selectedObjects = Selection.gameObjects;

        if (selectedObjects.Length == 0)
        {
            Debug.LogWarning("선택된 오브젝트가 없습니다!");
            return;
        }

        foreach (GameObject obj in selectedObjects)
        {
            SaveMesh(obj);
        }

        Debug.Log($"총 {selectedObjects.Length} 개의 메쉬를 저장 완료!");
    }

    static void SaveMesh(GameObject obj)
    {
        MeshFilter meshFilter = obj.GetComponent<MeshFilter>();

        if (meshFilter == null || meshFilter.sharedMesh == null)
        {
            Debug.LogWarning($"{obj.name}에 MeshFilter가 없습니다. 건너뜀.");
            return;
        }

        Mesh mesh = meshFilter.sharedMesh;

        // 새로운 메쉬를 생성하여 저장
        Mesh newMesh = Object.Instantiate(mesh);
        newMesh.name = obj.name + "_SavedMesh";

        string folderPath = "Assets/SavedMeshes";
        if (!AssetDatabase.IsValidFolder(folderPath))
        {
            AssetDatabase.CreateFolder("Assets", "SavedMeshes");
        }

        string path = $"{folderPath}/{newMesh.name}.asset";

        if (File.Exists(path))
        {
            Mesh existingMesh = AssetDatabase.LoadAssetAtPath<Mesh>(path);
            if (existingMesh != null)
            {
                existingMesh.vertices = newMesh.vertices;
                existingMesh.triangles = newMesh.triangles;
                existingMesh.normals = newMesh.normals;
                existingMesh.uv = newMesh.uv;
                existingMesh.RecalculateBounds();
                AssetDatabase.SaveAssets();
                meshFilter.sharedMesh = existingMesh;
                return;
            }
        }

        AssetDatabase.CreateAsset(newMesh, path);
        AssetDatabase.SaveAssets();
        meshFilter.sharedMesh = newMesh; // 저장된 메쉬 적용

        Debug.Log($"메쉬 저장 완료: {path}");
    }
}