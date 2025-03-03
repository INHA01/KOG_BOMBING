//#if UNITY_EDITOR
//using UnityEngine;
//using UnityEditor;
//namespace IndieImpulseAssets
//{
//    public class CreateUIPrefab : MonoBehaviour
//    {
//        // List of single-word base names for prefabs
//        static readonly string[] prefabBaseNames = {
//        "Fighting", "Horror", "SciFi", "Adventure", "Cyberpunk", "Espionage",
//        "Mystery", "PostApocalyptic", "RPG", "Strategy", "Survival", "War"
//    };

//        static void AddUIPrefabToCanvas(string baseName)
//        {
//            // Construct the prefab name with the "SingleTextEffect" suffix
//            string prefabName = baseName + "SingleTextEffect";

//            // Construct the prefab path dynamically
//            string prefabPath = $"Assets/IndieImpulse_Assets/Text Effects/Prefabs/{prefabName}.prefab";

//            // Load the prefab from the project assets
//            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);

//            if (prefab == null)
//            {
//                Debug.LogError($"Prefab '{prefabName}' not found at path: {prefabPath}");
//                return;
//            }

//            // Get the currently selected object in the hierarchy
//            GameObject selectedObject = Selection.activeGameObject;

//            // Ensure the selected object is a canvas or a child of a canvas
//            Canvas canvas = selectedObject != null ? selectedObject.GetComponentInParent<Canvas>() : null;
//            if (canvas == null)
//            {
//                Debug.LogWarning($"Please select a Canvas or a child object of a Canvas to add '{baseName}' prefab.");
//                return;
//            }

//            // Instantiate the prefab as a child of the canvas
//            GameObject newInstance = (GameObject)PrefabUtility.InstantiatePrefab(prefab);
//            newInstance.transform.SetParent(canvas.transform, false);

//            // Optional: Automatically select the newly created object
//            Selection.activeGameObject = newInstance;

//            Debug.Log($"{prefabName} prefab added to canvas.");
//        }

//        // Dynamically generate menu items for each prefab
//        [MenuItem("GameObject/UI/FightingTextEffect", false, 10)]
//        static void AddFightingTextEffect() => AddUIPrefabToCanvas("Fighting");

//        [MenuItem("GameObject/UI/HorrorTextEffect", false, 11)]
//        static void AddHorrorTextEffect() => AddUIPrefabToCanvas("Horror");

//        [MenuItem("GameObject/UI/SciFiTextEffect", false, 12)]
//        static void AddSciFiTextEffect() => AddUIPrefabToCanvas("SciFi");

//        [MenuItem("GameObject/UI/AdventureTextEffect", false, 13)]
//        static void AddAdventureTextEffect() => AddUIPrefabToCanvas("Adventure");

//        [MenuItem("GameObject/UI/CyberpunkTextEffect", false, 14)]
//        static void AddCyberpunkTextEffect() => AddUIPrefabToCanvas("Cyberpunk");

//        [MenuItem("GameObject/UI/EspionageTextEffect", false, 15)]
//        static void AddEspionageTextEffect() => AddUIPrefabToCanvas("Espionage");

//        [MenuItem("GameObject/UI/MysteryTextEffect", false, 16)]
//        static void AddMysteryTextEffect() => AddUIPrefabToCanvas("Mystery");

//        [MenuItem("GameObject/UI/PostApocalypticTextEffect", false, 17)]
//        static void AddPostApocalypticTextEffect() => AddUIPrefabToCanvas("PostApocalyptic");

//        [MenuItem("GameObject/UI/RPGTextEffect", false, 18)]
//        static void AddRPGTextEffect() => AddUIPrefabToCanvas("RPG");

//        [MenuItem("GameObject/UI/StrategyTextEffect", false, 19)]
//        static void AddStrategyTextEffect() => AddUIPrefabToCanvas("Strategy");

//        [MenuItem("GameObject/UI/SurvivalTextEffect", false, 20)]
//        static void AddSurvivalTextEffect() => AddUIPrefabToCanvas("Survival");

//        [MenuItem("GameObject/UI/WarTextEffect", false, 21)]
//        static void AddWarTextEffect() => AddUIPrefabToCanvas("War");
//    }
//#endif
//}