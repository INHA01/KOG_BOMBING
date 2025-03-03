using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public enum EDoorState
{
    OPEN,
    CLOSE
}
public class DoorUIPresenter : MonoBehaviour,IActiveable
{
    [SerializeField] DoorUIModel model;
    [SerializeField] DoorUIView view;
    [SerializeField] string[] doorStateText;
   
    private void Awake()
    {
        model.SetUpdateUI(UpdateUI);
        view.alertPanel.SetActive(false);
    }

    private void AlertDoorOpen()
    {
        model.AlertDoorOpen();
    }
    public void UpdateUI(EDoorState state, bool active)
    {
        view.stateAlertText.text = doorStateText[(int)state];
        view.alertPanel.SetActive(active);
    }

    public void Active()
    {
        AlertDoorOpen();
    }
}
