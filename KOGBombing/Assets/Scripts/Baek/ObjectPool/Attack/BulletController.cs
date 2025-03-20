using ExitGames.Client.Photon;
using Orpul1;
using Photon.Pun;
using Photon.Realtime;
using Semin;
using System.Collections;
using UnityEngine;
using UnityEngine.Rendering;

public class BulletController : PooledObject
{
    [SerializeField] protected float moveSpeed;
    [HideInInspector] public ETeam eTeamBullet;
     public int playerIndex;
    [SerializeField] protected int damage = 20;

   [SerializeField] protected Rigidbody rb;
    protected float destroyDistance;
    protected float distance;
    public Vector3 direction;
    Collider target;

    [Header("Effect")]
    public GameObject muzzlePrefab;
    public GameObject hitPrefab;
    RaiseEventOptions options = new RaiseEventOptions();
    SendOptions optionsSend;
    public float DestroyDistance { get => destroyDistance; set => destroyDistance = value; }
    public float Damage { get { return damage; } }
    int relaseEventCode = 99;
    private void Awake()
    {
        options.Receivers = ReceiverGroup.All;
        optionsSend.Reliability = true;
        optionsSend.DeliveryMode = DeliveryMode.Reliable;
    }
    private void OnEnable()
    {
        PhotonNetwork.NetworkingClient.EventReceived -= OnRelase;
        PhotonNetwork.NetworkingClient.EventReceived += OnRelase;
    }
    private void OnDisable()
    {
        PhotonNetwork.NetworkingClient.EventReceived -= OnRelase;
    }
    protected virtual void FixedUpdate()
    {
        transform.Translate(direction * moveSpeed * Time.deltaTime, Space.World);
        distance += moveSpeed * Time.deltaTime;
        if (distance > destroyDistance)
        {
            distance = 0;
            Release();
        }
    }

    protected bool IsOtherTeam(IGetTeamTypeable teamType)
    {
        if (teamType.GetTeamType() == eTeamBullet) return false;
        return true;
    }
    protected virtual void OnTriggerEnter(Collider other)
	{
		if (other.CompareTag("IgnoreBullet"))
		{
            if (other.GetComponent<Landmine>() != null) return;
		}
        if (other.CompareTag("Bomb")|| other.CompareTag("Bullet")) return;

        if (other.tag == "Player")
        {
            // >> : �� ����
            IGetTeamTypeable teamType = other.GetComponent<IGetTeamTypeable>();

            if (!other.GetComponent<PlayerData>().pv.IsMine) return;
            if (teamType == null) return;
            if (!IsOtherTeam(teamType)) return;
            // << :
            IDamageAble player = other.transform.GetComponent<IDamageAble>();
            if (player != null)
            {
				player.OnDamaged(damage, playerIndex);
                distance = 0;
				//return;
            }
        }

		HitAndMakeParticle(other);
	}

	public void HitAndMakeParticle(Collider other)
    {
        // >> : HitEffect
		Vector3 contactPoint = other.ClosestPoint(transform.position);
		Quaternion rot = Quaternion.FromToRotation(Vector3.up, other.transform.position - contactPoint);
		Vector3 pos = contactPoint;
		if (hitPrefab != null)
		{
			var hitVFX = Instantiate(hitPrefab, pos, rot);
			var psHit = hitVFX.GetComponent<ParticleSystem>();
			if (psHit != null)
				Destroy(hitVFX, psHit.main.duration);
			else
			{
				var psChild = hitVFX.transform.GetChild(0).GetComponent<ParticleSystem>();
				Destroy(hitVFX, psChild.main.duration);
			}
		}
        PhotonNetwork.RaiseEvent((byte)relaseEventCode, null, options, optionsSend);
		/// << :
		//distance = 0;
		//Release();
    }

    private void OnRelase(EventData punData)
    {
        if (punData.Code != relaseEventCode) return;
        Release();
    }
    public void ShowMuzzle()
    {
        if (muzzlePrefab != null)
        {
            var muzzleVFX = Instantiate(muzzlePrefab, transform.position, Quaternion.identity);
            muzzleVFX.transform.forward = gameObject.transform.forward;
            var psMuzzle = muzzleVFX.GetComponent<ParticleSystem>();
            if (psMuzzle != null)
                Destroy(muzzleVFX, psMuzzle.main.duration);
            else
            {
                var psChild = muzzleVFX.transform.GetChild(0).GetComponent<ParticleSystem>();
                Destroy(muzzleVFX, psChild.main.duration);
            }
        }
	}
}
