using Semin;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UIElements;

public class ClassDropdownFieldView : DropdownField
{
    public Action<ClassDropdownFieldView> OnSelected;
    public new class UxmlFactory : UxmlFactory<ClassDropdownFieldView, DropdownField.UxmlTraits> { }
    MonoBehaviour[] components;
    public Type SelectType;
    public PlayerController playerController;
    public ClassDropdownFieldView()
    {

    }

    internal void SetDropdownMenu(ObjectFieldView field)
    {
        components = field.value.GetComponents<MonoBehaviour>();

        foreach (var component in components)
        {
            Type type = component.GetType();
            choices.Add(type.Name);
        }
    }

    public override void SetValueWithoutNotify(string newValue)
    {
        base.SetValueWithoutNotify(newValue);
        if (components != null)
        {
            for (int i = 0; i < components.Length; i++)
            {
                if (newValue == components[i].GetType().Name)
                {
                    SelectType = components[i].GetType();
                }
            }
        }
        if (OnSelected != null)
            OnSelected.Invoke(this);
    }
}
