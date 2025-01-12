using Semin;
using System.Reflection;
using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.UIElements;
using Unity.VisualScripting.FullSerializer.Internal;

public class FuncDropdownFieldView : DropdownField
{
    public Action<FuncDropdownFieldView> OnSelected;
    public new class UxmlFactory : UxmlFactory<FuncDropdownFieldView, DropdownField.UxmlTraits> { }
    private MethodInfo[] methods;
    public Func<INode.ENodeState> SelectFunc;
    public NodeView SelectNode;

    public FuncDropdownFieldView()
    {

    }

    public void SetDropdownMenu(ClassDropdownFieldView field)
    {
        choices.Clear();
        if (field != null)
        {
            if (field.SelectType != null)
                methods = field.SelectType.GetDeclaredMethods();    
            Type type = null;
            if (SelectNode.node is ActionNode)
                type = typeof(INode.ENodeState);
            else if (SelectNode.node is IfDecoratorNode)
                type = typeof(bool);
            for (int i = 0; i < methods.Length; i++)
            {
                if (methods[i].IsPublic && methods[i].ReturnType == type)   
                    choices.Add(methods[i].Name);
            }
        }
    }

    public override void SetValueWithoutNotify(string newValue)
    {
        base.SetValueWithoutNotify(newValue);
        if (OnSelected != null)
            OnSelected.Invoke(this);
    }
}
