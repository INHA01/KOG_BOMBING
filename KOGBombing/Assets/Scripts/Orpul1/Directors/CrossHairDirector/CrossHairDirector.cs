using System.Collections;
using System.Collections.Generic;
using BAEK;
using UnityEngine;

namespace Orpul1
{
    public class CrossHairDirector : MonoBehaviour
    {
        private void Start()
        {
            Managers.UI.ShowPopupUI<CrossHariUpdater>(UIKEY.CrossHair);
        }
    }
}