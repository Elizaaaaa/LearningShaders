Shader "ShaderBook/ch11/ch11-ScrollingBg"
{
	Properties
	{
		_MainTex ("Fore Texture", 2D) = "white" {}
		_BackTex("Back Texture", 2D) = "white" {}
		_SpeedF("Fore Speed", float) = 1.0
		_SpeedB("Back Speed", float) = 1.0
		_Multipler("Multipler", float) = 1
	}
		SubShader
		{
			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BackTex;
			float4 _BackTex_ST;
			float _SpeedF;
			float _SpeedB;
			float _Multipler;

			struct a2v {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};

			v2f vert(a2v v) {
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw + frac(float2(_SpeedF, 0) * _Time.y);
				o.uv.zw = v.texcoord.xy * _BackTex_ST.xy + _BackTex_ST.zw + frac(float2(_SpeedB, 0) * _Time.y);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed4 forColor = tex2D(_MainTex, i.uv.xy);
				fixed4 bakColor = tex2D(_BackTex, i.uv.zw);
				fixed4 color = lerp(bakColor, forColor, forColor.a);

				color.xyz *= _Multipler;

				return color;
			}

			ENDCG
		}
	}
}
