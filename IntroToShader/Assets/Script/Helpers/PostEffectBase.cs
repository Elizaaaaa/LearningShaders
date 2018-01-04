using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]

public class PostEffectBase : MonoBehaviour {

    protected void CheckResources()
    {
        bool isSupported = CheckSupport();

        if (!isSupported)
            NotSupported();
    }

    protected bool CheckSupport()
    {
        if (SystemInfo.supportsImageEffects == false)
        {
            Debug.Log("Doesn't support");
            return false;
        }

        return true;
    }

    protected void NotSupported()
    {
        enabled = false;
    }

	// Use this for initialization
	void Start () {
        CheckResources();
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    protected Material CheckShaderCreateMaterial(Shader shader, Material material)
    {
        if (shader == null)
            return null;
        else if (!shader.isSupported)
            return null;

        else if (shader.isSupported && material && material.shader == shader)
            return material;
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material)
                return material;
            else
                return null;
        }
    }
}
