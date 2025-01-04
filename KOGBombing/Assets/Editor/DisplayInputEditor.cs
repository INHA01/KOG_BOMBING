using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting;
using UnityEditor;
using UnityEditor.PackageManager.UI;
using UnityEngine;

namespace Semin
{
	public class DisplayInputEditor : EditorWindow
	{
		PlayerController playerController;
		private Vector2 scrollPosition = new Vector2();

		[MenuItem("My Funcion/Display Input Editor")]
		public static void ShowEditor()
		{
			GetWindow<DisplayInputEditor>("Display Input Editor");
		}

		private void CreateGUI()
		{
			playerController = GameObject.FindWithTag("Player").GetComponent<PlayerController>();
		}

		private void OnInspectorUpdate()
		{
			this.Repaint();
		}

		private void OnGUI()
		{
			playerController = (PlayerController)EditorGUILayout.ObjectField(playerController, typeof(PlayerController), true);
			scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition, GUILayout.ExpandWidth(true), GUILayout.Height(500));

			for (int i = 0; i < playerController.Inputs.Count; i++)
			{
				GUILayout.Label($"Key: {playerController.Inputs.Keys.ElementAt(i)}, Value: {playerController.Inputs.Values.ElementAt(i)}");
			}

			EditorGUILayout.EndScrollView();
		}
	}

}
