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
    IHalfRoundUISetable halfRound;
    ERoundState roundState;
    private void Start()
    {
        UIPopup _uiPopup = Managers.UI.ShowPopupUI<UIPopup>("BattleBoardCanvas");
        Managers.UI.ClosePopupUI("BattleBoardCanvas");
        if (_uiPopup != null)
        {
            halfRound = _uiPopup.GetComponent<BattleBoardUpdater>();
        }
        roundState = ERoundState.FIRSTHALF;
    }
    public override void EnterState()
    {
        halfRound.SetHalfRound(roundState);
        _uiScene = Managers.UI.ShowPopupUI<UIPopup>("CharacterChooseCanvas");
        _uiScene.GetComponent<ChoosePlayer>().Init();
        EventBusSystem.Subscribe(EndSelectCharacter);
        isSelectCharacter = false;
        gameData.selectCharacterPath.Clear();
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
        roundState = ERoundState.SECONDHALF;
        EventBusSystem.Unsubscribe(EndSelectCharacter);
    }


    private void EndSelectCharacter()
    {
        Debug.Log("DoneSelectCharacter");
        gameData.selectCharacterPath.Append(_uiScene.GetComponent<ChoosePlayer>().type.ToString());
        isSelectCharacter = true;
    }
    
}
