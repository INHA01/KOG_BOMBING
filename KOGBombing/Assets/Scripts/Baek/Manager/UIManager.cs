using System.Collections;
using System.Collections.Generic;
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
    public Stack<UIPopup> _popupStack = new Stack<UIPopup>();
    public List<GameObject> _uiList = new List<GameObject>();

    #region ShowSceneUI (Original)
    //public T ShowSceneUI<T>(string name = null) where T : UIScene
    //{
    //    if (string.IsNullOrEmpty(name))
    //        name = typeof(T).Name;
    //    GameObject go = Managers.Resource.Instantiate($"UIPrefabs/Scene/{name}");
    //    T sceneUI = Util.GetOrAddComponent<T>(go);
    //    sceneUI.Init(); // 추가사항 
    //    _sceneStack.Push(sceneUI);

    //    go.transform.SetParent(Root.transform);
    //    return sceneUI;
    //}
    //public void CloseSceneUI()
    //{
    //    if (_sceneStack.Count == 0)
    //    {
    //        return;
    //    }
    //    UIScene sceneUI = _sceneStack.Pop();
    //    Managers.Resource.Destroy(sceneUI.gameObject);
    //    sceneUI = null;
    //    _order--;
    //}
    #endregion

    public T ShowPopupUI<T>(string name = null) where T : UIPopup
    {
        if (string.IsNullOrEmpty(name))
            name = typeof(T).Name;
        GameObject go = null;
        for (int i = 0; i < _uiList.Count; i++)
        {
            if (_uiList[i].name == name) 
            {
                go = _uiList[i]; 
            }
        }
        if (go == null)
        {
            go = Managers.Resource.Instantiate($"UIPrefabs/Scene/{name}");
            _uiList.Add(go); 
            go.transform.SetParent(Root.transform);
        }
        else { go.SetActive(true); }

        T sceneUI = Util.GetOrAddComponent<T>(go);
        sceneUI.Init();
        _popupStack.Push(sceneUI);

        return sceneUI;
    }
    public void ClosePopupUI()
    {
        if (_popupStack.Count == 0)
        {
            return;
        }
        _uiList[_uiList.Count - 1].SetActive(false);
        UIPopup sceneUI = _popupStack.Pop();
        sceneUI = null;
        _order--;
    }
    public void CloseAllPopupUI()
    {
        while (_popupStack.Count > 0)
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
