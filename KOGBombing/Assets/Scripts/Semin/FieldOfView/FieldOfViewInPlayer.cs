using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using static UnityEngine.Rendering.DebugUI;
using Orpul1;
using Photon.Pun;
using UnityEngine.UIElements;

namespace Semin
{
	public class FieldOfViewInPlayer : ViewObserver
	{
		[SerializeField] GameObject fovTargetObject;
		List<FieldOfView> fov = new List<FieldOfView>();
		public PhotonView pv;

		private void Start()
		{
			pv = GetComponent<PhotonView>();
			FieldOfView[] fovs = fovTargetObject.GetComponents<FieldOfView>();

			for (int i = 0; i < fovs.Length; i++)
				fov.Add(fovs[i]);

			Attach(true);
		}
		private void FixedUpdate()
		{
			if (pv.IsMine)
				pv.RPC("SetMyMesh", RpcTarget.AllBuffered);
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

		[PunRPC]
		private void SetMyMesh()
		{
			for (int i = 0; i < fov.Count; i++)
			{
				fov[i].DrawFieldOfView();
				fov[i].SetSyncMesh();
			}
		}

		//public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info)
		//{
		//	Debug.Log($"isWriting: {stream.IsWriting}");
		//	if (stream.IsWriting)
		//	{
		//		Debug.Log("OnPhoton");
		//		for (int i = 0; i < fov.Count; i++)
		//		{
		//			Mesh mesh = fov[i].GetComponent<FieldOfView>().viewMesh;
		//			stream.SendNext((int)mesh.vertices.Length); // 배열 길이 전송
		//			for (int j = 0; j < mesh.vertices.Length; j++)
		//			{
		//				stream.SendNext(mesh.vertices[j]); // 각 Vector3 요소 전송
		//			}
		//			stream.SendNext((int)mesh.triangles.Length); // 배열 길이 전송
		//			for (int j = 0; j < mesh.triangles.Length; j++)
		//			{
		//				stream.SendNext(mesh.triangles[j]);
		//			}
		//		}
		//	}
		//	else
		//	{
		//		for (int i = 0; i < fov.Count; i++)
		//		{
		//			Mesh mesh = fov[i].GetComponent<FieldOfView>().viewMesh;
		//			int length = (int)stream.ReceiveNext(); // 배열 길이 수신
		//			Vector3[] tempVertices = new Vector3[length];
		//			Debug.Log(length);
		//			for (int j = 0; j < length; j++)
		//			{
		//				tempVertices[j] = (Vector3)stream.ReceiveNext();
		//			}
		//			mesh.vertices = tempVertices;

		//			length = (int)stream.ReceiveNext();
		//			int[] tempTriangles = new int[length];
		//			for (int j = 0; j < length; j++)
		//			{
		//				tempTriangles[j] = (int)stream.ReceiveNext();
		//			}
		//			mesh.triangles = tempTriangles;
		//			mesh.RecalculateNormals();
		//		}
		//	}
		//}
	}
}
