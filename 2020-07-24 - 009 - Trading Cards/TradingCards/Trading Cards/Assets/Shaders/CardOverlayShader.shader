Shader "Unlit/CardOverlayShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_FiligreeMaskTex("Filigree Mask Texture", 2D) = "white" {}
		_FiligreeIntensity("Filigree Intensity", Float) = 3.0
	    _FiligreeAttenuation("Filigree Attenuation", Float) = 1.0

		_PseudoCurveAmount("Pseudo-Curve Amount", Float) = 0.3

	    _BaseLight("Base Light", Float) = 0.6
		_LightVector("Light Vector", Vector) = (0,0,0,0)
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
				float3 worldNormal : TEXCOORD1;
            };

            sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _FiligreeMaskTex;
			float _FiligreeIntensity;
			float _FiligreeAttenuation;
			float _PseudoCurveAmount;

			float _BaseLight;
			float4 _LightVector;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Define a pseudo-angle for this point on the surface, faking a curve
				// Center of the card (horizontally) is neutral, moving towards +-_PseudoCurveAmount at edges
				float pseudoAngle = lerp(_PseudoCurveAmount, -_PseudoCurveAmount, i.uv[0]);

				// Rotate normal by our pseudo-angle
				float3x3 rotMat = float3x3(cos(pseudoAngle), 0, sin(pseudoAngle), 0, 1, 0, -sin(pseudoAngle), 0, cos(pseudoAngle));
				float3 effectiveNormal = normalize(mul(rotMat, i.worldNormal));
				 
				// Calculate angle between light and surface
				float dotWithLight = dot(effectiveNormal, normalize(_LightVector.xyz)); // -1=direct lighting, 0=no lighting

				// Bits of the card directly facing the light glint more
				float filigreeGlintRatio = pow(clamp(-dotWithLight, 0.0, 1.0), _FiligreeAttenuation);

				// Sample filigree mask texture
				fixed4 filigreeMaskTexColor = tex2D(_FiligreeMaskTex, i.uv);

				// Overlay filigree onto base texture
				float textureIntensity = _BaseLight + (filigreeGlintRatio * filigreeMaskTexColor.r * _FiligreeIntensity);

                fixed4 mainTexColor = tex2D(_MainTex, i.uv);
                return fixed4(mainTexColor.r * textureIntensity, mainTexColor.g * textureIntensity, mainTexColor.b * textureIntensity, mainTexColor.a);
            }
            ENDCG
        }
    }
}
