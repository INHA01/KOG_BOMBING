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
        Managers.UI.DestroyAllPopupUI();
        nextScene = sceneName;
        SceneManager.LoadScene("LoadingScene");
    }
    IEnumerator LoadScene()
    {
        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync(nextScene);
        asyncLoad.allowSceneActivation = false;
        float time = Time.time + 1.0f; // 1 seconds term

        float elapsedTime = 0f;
        float finishTime = 3f;
        float k = 5f;

        while (!asyncLoad.isDone)
        {
            yield return null;
            {
                // 지수 함수로 fillAmount 계산
                float t = elapsedTime / finishTime;
                loadingCircle.fillAmount = 1 - Mathf.Exp(-k * t);
                elapsedTime += Time.deltaTime;

                if (loadingCircle.fillAmount >= 0.99f)
                {
                    if (asyncLoad.progress / 1.0f > 0.7f)
                    {
                        if (Time.time > time)
                        {
                            asyncLoad.allowSceneActivation = true;
                            yield break;
                        }
                    }
                    loadingCircle.fillAmount = 0;
                    elapsedTime = 0f;
                }
            }
        }

    }
}
