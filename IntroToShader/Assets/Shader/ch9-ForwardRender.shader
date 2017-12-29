Shader "ShaderBook/ch9/ch9-ForwardRender"
{
	Properties
	{
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256.0)) = 20.0
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
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
	
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				float3 halfDir = normalize(viewDir + worldLightDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfDir, worldNormal)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);

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
}
