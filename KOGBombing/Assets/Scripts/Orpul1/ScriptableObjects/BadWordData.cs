using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using UnityEngine;

namespace Orpul1
{
    [CreateAssetMenu(fileName = "BadWord", menuName = "Datas/BadWord")]

    public class BadWordData : ScriptableObject
    {
        [TextArea(5,100)] public string pattern = "";

        Regex filter;
        public void Reset()
        {
            SetFilter();
        }
        private void SetFilter()
        {
            filter = new Regex(pattern);
        }
        public string FilterMessage(string sentence)
        {
            if (filter == null) SetFilter();
            return filter.Replace(sentence, "*");
        }
    }
}
