using System.Collections;
using System.Collections.Generic;
using Orpul1;
using UnityEngine;

public class EventUIController
{
    TeamUIController teamUIController;
    public EventUIController(TeamUIController teamUIController)
    {
        this.teamUIController = teamUIController;
    }
    public void ShowEventUI(EGameEvent eventType)
    {
        // >> TODO : 매개변수 값에 따라 UI 생성
    }
}
