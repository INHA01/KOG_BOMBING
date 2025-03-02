using System.Collections;
using ExitGames.Client.Photon;
using Photon.Pun;
using Photon.Realtime;
using UnityEngine;
using PhotonHashtable = ExitGames.Client.Photon.Hashtable;

namespace Orpul1
{
    public enum EInteractState
    {
        WAIT,
        INTERACTING,
        DONE,
    }
    public class InteractSubject : MonoBehaviour, IInteractAble,IPunObservable
    {
        [SerializeField]
        PhotonView pv;
        Coroutine coroutine;
        [SerializeField]
        float interactEventTime = 0;
        [SerializeField]
        bool isDoneInteract = false;
        [SerializeField]

        private void Awake()
        {
            pv = GetComponent<PhotonView>();
        }
        public bool ProcessInteract(PhotonView pView)
        {
            EInteractState state = (EInteractState)pv.Owner.CustomProperties[(int)EPropertyType.STATE];
            if (state == EInteractState.DONE || state == EInteractState.INTERACTING) 
            {
                return false;
            }
            if (coroutine == null)
            {
                Debug.Log("상호작용 시작");
                pv.Owner.SetCustomProperties(new PhotonHashtable { { (int)EPropertyType.STATE, EInteractState.INTERACTING} });

                coroutine = StartCoroutine(CoInteract());
            }
            return true;
        }
        public void AbortInteract()
        {
            EInteractState state = (EInteractState)pv.Owner.CustomProperties[(int)EPropertyType.STATE];
            Debug.Log($"abort state : {state}");
            if (state == EInteractState.DONE)
            {
                return;
            }
            if (coroutine != null)
            {
                Debug.Log("상호작용 중단!");
                StopCoroutine(coroutine);
                pv.Owner.SetCustomProperties(new PhotonHashtable { { (int)EPropertyType.STATE, EInteractState.WAIT } });
                coroutine = null;
            }
        }
       
        IEnumerator CoInteract()
        {
            float time = Time.time + interactEventTime;
            while (Time.time < time) 
            {
                Debug.Log("상호작용 중!");
                yield return null;
            }
            Debug.Log("상호작용 완료 이벤트!");
            coroutine = null;
            isDoneInteract = true;
            pv.Owner.SetCustomProperties(new PhotonHashtable { { (int)EPropertyType.STATE, EInteractState.DONE } });
        }

        public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info)
        {
            if(stream.IsWriting)
            {
                stream.SendNext(isDoneInteract);
            }
            else if(stream.IsReading)
            {
                isDoneInteract = (bool)stream.ReceiveNext();
            }
        }
    }
}
