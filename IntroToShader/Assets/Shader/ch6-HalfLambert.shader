﻿Shader "Custom/ch6-HalfLambert"
{
	Properties {
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
	}
	SubShader {
        Pass {

        	Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct a2v {
            	float4 vertex: POSITION;
            	float3 normal: NORMAL;
            };

            struct v2f {
            	float4 pos: SV_POSITION;
            	float3 worldNormal: TEXCOORD0;
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

            	return o;
            }

            fixed4 frag( v2f i ): SV_Target {

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 halfLambert = dot(i.worldNormal, worldLightDir)*0.5 + 0.5;
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

				fixed3 color = ambient + diffuse;
            	
            	return fixed4(color, 1.0);
            }


			ENDCG
        }
    }
}
