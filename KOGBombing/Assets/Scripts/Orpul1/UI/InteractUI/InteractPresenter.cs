using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using static UnityEngine.Rendering.DebugUI;

public class InteractPresenter : MonoBehaviour
{
    InteractModel model;

    [SerializeField] GameObject interactUI;
    [SerializeField] GameObject interactAblePanel;
    [SerializeField] GameObject progressPanel;
    [SerializeField] Image imgProgress;

    private void Awake()
    {
        model = new InteractModel(this);
        interactAblePanel.SetActive(false);
        progressPanel.SetActive(false);
        interactUI.SetActive(false);
    }
    public void ActivePanel()
    {
        interactUI.SetActive(true);
        interactAblePanel.SetActive(true);
        progressPanel.SetActive(false);
    }
    public void DeactivePanel()
    {
        interactAblePanel.SetActive(false);
        progressPanel.SetActive(false);
        interactUI.SetActive(false);
    }
    public void ProgressInteract(float value)
    {
        interactAblePanel.SetActive(false);
        progressPanel.SetActive(true);
        imgProgress.fillAmount = value / 3;
    }
    public void AbortInteract()
    {
        interactAblePanel.SetActive(true);
        progressPanel.SetActive(false);
        imgProgress.fillAmount = 0;
    }
    public void SetValue(float value)
    {
        model.interactInterval = value;
        model.SetUI();
    }

}
