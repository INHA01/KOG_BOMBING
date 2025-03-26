using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using Photon;
using Photon.Pun;
using Semin;

public class SyncFieldOfView : MonoBehaviourPun, IPunObservable
{
	[SerializeField] PhotonView pv;

	public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info)
	{
		//Debug.Log("포톤 FOV");
		//if (stream.IsWriting)
		//{
		//	Debug.Log("포톤 IsWriting");
		//	stream.SendNext((int)meshFilter.mesh.vertices.Length); // 배열 길이 전송
		//	for (int j = 0; j < meshFilter.mesh.vertices.Length; j++)
		//	{
		//		stream.SendNext(meshFilter.mesh.vertices[j]); // 각 Vector3 요소 전송
		//	}
		//	stream.SendNext(meshFilter.mesh.triangles.Length); // 배열 길이 전송
		//	for (int j = 0; j < meshFilter.mesh.triangles.Length; j++)
		//	{
		//		stream.SendNext(meshFilter.mesh.triangles[j]);
		//	}
		//}
		//else if (stream.IsReading)
		//{
		//	Debug.Log("포톤 IsReading");
		//	int length = (int)stream.ReceiveNext();
		//	Vector3[] tempVertices = new Vector3[length];
		//	Debug.Log(length);
		//	for (int j = 0; j < length; j++)
		//	{
		//		tempVertices[j] = (Vector3)stream.ReceiveNext();
		//	}
		//	meshFilter.mesh.vertices = tempVertices;

		//	length = (int)stream.ReceiveNext();
		//	int[] tempTriangles = new int[length];
		//	for (int j = 0; j < length; j++)
		//	{
		//		tempTriangles[j] = (int)stream.ReceiveNext();
		//	}
		//	meshFilter.mesh.triangles = tempTriangles;
		//	meshFilter.mesh.RecalculateNormals();
		//}

		if (stream.IsWriting)
		{
			stream.SendNext(transform.rotation);
		}
		else if (stream.IsReading)
		{
			transform.rotation = (Quaternion)stream.ReceiveNext();
		}
	}
}
