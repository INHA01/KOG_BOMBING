using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Unity.VisualScripting;

public class EditorSetPhysicsMaterial : MonoBehaviour
{
    [MenuItem("Tools/PhysicMaterial/SetStaticPhysicMaterial")]
    public static void SetPhysicsMaterial()
    {
        if (!(Selection.activeObject is GameObject targetObj)) return;
        Collider[] childColls = targetObj.GetComponentsInChildren<Collider>();
        PhysicMaterial physicMaterial = Resources.Load<PhysicMaterial>("PhysicsMaterials/StaticMaterial");
        for (int i = 0; i < childColls.Length; i++)
        {
            childColls[i].material = physicMaterial;
        }
    }
}
