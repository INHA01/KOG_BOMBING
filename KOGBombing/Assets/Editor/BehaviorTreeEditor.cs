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

        fieldView.SetEnabled(false);
        funcDropdownView.SetEnabled(false);
        classDropdownView.SetEnabled(false);
        keyParameterView.SetEnabled(false);
        directionParameterView.SetEnabled(false);
    }

	private void OnSelectionChange()
	{
		SCBehaviorTree tree = Selection.activeObject as SCBehaviorTree;

        if (tree)
            treeView.PopulateView(tree);
	}

    void OnNodeSelectionChanged(NodeView node)
    {
        inspectorView.UpdateSelection(node);
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
        parameters = GetParameters(field.value.ToString());

        PlayerController controller = fieldView.value.GetComponent<PlayerController>();
        if (controller == null)
            return;

        if (selectNode.node is ActionNode action)
        {
            action.SetAction(field.value.ToString(), controller);
        }
    }

    void OnDirectionSelectionChanged(DirectionParameterView direction)
    {
        PlayerController controller = fieldView.value.GetComponent<PlayerController>();
        if (parameters.Length > 0)
        {
            if (selectNode.node is ActionNode action)
            {
                action.SetActionWithParam(funcDropdownView.value.ToString(), controller, typeof(PlayerController.EDirection), direction.value.ToString());
            }
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
