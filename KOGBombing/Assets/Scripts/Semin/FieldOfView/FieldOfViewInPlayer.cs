using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using static UnityEngine.Rendering.DebugUI;
using Orpul1;
using Photon.Pun;

namespace Semin
{
	public class FieldOfViewInPlayer : ViewObserver
	{
		[SerializeField] GameObject fovTargetObject;
		List<FieldOfView> fov = new List<FieldOfView>();
		public PhotonView pv;

		private void Start()
		{
			FieldOfView[] fovs = fovTargetObject.GetComponents<FieldOfView>();

			for (int i = 0; i < fovs.Length; i++)
				fov.Add(fovs[i]);

			Attach(true);
		}

		protected override void SetPlayerSight(int isZoom)
		{
			if (!pv.IsMine) return;
			pv.RPC("SetFOVAngle", RpcTarget.AllBuffered, isZoom);
		}

		[PunRPC]
		private void SetFOVAngle(int isZoom)
		{
			for (int i = 0; i < fov.Count; i++)
				fov[i].ExtractView(isZoom);
		}
	}
}
