using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Semin;
using UnityEngine;

public class CharacterSelect : GameProcessLogic
{
    [SerializeField] AudioListener audioListener;
    UIPopup _choosePlayerUI;
    bool isSelectCharacter = false;
    IHalfRoundUISetable halfRound;
    ERoundState roundState;
    private void Start()
    {
        BattleBoardUpdater _uiPopup = Managers.UI.ShowPopupUI<BattleBoardUpdater>(BAEK.UIKEY.BattleBoard);
        Managers.UI.ClosePopupUI(BAEK.UIKEY.BattleBoard);
        if (_uiPopup != null)
        {
            halfRound = _uiPopup;
        }
        roundState = ERoundState.FIRSTHALF;
    }
    public override void EnterState()
    {
        halfRound.SetHalfRound(roundState);
        _choosePlayerUI = Managers.UI.ShowPopupUI<UIPopup>(BAEK.UIKEY.CharacterChoose);
        EventBusSystem.Subscribe(EndSelectCharacter);
        _choosePlayerUI.GetComponent<PhotonChoosePlayer>().Init();
        isSelectCharacter = false;
        gameData.selectCharacterPath.Clear();
        Debug.Log("Character Select State");
        audioListener.enabled = true;
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
        audioListener.enabled = false;
    }


    private void EndSelectCharacter()
    {
        Debug.Log("DoneSelectCharacter");
        CharacterType characterType = _choosePlayerUI.GetComponent<ChoosePlayer>().type;
        gameData.selectCharacterPath.Append(characterType.ToString());
        
        isSelectCharacter = true;
    }
}
