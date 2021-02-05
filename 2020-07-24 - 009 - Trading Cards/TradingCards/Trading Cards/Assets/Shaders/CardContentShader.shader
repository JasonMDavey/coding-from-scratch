Shader "Unlit/CardContentShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

		_DistortionMaskTex("Distortion Mask Texture", 2D) = "white" {}
		_DistortionIntensity("Distortion Intensity", Float) = 0.1
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_NoiseScale("Noise Scale", Float) = 1
	    _NoiseSpeed("Noise Speed", Float) = 1
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _DistortionMaskTex;
			float _DistortionIntensity;

			sampler2D _NoiseTex;
			float _NoiseScale;
			float _NoiseSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				// Sample distortion mask texture
				fixed4 distortionTexColor = tex2D(_DistortionMaskTex, i.uv);
				float2 noiseSampleUV = float2(_Time.y*0.51*_NoiseSpeed, _Time.y*0.21) + i.uv;
				fixed4 noiseColor = tex2D(_NoiseTex, noiseSampleUV / _NoiseScale);
				float2 offsetFromNoise = float2(noiseColor.r-0.5, noiseColor.g-0.5) * _DistortionIntensity;

				float2 distortionOffset = offsetFromNoise * distortionTexColor.r;

				fixed4 mainTexColor = tex2D(_MainTex, i.uv);
                fixed4 mainTexOffsetColor = tex2D(_MainTex, i.uv + distortionOffset);

				// Use alpha from true UV coord in main texture, but colour from UV with distortion applied
                return fixed4(mainTexOffsetColor.r, mainTexOffsetColor.g, mainTexOffsetColor.b, mainTexColor.a);
            }
            ENDCG
        }
    }
}
