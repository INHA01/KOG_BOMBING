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
    Action<StringBuilder> setPlayerCharacter;
    StringBuilder characterPath = new StringBuilder();
    private void Start()
    {
        setPlayerCharacter = GetComponent<PlayerSpawner>().SetPlayerCharacter;
    }
    public override void EnterState()
    {
        _uiScene = Managers.UI.ShowPopupUI<UIPopup>("CharacterChooseCanvas");
        EventBusSystem.Subscribe(DoneSelectCharacter);
        isSelectCharacter = false;
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
        characterPath.Append(_uiScene.GetComponent<ChoosePlayer>().type.ToString());
        setPlayerCharacter(characterPath);
        isSelectCharacter = true;
    }
    
}
