using Semin;
using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UIElements;

public class DirectionParameterView : DropdownField
{
    public Action<DirectionParameterView> OnSelected;
    public new class UxmlFactory : UxmlFactory<DirectionParameterView, DropdownField.UxmlTraits> { }
    public EKey SelectKey;

    public DirectionParameterView()
    {
        var enumValues = System.Enum.GetNames(typeof(PlayerController.EDirection));

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
            }
        }
        if (OnSelected != null)
            OnSelected.Invoke(this);
    }
}
