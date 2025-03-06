using System;
using System.Text;

public class DisplayPlayerModel
{
    Action updateUI;

    private StringBuilder stbNickname = new StringBuilder();
    private StringBuilder stbLevel = new StringBuilder();

    public StringBuilder PlayerNickname { get { return stbNickname; } }
    public StringBuilder PlayerLevel { get { return stbLevel; } }
    public DisplayPlayerModel(Action updateUI)
    {
        this.updateUI = updateUI;
    }
    public void SetPlayerInfo(StringBuilder nickname, StringBuilder level)
    {
        stbNickname = nickname;
        stbLevel = level;
        updateUI();
    }



}
