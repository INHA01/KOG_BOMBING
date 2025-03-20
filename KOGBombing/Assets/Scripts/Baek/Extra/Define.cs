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
        CrossHair,
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
    public enum SpriteType
    {
        Background,
        SkillButton,
        Common,
        Story,
        Max
    }
    public enum VideoType
    {
        Skill,
        Attack,
        Defense,
        Max
    }
    public enum EmoticonType
    {
        Common_1,
        Common_2,
        Ned_1,
        Tau_1,
        US_1,
        Elvacia_1,
        Uni_1,
        Uni_2,
        Max
    }
    public enum PingPos
    {
        Top,
        Bottom,
        Right,
        Left,
        Max
    }
}
