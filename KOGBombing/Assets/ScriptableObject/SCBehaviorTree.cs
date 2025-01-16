using Semin;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting.Antlr3.Runtime.Tree;
using UnityEngine;
using UnityEngine.UIElements;

[CreateAssetMenu()]
public class SCBehaviorTree : ScriptableObject
{
	public Node rootNode;
	[HideInInspector] public INode.ENodeState state = INode.ENodeState.Running;
	public List<Node> nodes = new List<Node>();
	GameObject target;

	public void SetTarget(GameObject target)
	{
		this.target = target;
		rootNode.SetTarget(target);
		rootNode.Start();
		//rootNode.SetTarget(target);
	}

	public INode.ENodeState Operate()
	{
		return rootNode.Evaluate();
	}

	public Node CreateNode(System.Type type)
	{
		Node node = null;
        if (typeof(Node).IsAssignableFrom(type))
        {
            node = ScriptableObject.CreateInstance(type) as Node;
            if (node != null)
            {
                node.name = type.Name;
				nodes.Add(node);
            }
            else
            {
                Debug.LogError("Node 인스턴스 생성 실패");
            }
        }
		return node;
	}

	public void DeleteNode(Node node)
	{
        nodes.Remove(node);
	}

	public void AddChild(Node parent, Node child)
	{
		DecoratorNode decorator = parent as DecoratorNode; 
		if (decorator)
		{
			decorator.SetChild(child);
			return;
		}

		RootNode root = parent as RootNode;
		if (root)
		{
			root.child = child;
			return;
		}

		CompositeNode composite = parent as CompositeNode;
		if (composite)
			composite.AddChild(child);
	}

	public void RemoveChild(Node parent, Node child)
	{
		DecoratorNode decorator = parent as DecoratorNode;
		if (decorator)
		{
			decorator.SetChild(null);
			return;
		}

		RootNode root = parent as RootNode;
		if (root)
		{
			root.child = null;
			return;
		}

		CompositeNode composite = parent as CompositeNode;
		if (composite)
			composite.RemoveChild(child);
	}

	public List<Node> GetChild(Node parent)
	{
		List<Node> children = new List<Node>();
		DecoratorNode decorator = parent as DecoratorNode;
		if (decorator && decorator.GetChild() != null)
			children.Add(decorator.GetChild());


		RootNode root = parent as RootNode;
		if (root && root.child != null)
			children.Add(root.child);


		CompositeNode composite = parent as CompositeNode;
		if (composite)
			return composite.GetChild();

		return children;
	}

	public SCBehaviorTree Clone()
	{
		SCBehaviorTree tree = Instantiate(this);
		tree.rootNode = tree.rootNode.Clone();
		//tree.rootNode.SetTarget(target);
		return tree;
	}
}
