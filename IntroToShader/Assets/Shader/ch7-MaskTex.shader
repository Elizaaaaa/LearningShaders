Shader "Custom/ch7-MaskTex"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BumpTex ("Normal Map", 2D) = "bump" {}
		_SpecularMask ("Specular Mask", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20.0
		_BumpScale ("Bump Scale", float) = 1.0
		_MaskScale ("Mask Scale", float) = 1.0
	}
	SubShader
	{
		Tags {"LightMode" = "ForwardBase"}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			sampler2D _SpecularMask;
			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;
			float _BumpScale;
			float _MaskScale;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert( a2v v ) {
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}

			fixed4 frag( v2f i ) : SV_Target {
				fixed3 tangentLight = normalize(i.lightDir);
				fixed3 tangentView = normalize(i.viewDir);

				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpTex, i.uv));
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - dot(tangentNormal.xy, tangentNormal.xy));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0 * albedo * max(0, dot(tangentNormal, tangentLight));

				fixed3 halfDir = normalize(tangentLight + tangentView);
				fixed mask = tex2D(_SpecularMask, i.uv).r * _MaskScale;
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, tangentNormal)),_Gloss) * mask;

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}
}
