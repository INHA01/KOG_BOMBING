using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;
using Semin;
using UnityEditor.UIElements;
using Unity.VisualScripting;
using System.Reflection;
using Unity.VisualScripting.FullSerializer.Internal;
using PlasticPipe.PlasticProtocol.Messages;
using UnityEngine.InputSystem.XR;
using UnityEditor.Rendering;

public class BehaviorTreeEditor : EditorWindow
{
    [SerializeField]
    BehaviorTreeView treeView;
    InspectorView inspectorView;
    ObjectFieldView fieldView;
    FuncDropdownFieldView funcDropdownView;
    ClassDropdownFieldView classDropdownView;
    NodeView selectNode;
    KeyParameterView keyParameterView;
    DirectionParameterView directionParameterView;

    PlayerController playerController;
	private MethodInfo[] methods;
    private ParameterInfo[] parameters;

    [MenuItem("My Funcion/Behaviour Tree/Editor ...")]
    public static void OpenWindow()
    {
        BehaviorTreeEditor wnd = GetWindow<BehaviorTreeEditor>();
        wnd.titleContent = new GUIContent("BehaviorTreeEditor");
    }

    public void CreateGUI()
    {
        // Each editor window contains a root VisualElement object
        VisualElement root = rootVisualElement;

        var visualTree = AssetDatabase.LoadAssetAtPath<VisualTreeAsset>("Assets/Editor/BehaviorTreeEditor.uxml");
        visualTree.CloneTree(root);

        // Style
        var styleSheet = AssetDatabase.LoadAssetAtPath<StyleSheet>("Assets/Editor/BehaviorTreeEditor.uss");
        root.styleSheets.Add(styleSheet);

        treeView = root.Q<BehaviorTreeView>();
        inspectorView = root.Q<InspectorView>();

        fieldView = root.Q<ObjectFieldView>();
        funcDropdownView = root.Q<FuncDropdownFieldView>();
        classDropdownView = root.Q<ClassDropdownFieldView>();
        keyParameterView = root.Q<KeyParameterView>();
        directionParameterView = root.Q<DirectionParameterView>();

        treeView.OnNodeSelected = OnNodeSelectionChanged;
        treeView.focusable = true;

        fieldView.OnChanged = OnObjectSelectionChanged;
        fieldView.OnChanged.Invoke(fieldView);

        classDropdownView.OnSelected = OnClassSelectionChanged;

        funcDropdownView.OnSelected = OnFuncSelectionChanged;

        directionParameterView.OnSelected = OnDirectionSelectionChanged;
        keyParameterView.OnSelected = OnKeySelectionChanged;

        fieldView.SetEnabled(false);
        funcDropdownView.SetEnabled(false);
        classDropdownView.SetEnabled(false);
        keyParameterView.SetEnabled(false);
        directionParameterView.SetEnabled(false);
    }

	private void OnSelectionChange()
	{
		BehaviorTreeAsset tree = Selection.activeObject as BehaviorTreeAsset;

        if (tree)
        {
            treeView.PopulateView(tree);
            EditorUtility.SetDirty(tree);
        }
    }

    void OnNodeSelectionChanged(NodeView node)
    {
        inspectorView.UpdateSelection(node);
        funcDropdownView.value = null;
        keyParameterView.value = null;
        directionParameterView.value = null;
        selectNode = node;  

        if (inspectorView.SelectNode.node is CompositeNode || inspectorView.SelectNode.node is RootNode)
        {
            classDropdownView.SetEnabled(false);
            funcDropdownView.SetEnabled(false);
        }

        else
        {
            funcDropdownView.SetEnabled(true);
            classDropdownView.SetEnabled(true);
            funcDropdownView.SelectNode = node;
            funcDropdownView.SetDropdownMenu(classDropdownView);
        }
    }

    void OnObjectSelectionChanged(ObjectFieldView field)
    {
        classDropdownView.SetDropdownMenu(field);
    }

    void OnClassSelectionChanged(ClassDropdownFieldView field)
    {
        funcDropdownView.SelectNode = selectNode;
        funcDropdownView.SetDropdownMenu(field);
    }

    void OnFuncSelectionChanged(FuncDropdownFieldView field)
    {
        if (field.value == null)
            return;
        parameters = GetParameters(field.value.ToString());

        GameObject controller = fieldView.value as GameObject;
        if (controller == null)
            return;

        if (selectNode.node is ActionNode action)
            action.SetAction(field.value.ToString(), controller, classDropdownView.value);
        else if (selectNode.node is IfDecoratorNode deco)
            deco.SetCondition(field.value.ToString(), controller, classDropdownView.value);
    }

    void OnDirectionSelectionChanged(DirectionParameterView direction)
    {
        if (funcDropdownView.value == null)
            return;
        GameObject controller = fieldView.value as GameObject;
        if (parameters.Length > 0)
        {
            if (selectNode.node is ActionNode action)
                action.SetActionWithParam(funcDropdownView.value.ToString(), controller, direction.value.ToString(), classDropdownView.value);
        }
    }

    void OnKeySelectionChanged(KeyParameterView key)
    {
        if (funcDropdownView.value == null)
            return;
        GameObject controller = fieldView.value as GameObject;
        if (parameters.Length > 0)
        {
            if (selectNode.node is IfDecoratorNode deco)
                deco.SetConditionWithParam(funcDropdownView.value.ToString(), controller, key.value.ToString(), classDropdownView.value);
        }
    }

    ParameterInfo[] GetParameters(string methodName)
    {
        keyParameterView.SetEnabled(false);
        directionParameterView.SetEnabled(false);

        ParameterInfo[] parameters = null;

        PlayerController controller = GameObject.FindWithTag("Player").GetComponent<PlayerController>();
        methods = controller.GetType().GetDeclaredMethods();

        for (int i = 0; i < methods.Length; i++)
        {
            if (methods[i].Name == methodName)
            {
                parameters = methods[i].GetParameters();
                for (int j = 0; j < parameters.Length; j++)
                {
                    if (parameters[j].ParameterType == typeof(EKey))
                        keyParameterView.SetEnabled(true);
                    if (parameters[j].ParameterType == typeof(PlayerController.EDirection))
                        directionParameterView.SetEnabled(true);
                }
            }
        }

        return parameters;
    }
}
