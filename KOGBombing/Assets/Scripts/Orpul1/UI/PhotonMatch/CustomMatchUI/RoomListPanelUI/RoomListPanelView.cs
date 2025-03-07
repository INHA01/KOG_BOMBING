using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public enum ERoomListPanel
{
    CREATEPANEL,
    ROOMLIST,
    BACKGROUND,
    END,
}
public class RoomListPanelView : MonoBehaviour
{
    public GameObject[] panels;
    public Button btnSelectMode;
}