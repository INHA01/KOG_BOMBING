using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public interface ISetScoreable<T>
{
    public void Initialize();
    public void SetTitle(StringBuilder title);
    public void SetScore(T type, int score);
    public void ResetScore();
}
