Shader "Hidden/ch12-BSC"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Brightness("Brightness", float) = 1.0
		_Saturation("Saturation", float) = 1.0
		_Contrast("Contrast", float) = 1.0
	}
		SubShader
		{
			// No culling or depth
			Cull Off ZWrite Off ZTest Always

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				sampler2D _MainTex;
				float _Brightness;
				float _Contrast;
				float _Saturation;


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 tex = tex2D(_MainTex, i.uv);
				fixed3 c = tex.rgb * _Brightness;

				fixed3 l = 0.2125 * tex.r + 0.7154 * tex.g + 0.0721 * tex.b;
				c = lerp(l, c, _Saturation);

				fixed3 a = fixed3(0.5, 0.5, 0.5);
				c = lerp(a, c, _Contrast);

				return fixed4(c, 1.0);
			}
			ENDCG
		}
	}
}
