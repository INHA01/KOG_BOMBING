using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Orpul1
{
    public class RandomMatchPresenter : MonoBehaviour
    {
        [SerializeField]
        RandomMatchView view;
        RandomMatchModel model = new RandomMatchModel();
        bool isMatching = false;
        private void Start()
        {
            view.btnMatch.interactable = false;
            view.tmpMatch.text = model.MatchText.ToString();
        }
        public void OnRandomMatching()
        {
            isMatching = !isMatching;

            if (isMatching)
                view.tmpMatch.text = model.MatchingText.ToString();
            else
                view.tmpMatch.text = model.MatchText.ToString();
        }
    }
}