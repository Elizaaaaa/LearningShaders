using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectBase {

    [SerializeField] Shader edgeShader;
    [SerializeField] Material edgeMaterial;

    [Range(0.0f, 1.0f)]
    public float edgeOnly = 0.0f;

    public Color edgeColor = Color.black;
    public Color bgColor = Color.white;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    private Material GetMaterial()
    {
        edgeMaterial = CheckShaderCreateMaterial(edgeShader, edgeMaterial);
        return edgeMaterial;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Material material = this.GetMaterial();
        if (material)
        {
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BgColor", bgColor);

            Graphics.Blit(source, destination, material);
        }
        else
            Graphics.Blit(source, destination);
    }
}
