Shader "ShaderBook/ch11/ch11-ImageSequence"
{
	Properties
	{
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Texture Sequence", 2D) = "white" {}
		_AmountH("Horizontal Amount", float) = 4
		_AmountV("Vertical Amount", float) = 4
		_Speed("Speed", float) = 30
	}
		SubShader
		{
			Tags {"Queue" = "Transparent" "IgnorProjector" = "true" "RenderType" = "Transparent"}

			Pass
			{
				Tags {"LightMode" = "ForwardBase"}
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _AmountH;
			float _AmountV;
			float _Speed;

			struct a2v {
				float4 vertex :POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(a2v v) {
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				float time = floor(_Time.y * _Speed);
				float row = floor(time / _AmountH);
				float column = time - row * _AmountV;

				half2 uv = float2(i.uv.x / _AmountH, i.uv.y / _AmountV);
				uv.x += column / _AmountH;
				uv.y -= row / _AmountV;

				fixed4 c = tex2D(_MainTex, uv);

				return c;
			}

			ENDCG
		}
	}
}
