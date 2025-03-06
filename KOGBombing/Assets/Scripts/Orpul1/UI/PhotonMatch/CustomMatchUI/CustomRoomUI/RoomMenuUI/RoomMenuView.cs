using UnityEngine;
using UnityEngine.UI;

namespace Orpul1
{
    public enum ERoomMenuButton
    {
        STARTBUTTON,
        QUITBUTTON,
        SWAPREDBUTTON,
        SWAPBLUEBUTTON,
        END,
    }
    public class RoomMenuView : MonoBehaviour
    {
        
        public GameObject background;
        public Button[] menuButtons;
    }
}
