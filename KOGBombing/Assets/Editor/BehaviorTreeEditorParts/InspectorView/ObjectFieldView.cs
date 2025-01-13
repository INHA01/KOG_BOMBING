using Semin;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.UIElements;
using UnityEngine;
using UnityEngine.UIElements;

public class ObjectFieldView : ObjectField
{
    public Action<ObjectFieldView> OnChanged;
    public new class UxmlFactory : UxmlFactory<ObjectFieldView, ObjectField.UxmlTraits> { }

    public ObjectFieldView()
    {
        this.value = GameObject.FindWithTag("Player");
    }

    protected override void UpdateMixedValueContent()
    {
        Debug.Log("Update Mixed Value COntent");
    }

    public override void SetValueWithoutNotify(UnityEngine.Object newValue)
    {
        base.SetValueWithoutNotify(newValue);
        if (OnChanged != null)
            OnChanged.Invoke(this);
    }
}
