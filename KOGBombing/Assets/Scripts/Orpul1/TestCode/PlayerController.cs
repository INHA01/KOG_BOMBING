using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

namespace Orpul1.Test
{
    public class PlayerController : MonoBehaviour,IInteractAble
    {
        [SerializeField]
        float speed = 5f;
        public void Interact()
        {

        }
        void Start()
        {

        }

        void Update()
        {
            float hor = Input.GetAxis("Horizontal");
            float ver = Input.GetAxis("Vertical");
            transform.Translate(new Vector3(hor, 0, ver) * speed * Time.deltaTime);

        }

        private void OnTriggerStay(Collider other)
        {
            IInteractAble interact = other.GetComponent<IInteractAble>();
            if(interact != null&&Input.GetKeyDown(KeyCode.F))
            {
                interact.Interact();
            }
        }
    }
}
