using Photon.Pun;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomMatchPresenter : MonoBehaviour
{
    [SerializeField]
    RandomMatchView view;
    RandomMatchModel model = new RandomMatchModel();
    bool isMatching = false;
    private void Start()
    {
        view.btnMatch.interactable = false;
        view.tmpMatch.text = model.matchText.ToString();
    }
    public void SetEnableMatchButton()
    {
        view.btnMatch.interactable = true;
    }
    public void OnRandomMatching()
    {
        isMatching = !isMatching;

        if (isMatching) 
            view.tmpMatch.text = model.matchingText.ToString();
        else
            view.tmpMatch.text = model.matchText.ToString();
    }
}
