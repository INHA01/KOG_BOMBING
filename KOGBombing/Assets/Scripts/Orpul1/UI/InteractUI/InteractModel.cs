using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractModel
{
    public float interactInterval;
    Action<float> updateUI;
    public InteractModel(InteractPresenter presenter)
    {
        updateUI = presenter.ProgressInteract;
    }

    public void SetUI()
    {
        updateUI?.Invoke(interactInterval);
    }

}
