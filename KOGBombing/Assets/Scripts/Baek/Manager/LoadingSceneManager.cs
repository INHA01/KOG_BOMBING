using System.Collections;
using UnityEngine;

using UnityEngine.SceneManagement;
using UnityEngine.UI;
public class LoadingSceneManager : MonoBehaviour
{
    public static string nextScene;
    [SerializeField] Image loadingCircle;
    private void Start()
    {
        StartCoroutine(LoadScene());
    }
    public static void LoadScene(string sceneName)
    {
        nextScene = sceneName;
        SceneManager.LoadScene("LoadingScene");
    }
    IEnumerator LoadScene()
    {
        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync(nextScene);
        asyncLoad.allowSceneActivation = false;
        float time = Time.time + 1.0f; // 1 seconds term
        while (!asyncLoad.isDone)
        {
            yield return null;
            {
                loadingCircle.fillAmount += Time.deltaTime;
                if(loadingCircle.fillAmount >= 1) loadingCircle.fillAmount = 0;

                if (asyncLoad.progress / 1.0f > 0.7f)
                {
                    if(Time.time > time)
                    {
                        asyncLoad.allowSceneActivation = true;
                        yield break;
                    }
                }
            }
        }

    }
}
