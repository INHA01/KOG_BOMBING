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
    Stack<UIScene> _sceneStack = new Stack<UIScene>();
    List<GameObject> _scenes = new List<GameObject>();

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

    public T ShowSceneUI<T>(string name = null) where T : UIScene
    {
        if (string.IsNullOrEmpty(name))
            name = typeof(T).Name;
        GameObject go = null;
        for (int i = 0; i < _scenes.Count; i++)
        {
            if (_scenes[i].name == name) { go = _scenes[i]; }
        }
        if (go == null)
        {
            go = Managers.Resource.Instantiate($"UIPrefabs/Scene/{name}");
            _scenes.Add(go); 
            go.transform.SetParent(Root.transform);
        }
        else { go.SetActive(true); }

        T sceneUI = Util.GetOrAddComponent<T>(go);
        sceneUI.Init();
        _sceneStack.Push(sceneUI);

        return sceneUI;
    }
    public void CloseSceneUI()
    {
        if (_sceneStack.Count == 0)
        {
            return;
        }
        _scenes[_scenes.Count - 1].SetActive(false);
        UIScene sceneUI = _sceneStack.Pop();
        sceneUI = null;
        _order--;
    }
    public void CloseAllSceneUI()
    {
        while (_sceneStack.Count > 0)
        {
            CloseSceneUI();
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
