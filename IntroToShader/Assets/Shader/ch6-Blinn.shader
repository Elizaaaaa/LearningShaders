Shader "Custom/ch6-Blinn"
{
	Properties {
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0, 256.0)) = 20.0
	}
	SubShader {
        Pass {

        	Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            fixed _Gloss;

            struct a2v {
            	float4 vertex: POSITION;
            	float3 normal: NORMAL;
            };

            struct v2f {
            	float4 pos: SV_POSITION;
            	float3 worldNormal: TEXCOORD0;
            	float3 worldPos: TEXCOORD1;
            };

            v2f vert( a2v v ) {
            	v2f o;

            	o.pos = UnityObjectToClipPos(v.vertex);

//            	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
//
  //          	fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
    //        	fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
      //      	fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
      //
        //    	o.color = ambient + diffuse;

        		o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

        		o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

            	return o;
            }

            fixed4 frag( v2f i ): SV_Target {

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, worldLightDir));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
	//			fixed3 reflectDir = normalize(reflect(-worldLightDir, i.worldNormal));

				fixed3 halfDir = normalize(worldLightDir + viewDir);

				fixed3 specular = pow(max(0, dot(halfDir, normalize(i.worldNormal))),_Gloss) * _LightColor0.rgb * _Specular.rgb;

				fixed3 color = ambient + diffuse + specular;
            	
            	return fixed4(color, 1.0);
            }


			ENDCG
        }
    }
}
