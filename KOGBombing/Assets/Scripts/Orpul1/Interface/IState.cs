using System;

public interface IState
{
    public void Initialize(Action<int> transition);
    public void EnterState();
    public void UpdateState();
    public void ExitState();
}
