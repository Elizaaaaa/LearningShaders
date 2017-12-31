
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[ExecuteInEditMode]

public class ProceduralTexGenerator : MonoBehaviour {

    public Material material = null;

    #region Material properties
    [SerializeField, SetProperty("textureWidth")]
    private int m_textureWidth = 512;
    public int textureWidth
    {
        get {
            return m_textureWidth;
        }
        set
        {
            m_textureWidth = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("backgroundColor")]
    private Color m_backgroundColor = Color.white;
    public Color backgroundColor
    {
        get
        {
            return m_backgroundColor;
        }
        set
        {
            m_backgroundColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("circleColor")]
    private Color m_circleColor = Color.yellow;
    public Color circleColor
    {
        get
        {
            return m_circleColor;
        }
        set
        {
            m_circleColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("blueFactor")]
    private float m_blueFactor = 2.0f;
    public float blueFactor
    {
        get
        {
            return m_blueFactor;
        }
        set
        {
            m_blueFactor = value;
            _UpdateMaterial();
        }
    }
    #endregion

    private Texture2D m_generatedTex = null;

    // Use this for initialization
    void Start()
    {
        if (material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if (renderer == null)
            {
                return;
            }

            material = renderer.sharedMaterial;
        }

        _UpdateMaterial();
    }


    private void _UpdateMaterial()
    {
        if (material != null)
        {
            m_generatedTex = _GenerateProceduralTex();
            material.SetTexture("_MainTex", m_generatedTex);
        }
    }

    private Color _MixColor(Color c0, Color c1, float cf)
    {
        Color mc = Color.white;

        mc.r = Mathf.Lerp(c0.r, c1.r, cf);
        mc.g = Mathf.Lerp(c0.g, c1.g, cf);
        mc.b = Mathf.Lerp(c0.b, c1.b, cf);
        mc.a = Mathf.Lerp(c0.a, c1.a, cf);

        return mc;
    }

    private Texture2D _GenerateProceduralTex()
    {
        Texture2D proceduralTex = new Texture2D(textureWidth, textureWidth);
        float circleInterval = textureWidth / 4.0f;
        float radius = textureWidth / 10.0f;
        float edgeBlur = 1.0f / blueFactor;

        for (int w = 0; w < textureWidth; w++)
        {
            for (int h = 0; h < textureWidth; h++)
            {
                Color pixel = backgroundColor;
                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;
                        Color color = _MixColor(circleColor, new Color(pixel.r, pixel.g, pixel.b, 0.0f), Mathf.SmoothStep(0f, 1.0f, dist * edgeBlur));
                        pixel = _MixColor(pixel, color, color.a);
                    }
                }

                proceduralTex.SetPixel(w, h, pixel);
            }
        }

        proceduralTex.Apply();
        return proceduralTex;
    }

	// Update is called once per frame
	void Update () {
		
	}
}
