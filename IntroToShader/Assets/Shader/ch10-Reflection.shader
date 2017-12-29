Shader "ShaderBook/ch10/ch10-Reflection"
{
	Properties
	{
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_RefColor("Reflection Color", Color) = (1, 1, 1, 1)
		_RefAmount("Reflection Amount", Range(0, 1)) = 0.4
		_Cubemap("Cubemap", Cube) = "_Skybox" {}
	}
	SubShader
	{
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed4 _RefColor;
			float _RefAmount;
			samplerCUBE _Cubemap;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 worldRef : TEXCOORD2;
				float3 worldViewDir : TEXCOORD3;

				SHADOW_COORDS(4)
			};

			v2f vert(a2v v) {
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldRef = reflect(-o.worldViewDir, o.worldNormal);
				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f o) : SV_Target {
				float3 worldNormal = normalize(o.worldNormal);
				float3 worldViewDir = normalize(o.worldViewDir);
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(o.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldViewDir));

				fixed3 reflection = texCUBE(_Cubemap, o.worldRef).rgb * _RefColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten, o, o.worldPos);

				return fixed4(ambient + lerp(diffuse, reflection, _RefAmount) * atten, 1.0);
			}

			ENDCG
		}
	}
}
