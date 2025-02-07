﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectBase {

    [SerializeField] Shader bloomShader;
    [SerializeField] Material bloomMaterial = null;

    [Range(0, 4)]
    public int iteration = 3;
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    [Range(1, 8)]
    public int scaleDown = 4;
    [Range(0.0f, 4.0f)]
    public float luminanceThreshhold = 0.6f;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    private Material GetMaterial()
    {
        bloomMaterial = CheckShaderCreateMaterial(bloomShader, bloomMaterial);
        return bloomMaterial;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Material material = GetMaterial();
        if (material)
        {
            material.SetFloat("_LuminanceThreshold", luminanceThreshhold);

            int rtW = source.width / scaleDown;
            int rtH = source.height / scaleDown;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(source, buffer0, material, 0);

            for (int i = 0; i < iteration; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                buffer1.filterMode = FilterMode.Bilinear;
                Graphics.Blit(buffer0, buffer1, material, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                buffer1.filterMode = FilterMode.Bilinear;
                Graphics.Blit(buffer0, buffer1, material, 2);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            material.SetTexture("_Bloom", buffer0);
            Graphics.Blit(source, destination, material, 3);

            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Debug.Log("no material");
            Graphics.Blit(source, destination);
        }
    }
}
