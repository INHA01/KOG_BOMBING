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
    public T GetPopupUI<T>(string name = null) //where T : UIPopup
    {
        if (string.IsNullOrEmpty(name))
            name = typeof(T).Name;
        if (_popupDictionary.ContainsKey(name))
        {
            return _popupDictionary[name].GetComponent<T>();
        }
        else
        {
            UIPopup popup = ShowPopupUI<UIPopup>(name);
            if(popup != null)
                return popup.GetComponent<T>();
        }
        return default;
    }

    public T ShowPopupUI<T>(string name = null) where T : UIPopup
    {
        if (string.IsNullOrEmpty(name))
            name = typeof(T).Name;
        GameObject go = null;
        bool isExist = false;
        // ContainsKey : 키가 존재하면 true 반환
        // TryGetValue : 키가 존재하면 true 반환하고 out으로 값을 반환
        if (!_popupDictionary.ContainsKey(name))
        {
            go = LocalManagers.Resource.Instantiate($"UIPrefabs/Scene/{name}");
            go.transform.SetParent(Root.transform);
            isExist = true;
        }
        else
        {
            go = _popupDictionary[name].gameObject;
        }
        go.SetActive(true); 
        T sceneUI = Util.GetOrAddComponent<T>(go);
        // 검색한 UI가 없을 경우
        if (sceneUI == null)
        {
            Debug.LogError("UIPopup is Null");
            return null;
        }
        sceneUI.Init();
        if(isExist)
            _popupDictionary.Add(name, sceneUI);

        return sceneUI;
    }
    public void ClosePopupUI(string name = null)
    {
        if (_popupDictionary.Count == 0) return;
        GameObject go = null;
        if (string.IsNullOrEmpty(name))
        {
            go = _popupDictionary.Last().Value.gameObject;
        }
        else if(_popupDictionary.ContainsKey(name))
        {
            go = _popupDictionary[name].gameObject;
        }
        if(go != null)
        {
            _order--;
            go.SetActive(false);
        }
    }
    public void CloseAllPopupUI()
    {
        for(int i = 0; i < _popupDictionary.Count; i++)
        {
            ClosePopupUI();
        }
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
