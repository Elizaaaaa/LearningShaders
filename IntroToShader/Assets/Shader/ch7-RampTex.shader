Shader "Custom/ch7-RampTex"
{
	Properties
	{
		_RampTex ("Ramp Texture", 2D) = "white" {}
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20.0
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _RampTex;
			float4 _RampTex_ST;
			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v) {
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.uv = v.texcoord.xy * _RampTex_ST.xy + _RampTex_ST.zw;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				float halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
				fixed2 rampUv = fixed2(halfLambert, halfLambert);
				fixed3 diffuseColor = tex2D(_RampTex, rampUv).rgb * _Color.rgb;

				fixed3 diffuse = diffuseColor * _LightColor0.rgb;

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, worldNormal)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}


			ENDCG
		}
	}
}
