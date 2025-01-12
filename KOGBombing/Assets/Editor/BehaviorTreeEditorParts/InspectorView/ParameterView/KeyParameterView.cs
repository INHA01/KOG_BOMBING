using Semin;
using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting.FullSerializer.Internal;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;

public class KeyParameterView : DropdownField
{
    public Action<KeyParameterView> OnSelected;
    public new class UxmlFactory : UxmlFactory<KeyParameterView, DropdownField.UxmlTraits> { }
    public EKey SelectKey;

    public KeyParameterView()
    {
        var enumValues = System.Enum.GetNames(typeof(EKey));

        for (int i = 0; i < enumValues.Length; i++)
            choices.Add(enumValues[i].ToString());
    }

    public override void SetValueWithoutNotify(string newValue)
    {
        base.SetValueWithoutNotify(newValue);

        var enumValues = System.Enum.GetNames(typeof(EKey));

        for (int i = 0; i < enumValues.Length; i++)
        {
            if (newValue == enumValues[i].ToString())
            {
                Enum.TryParse<EKey>(enumValues[i], out SelectKey);
                Debug.Log(SelectKey.ToString());
            }
        }
        if (OnSelected != null)
            OnSelected.Invoke(this);
    }
}
