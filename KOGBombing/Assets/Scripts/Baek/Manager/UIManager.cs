using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Diagnostics;

public class UIManager
{
    public GameObject Root
    {
        get
        {
            GameObject root = GameObject.Find("@UI_Root");
            if (root == null)
                root = new GameObject { name = "@UI_Root" };
            return root;
        }
    }
    int _order = 0;
    public Dictionary<string, UIPopup> _popupDictionary = new Dictionary<string, UIPopup>();
    public List<GameObject> _uiList = new List<GameObject>();
    public T GetPopupUI<T>(string name = null) where T : UIPopup
    {
        if (string.IsNullOrEmpty(name))
            name = typeof(T).Name;
        if (_popupDictionary.ContainsKey(name))
        {
            return _popupDictionary[name] as T;
        }
        return null;
    }

    public T ShowPopupUI<T>(string name = null) where T : UIPopup
    {
        if (string.IsNullOrEmpty(name))
            name = typeof(T).Name;
        GameObject go = null;
        // Exists : 조건에 맞는 요소가 하나라도 있으면 true 반환
        // Find : 조건에 맞는 요소를 찾아서 반환 , 여러개면 첫번째 요소 반환
        if (_uiList.Exists(ui => ui.name == name))
        {
            go = _uiList.Find(ui => ui.name == name);
        }
        else
        {
            go = Managers.Resource.Instantiate($"UIPrefabs/Scene/{name}");
            _uiList.Add(go); 
            go.transform.SetParent(Root.transform);
        }

        T sceneUI = Util.GetOrAddComponent<T>(go);
        sceneUI.Init();

        // ContainsKey : 키가 존재하면 true 반환
        if (!_popupDictionary.ContainsKey(name))
        {
            _popupDictionary.Add(name, sceneUI);
        }
        go.SetActive(true); 

        return sceneUI;
    }
    public void ClosePopupUI(string name = null)
    {
        if (_popupDictionary.Count == 0)
        {
            return;
        }
        if (string.IsNullOrEmpty(name))
        {
            _popupDictionary.Remove(_popupDictionary.Last().Key);
            _uiList[_uiList.Count - 1].SetActive(false);
            //_uiList.Find(ui => ui.name == lastPopup.Key)?.SetActive(false);
        }
        else if(_popupDictionary.ContainsKey(name))
        {
            _popupDictionary.Remove(name);
            _uiList.Find(ui => ui.name == name)?.SetActive(false);
        }

        _order--;
    }
    public void CloseAllPopupUI()
    {
        while (_popupDictionary.Count > 0)
        {
            ClosePopupUI();
        }
    }
    public void DestroyAllPopupUI()
    {
        CloseAllPopupUI();
        for (int i = 0; i < _uiList.Count; i++)
        {
            Managers.Resource.Destroy(_uiList[i]);
        }
        _uiList.Clear();
    }

    public void SetCanvas(GameObject go, bool sort = true)
    {
        Canvas canvas = Util.GetOrAddComponent<Canvas>(go);
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.overrideSorting = true;

        if (sort)
        {
            _order++;
            canvas.sortingOrder = _order;
        }
        else
        {
            canvas.sortingOrder = 0;
        }
    }
}
