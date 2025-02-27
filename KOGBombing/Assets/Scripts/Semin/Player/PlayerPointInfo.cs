using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public class PlayerPointInfo
{
    private StringBuilder nickname = new StringBuilder();
    private int killPoint;
    private int deathPoint;
    private int asistPoint;
    private int missionPoint;
    public int KillPoint { get { return killPoint; } }
    public int DeathPoint { get {return deathPoint; } }
    public int AsistPoint { get {return asistPoint; } }
    public int MissionPoint { get { return missionPoint; } }
    public void SetKillPoint(int point)
    {
        this.killPoint = point; 
    }
    public void SetDeathPoint(int point)
    {
        this.deathPoint = point;
    }
    public void SetAsistePoint(int point)
    {
        this.asistPoint = point;
    }
    public void SetMissionPoint(int point)
    {
        this.missionPoint = point;
    }
}
