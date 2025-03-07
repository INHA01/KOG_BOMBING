using System;
using System.Text;

public class DisplayPlayerModel
{
    Action updateUI;
    private StringBuilder[] stbPlayerInfos = new StringBuilder[2];
    public StringBuilder[] PlayerInfos { get { return stbPlayerInfos; } } 
    public DisplayPlayerModel(Action updateUI)
    {
        this.updateUI = updateUI;
    }
    public void SetPlayerInfo(StringBuilder nickname, StringBuilder level)
    {
        stbPlayerInfos[(int)EPlayerTextUI.NICKNAME] = nickname;
        stbPlayerInfos[(int)EPlayerTextUI.LEVEL] = level;
        updateUI();
    }
}
