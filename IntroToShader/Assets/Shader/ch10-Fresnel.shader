Shader "ShaderBook/ch10/ch10-Fresnel"
{
	Properties
	{
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_RefColor("Refelction Color", Color) = (1, 1, 1, 1)
		_RefAmount("Reflection Amount", Range(0, 1)) = 0.5
		_FresScale("Fresnel Scale", Range(0, 1)) = 1
		_Cubemap("Cubemap", Cube) = "_Skybox"{}
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
	float _RecAmount;
	float _FresScale;
	samplerCUBE _Cubemap;

	struct a2v {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
			};

	struct v2f {
		float4 pos : SV_POSITION;
		float3 worldNormal : TEXCOORD0;
		float3 worldPos : TEXCOORD1;
		float3 worldViewDir : TEXCOORD2;
		float3 worldRef : TEXCOORD3;

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

	fixed4 frag(v2f i) : SV_Target{
		float3 worldNormal = normalize(i.worldNormal);
		float3 worldViewDir = normalize(i.worldViewDir);
		float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
		fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldLightDir, worldNormal));

		UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

		fixed3 reflection = texCUBE(_Cubemap, i.worldRef).rgb * _RefColor.rgb;

		fixed3 fresnel = _FresScale + (1 - _FresScale) * pow(1 - dot(worldViewDir, worldNormal), 5);

		return fixed4(ambient + lerp(diffuse, reflection, saturate(fresnel))*atten, 1.0);
	}

			ENDCG
		}
	}
}
