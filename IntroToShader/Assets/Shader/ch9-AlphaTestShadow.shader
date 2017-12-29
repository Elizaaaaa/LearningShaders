Shader "ShaderBook/ch9/ch9-AlphaTestShadow"
{
	Properties
	{
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "white" {}
		_Cutoff("Cut off", float) = 0.5
	}
	SubShader
	{
		Tags {"Queue" = "AlphaTest" "IgnoreProjector" = "true" "RenderType" = "TransparentCutout"}

		Pass
		{
			Tags {"LightMode" = "ForwardBase"}

			Cull Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Cutoff;

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
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v) {
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = _MainTex_ST.xy * v.texcoord.xy + _MainTex_ST.zw;

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				float4 texColor = tex2D(_MainTex, i.uv);
				if (texColor.a - _Cutoff < 0) discard;

				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
	
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));


				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				return fixed4(ambient + (diffuse) * atten, 1.0);

			}

			ENDCG
		}

		Pass{
			Tags {"LightMode" = "ForwardAdd"}

			Blend One One

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#pragma multi_compile_fwdadd

				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "AutoLight.cginc"

				fixed4 _Color;
				fixed4 _Specular;
				float _Gloss;

				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float3 worldNormal : TEXCOORD0;
					float3 worldPos : TEXCOORD1;
				};

				v2f vert(a2v v) {
					v2f o;

					o.pos = UnityObjectToClipPos(v.vertex);

					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

					return o;
				}

				fixed4 frag(v2f i) : SV_Target {
					float3 worldNormal = normalize(i.worldNormal);

					#ifdef USING_DIRECTIONAL_LIGHT
						float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
					#else
						float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
					#endif

					fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

					float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
					float3 halfDir = normalize(viewDir + worldLightDir);

					fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

					#ifdef USING_DIRECTIONAL_LIGHT
						float atten = 1.0;
					#else 
						#if defined (POINT)
							float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
							float atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
						#elif defined (SPOT)
							float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
				        	fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
						#else
							float atten = 1.0;
						#endif
					#endif

					return fixed4((diffuse+specular)*atten, 1.0);
				}
			ENDCG
		}
	}
	Fallback "Transparent/Cutout/VertexLit"
}
