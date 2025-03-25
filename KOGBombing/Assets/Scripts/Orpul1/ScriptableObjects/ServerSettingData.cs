using System.Collections;
using System.Collections.Generic;
using Photon.Realtime;
using UnityEngine;

[CreateAssetMenu(fileName = "ServerSetting", menuName = "Datas/ServerSetting")]
public class ServerSettingData : ScriptableObject
{
    public AppSettings appsetting;
}
