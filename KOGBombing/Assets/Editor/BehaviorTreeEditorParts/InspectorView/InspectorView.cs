using Semin;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;
using System.Reflection;
using UnityEditor.UIElements;
using UnityEditor.IMGUI.Controls;
using Unity.VisualScripting.FullSerializer.Internal;
using System.Security.Policy;

public class InspectorView : VisualElement
{
	public DropdownField dropDown;

	public UnityEngine.Object objectValue;	

	PlayerController playerController;
	public new class UxmlFactory : UxmlFactory<InspectorView, VisualElement.UxmlTraits> { }
	Editor editor;
	private MethodInfo[] methods;
	public NodeView SelectNode;

	public InspectorView()
	{
	}

    internal void UpdateSelection(NodeView nodeView)
	{
		Clear();
		SelectNode = nodeView;
        UnityEngine.Object.DestroyImmediate(editor);
		editor = Editor.CreateEditor(nodeView.node);

		IMGUIContainer container = new IMGUIContainer(() => { editor.OnInspectorGUI(); });
		Add(container);	
	}

	private void CallFunction(MethodInfo method)
	{
		// 메서드의 반환 타입에 따라 호출
		if (method.ReturnType == typeof(int))
		{
			int result = (int)method.Invoke(playerController, null);
			Debug.Log($"{method.Name}의 반환값: {result}");
		}
		else if (method.ReturnType == typeof(string))
		{
			string result = (string)method.Invoke(playerController, null);
			Debug.Log($"{method.Name}의 반환값: {result}");
		}
		else if (method.ReturnType == typeof(float))
		{
			float result = (float)method.Invoke(playerController, null);
			Debug.Log($"{method.Name}의 반환값: {result}");
		}
	}
}
