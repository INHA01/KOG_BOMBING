using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace BAEK
{
    public enum Range
    {
        Attack,
        NoAttack,
        MaxAttack,
        Max,
    }
    public enum ShootPos
    {
        Start,
        End,
        Max,
    }
    public enum BombCursorType
    {
        SectorA,
        SectorB,
        Max,
    }
    public enum InteractUI
    {
        InteractBar,
        Interact,
        InteractBomb,
        Time,
        BombSet,
        BombDefuse,
        Max
    }
    public enum UIKEY
    {
        NONE,
        BattleBoard,
        CharacterChoose,
        Interacting,
        KeyDescription,
        Loading,
        Lobby,
        Login,
        Option,
        Play,
        Result,
        SelectMode,
        Winner,
        Max
    }
    public enum PingCursorType
    {
        Find,
        Help,
        Move,
        Warning,
        Max,
    }
    public enum ProfileCharacterType
    { 
        Elvacia_1,
        Elvacia_2,
        Ned_1,
        Ned_2,
        Ned_3,
        Tau_1,
        Tau_2,
        Uni_1,
        Uni_2,
        Uni_3,
        US,
        Max
    }
}
