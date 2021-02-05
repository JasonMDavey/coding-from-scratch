Shader "Custom/LavaShader"
{
	Properties
	{
		_Threshold("Threshold", Range(0,1)) = 0.3
		_OutlineTolerance("OutlineTolerance", Range(0,0.1)) = 0.01

		_OutlineColor("OutlineColor", Color) = (1,1,1,1)
		_Color("Color", Color) = (1,1,1,1)

		// Balls - (x,y,intensity,unused)
		_Ball0("Ball0", Vector) = (0,0,0,0)
		_Ball1("Ball1", Vector) = (0,0,0,0)
		_Ball2("Ball2", Vector) = (0,0,0,0)
		_Ball3("Ball3", Vector) = (0,0,0,0)
		_Ball4("Ball4", Vector) = (0,0,0,0)
		_Ball5("Ball5", Vector) = (0,0,0,0)
		_Ball6("Ball6", Vector) = (0,0,0,0)
		_Ball7("Ball7", Vector) = (0,0,0,0)
		_Ball8("Ball8", Vector) = (0,0,0,0)
		_Ball9("Ball9", Vector) = (0,0,0,0)
	}
		SubShader
		{
			Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
			LOD 100

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : NORMAL;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};


				float _Threshold;
				float _OutlineTolerance;
				fixed4 _Color;
				fixed4 _OutlineColor;

				float4 _Ball0;
				float4 _Ball1;
				float4 _Ball2;
				float4 _Ball3;
				float4 _Ball4;
				float4 _Ball5;
				float4 _Ball6;
				float4 _Ball7;
				float4 _Ball8;
				float4 _Ball9;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					return o;
				}

				float calcBall(float4 ball, float2 uv) {
					float xDiff = uv.x - ball.x;
					float yDiff = uv.y - ball.y;
					return ball.z * 1.0/sqrt(xDiff*xDiff + yDiff*yDiff);
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float influence = calcBall(_Ball0, i.uv) + calcBall(_Ball1, i.uv) + calcBall(_Ball2, i.uv) + calcBall(_Ball3, i.uv) + calcBall(_Ball4, i.uv) 
									+ calcBall(_Ball5, i.uv) + calcBall(_Ball6, i.uv) + calcBall(_Ball7, i.uv) + calcBall(_Ball8, i.uv) + calcBall(_Ball9, i.uv);

					float fillIntensity = min(10000*max(0, influence - _Threshold), 1);

					float thresDiff = abs(influence - _Threshold);
					float outlineIntensity = max(0, (_OutlineTolerance - thresDiff) / _OutlineTolerance);

					fixed4 col = fixed4(_Color.x, _Color.y, _Color.z, min(1.1, fillIntensity + outlineIntensity));
					
					return col;
				}

			ENDCG
		}
		}
}
