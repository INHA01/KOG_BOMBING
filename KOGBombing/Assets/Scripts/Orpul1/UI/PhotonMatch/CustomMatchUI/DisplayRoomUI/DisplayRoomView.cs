using System.Collections;
using TMPro;
using UnityEngine;

namespace Orpul1
{
    public enum ERoomUI
    {
        SEVERNAME,
        PLAYERCOUNT,
        END,
    }
    public class DisplayRoomView : MonoBehaviour
    {
        public TextMeshProUGUI[] roomUIs;
    }
}