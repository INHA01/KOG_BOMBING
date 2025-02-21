using System;

namespace Orpul1
{
    public interface IState
    {
        public void Initialize(Action<int> transition,LogicContext logicContext);
        public void EnterState();
        public void UpdateState();
        public void ExitState();
    }
}
