using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Gaussian : PostEffectBase {

    [SerializeField] Shader gShader;
    [SerializeField] Material gMaterial = null;

    [Range(0, 4)]
    public int iterator = 3;
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    [Range(1, 8)]
    public int downSample = 2;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    private Material GetMaterial()
    {
        gMaterial = CheckShaderCreateMaterial(gShader, gMaterial);
        return gMaterial;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Material material = GetMaterial();
        if (material)
        {
            int rtW = source.width / downSample;
            int rtH = source.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(source, buffer0);

            for (int i = 0; i < iterator; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(buffer0, buffer1, material, 0);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(buffer0, buffer1, material, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            Graphics.Blit(buffer0, destination);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
            Graphics.Blit(source, destination);
    }
}
