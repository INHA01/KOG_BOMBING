using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChooseObserverComposition : MonoBehaviour
{
    [Header("Subject")]
    [SerializeField] private ChoosePlayer _playerSubject;

    [Header("Observer")]
    [SerializeField] private List<GameObject> _observersPrefab = new List<GameObject>();
    public void Awake()
    {
        if (_playerSubject == null) return;

        foreach (GameObject observerPrefab in _observersPrefab)
        {
            if (observerPrefab == null) continue;

            GameObject go = Instantiate(observerPrefab, this.transform);

            if (go.TryGetComponent(out IObserver observer))
            {
                _playerSubject.AddObserver(observer);
            }

            if (go.TryGetComponent(out IObserverParam<int> observerParam))
            {
                _playerSubject.AddObserver(observerParam);
            }
        }
    }
    private void Start()
    {
        // 생명주기상 Awake로 모든 연결이 끝난 후 초기화 시작
        _playerSubject.Init();
    }
}
