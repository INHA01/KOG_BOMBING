using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractPresenter : MonoBehaviour
{
    [SerializeField] InteractView view;
    [SerializeField] InteractModel model;
    private void Start()
    {
        view.interactAblePanel.SetActive(false);
        view.progressPanel.SetActive(false);
    }
}
