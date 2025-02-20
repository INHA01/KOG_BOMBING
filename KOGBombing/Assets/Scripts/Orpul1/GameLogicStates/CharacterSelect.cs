using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Orpul1;
using Photon.Pun;
using UnityEngine;

public class CharacterSelect : GameProcessLogic
{
    UIPopup _uiScene;
    bool isSelectCharacter = false;
    private void Start()
    {
    }
    public override void EnterState()
    {
        _uiScene = Managers.UI.ShowPopupUI<UIPopup>("CharacterChooseCanvas");
        _uiScene.GetComponent<ChoosePlayer>().Init();
        EventBusSystem.Subscribe(DoneSelectCharacter);
        isSelectCharacter = false;
        logicContext.selectCharacterPath.Clear();
        Debug.Log("Character Select State");
    }
    public override void UpdateState()
    {
        if (isSelectCharacter)
        {
            transitionState((int)EGameState.SPAWNPLAYER);
        }
    }

    public override void ExitState()
    {
        EventBusSystem.Unsubscribe(DoneSelectCharacter);
    }


    private void DoneSelectCharacter()
    {
        Debug.Log("DoneSelectCharacter");
        logicContext.selectCharacterPath.Append(_uiScene.GetComponent<ChoosePlayer>().type.ToString());
        isSelectCharacter = true;
    }
    
}
