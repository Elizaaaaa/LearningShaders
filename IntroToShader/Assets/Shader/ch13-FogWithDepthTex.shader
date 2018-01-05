Shader "Hidden/ch13-FogWithDepthTex"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FogDensity ("Fog Density", float) = 1.0
		_FogColor ("Fog Color", Color) = (1, 1, 1, 1)
		_FogStart ("Fog Start", float) = 0.0
		_FogEnd ("Fog End", float) = 2.0
	}
	SubShader
	{
		CGINCLUDE

		#include "UnityCG.cginc"

		float4x4 _FrustumCornersRay;
		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;
		float _FogDensity;
		float _FogStart;
		float _FogEnd;
		fixed4 _FogColor;


			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 depth : TEXCOORD1;
				float4 interpolatedRay : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata_img v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.depth = v.texcoord;

				int index = 0;
				if (v.texcoord.x < 0.5 && v.texcoord.y < 0.5)
					index = 0;
				else if (v.texcoord.x > 0.5 && v.texcoord.y < 0.5)
					index = 1;
				else if (v.texcoord.x > 0.5 && v.texcoord.y > 0.5)
					index = 2;
				else
					index = 3;

				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0){
					o.depth.y = 1-o.depth.y;
					index = 3 - index;
				}
				#endif

				o.interpolatedRay = _FrustumCornersRay[index];

				return o;
			}
			fixed4 frag (v2f i) : SV_Target
			{
				float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.depth));
				float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;

				float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
				fogDensity = saturate(fogDensity * _FogDensity);

				fixed4 color = tex2D(_MainTex, i.uv);
				color.rgb = lerp(color.rgb, _FogColor.rgb, fogDensity);

				return color;
			}
		ENDCG

		// No culling or depth


		Pass
		{
			Cull Off ZWrite Off ZTest Always

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}

	FallBack Off
}
