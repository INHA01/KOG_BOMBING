using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneLoadManager 
{
    public string currentScene;
    Loading loading;
    public void Init()
    { 
        currentScene = SceneManager.GetActiveScene().name;
        SceneManager.LoadScene("UIScene", LoadSceneMode.Additive);
    }
    public void LoadScene(string sceneName)
    {
        SceneManager.UnloadSceneAsync(currentScene);
        currentScene = sceneName;
        loading = LocalManagers.UI.ShowPopupUI<Loading>("LoadingCanvas");
        loading.LoadScene(sceneName);
    }
}
