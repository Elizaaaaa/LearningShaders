﻿Shader "ShaderBook/ch11/ch11-Billboard"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_VerticalBillboarding("Vertical Restraints", Range(0, 1)) = 1
	}
		SubShader
		{
			Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			Pass
			{
				Tags {"LightMode" = "ForwardBase"}

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed4 _Color;
				fixed _VerticalBillboarding;

				struct a2v {
					float4 vertex : POSITION;
					float4 texcoord : TEXCOORD;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
				};

				v2f vert(a2v v) {
					v2f o;

					float3 center = float3(0, 0, 0);
					float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
					float3 normalDir = viewer - center;
					normalDir.y = normalDir.y * _VerticalBillboarding;
					normalDir = normalize(normalDir);

					float3 upDir = float3(0, 0, 0);
					upDir = abs(normalDir.y > 0.999) ? float3(0, 0, 1) : float3(0, 1, 0);
					float3 rightDir = normalize(cross(upDir, normalDir));
					upDir = normalize(cross(normalDir, rightDir));

					float3 offset = v.vertex.xyz - center;
					float3 localPos = center + rightDir * offset.x + upDir * offset.y + normalDir * offset.z;

					o.pos = UnityObjectToClipPos(float4(localPos, 1));
					o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

					return o;
				}

				fixed4 frag(v2f i) : SV_Target{
					fixed4 color = tex2D(_MainTex, i.uv);
					color.rgb *= _Color.rgb;

					return color;
				}

			ENDCG
		}
	}
}
