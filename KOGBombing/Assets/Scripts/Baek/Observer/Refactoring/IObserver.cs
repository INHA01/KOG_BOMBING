
public interface IObserver 
{
    void OnNotify();
}

public interface IObserverParam<T>
{
    void OnNotify(T data);
}