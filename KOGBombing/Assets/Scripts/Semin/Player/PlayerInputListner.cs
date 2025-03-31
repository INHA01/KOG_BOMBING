using System.Collections;
using System.Collections.Generic;
using BAEK;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerInputListner : Subject
{
    [SerializeField] PlayerBlackBoard blackBoard;
    [SerializeField] PlayerData playerData;
    private void Start()
    {
        for (int i = 0; i < (int)EKey.MAX; i++)
            blackBoard.inputs.Add((EKey)i, false);
    }
    public bool CheckInput(EKey key)
    {
        return blackBoard.inputs[key];
    }
    public void OnCanBehavior(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        blackBoard.inputs[EKey.ESC] = !blackBoard.inputs[EKey.ESC];
        if (blackBoard.inputs[EKey.ESC])
        {
            blackBoard._uiScene = Managers.UI.ShowPopupUI<Option>(BAEK.UIKEY.Option);
            if (blackBoard._uiScene.GetComponent<Option>().playerBlackBoard == null)
            {
                blackBoard._uiScene.GetComponent<Option>().playerBlackBoard = blackBoard;
            }
        }
        else
            Managers.UI.ClosePopupUI(BAEK.UIKEY.Option);
    }

    public void OnAttack(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        blackBoard.inputs[EKey.LMOUSEBUTTON] = value.isPressed;
    }
    bool CheckMouseOutScreen(Vector2 mousePos)
    {
        return (mousePos.x >= 0 && mousePos.x <= Screen.width && mousePos.y >= 0 && mousePos.y <= Screen.height);
    }
    public void OnRotate(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        if (!CheckMouseOutScreen(value.Get<Vector2>())) return;
        blackBoard.mousePos = value.Get<Vector2>();
    }

    public void OnMove(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        Vector2 inputVector = value.Get<Vector2>();
        blackBoard.speedValue.x = inputVector.x;
        blackBoard.speedValue.y = inputVector.y;
        inputVector.x = ConvertToThreeValues(value.Get<Vector2>().normalized.x);
        inputVector.y = ConvertToThreeValues(value.Get<Vector2>().normalized.y);

        switch (inputVector.x)
        {
            case -1:
                blackBoard.inputs[EKey.A] = true;
                break;
            case 0:
                blackBoard.inputs[EKey.A] = false;
                blackBoard.inputs[EKey.D] = false;
                break;
            case 1:
                blackBoard.inputs[EKey.D] = true;
                break;
        }

        switch (inputVector.y)
        {
            case -1:
                blackBoard.inputs[EKey.S] = true;
                break;
            case 0:
                blackBoard.inputs[EKey.W] = false;
                blackBoard.inputs[EKey.S] = false;
                break;
            case 1:
                blackBoard.inputs[EKey.W] = true;
                break;
        }
    }
    public int ConvertToThreeValues(float value)
    {
        if (value > 0)
            return 1;
        else if (value < 0)
            return -1;
        else
            return 0;
    }
    public void OnInteract(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        blackBoard.inputs[EKey.F] = value.isPressed;
    }
    public void OnSlowMove(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        blackBoard.inputs[EKey.LEFTSHIFT] = value.isPressed;
        int pressed = value.isPressed ? 1 : 0;
        Notify(pressed);
        if (pressed == 1)
            blackBoard.speedDebuff.slowMoveValue = 0.5f;
        else blackBoard.speedDebuff.slowMoveValue = 1f;
    }
    public void OnOpenBattleboard(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        if (value.isPressed)
            Managers.UI.ShowPopupUI<BattleBoardUpdater>(BAEK.UIKEY.BattleBoard);
        else
            Managers.UI.ClosePopupUI(BAEK.UIKEY.BattleBoard);
    }
    public void OnOpenKeyDescription(InputValue value)
    {
        if (!playerData.pv.IsMine) return;
        if (value.isPressed)
            Managers.UI.ShowPopupUI<KeyDescription>(BAEK.UIKEY.KeyDescription).LoadImg(blackBoard.playerStatus.CharacterType);
        else
            Managers.UI.ClosePopupUI(BAEK.UIKEY.KeyDescription);
    }
}
