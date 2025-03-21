using UnityEngine;

namespace Michsky.UI.Shift
{
    public class FriendsPanelManager : MonoBehaviour
    {
        Animator windowAnimator;
        public bool isOn = true;
        CanvasGroup canvasGroup;

        void Start()
        {
            windowAnimator = gameObject.GetComponent<Animator>();
            canvasGroup = GetComponent<CanvasGroup>();
        }

        public void AnimateWindow()
        {
            if (isOn == false)
            {
                windowAnimator.CrossFade("Window In", 0.1f);
                isOn = true;
            }

            else
            {
                windowAnimator.CrossFade("Window Out", 0.1f);
                isOn = false;
            }
        }

        public void WindowIn()
        {
            if (isOn == false)
            {
                windowAnimator.CrossFade("Window In", 0.1f);
                isOn = true;
            }
        }

        public void WindowOut()
        {
            if (isOn == true)
            {
                windowAnimator.CrossFade("Window Out", 0.1f);
                isOn = false;
            }
		}

		public void WindowOutWithAlpha()
		{
			if (isOn == true)
			{
                if (canvasGroup.alpha <= 0) return;
				
                windowAnimator.CrossFade("Window Out", 0.1f);
				isOn = false;
			}
		}
	}
}