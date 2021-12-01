Shader "Unlit/TexturedShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Pattern ("Pattern", 2D) = "white" {}
        _Rock ("Rock", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define TAU 6.28318530718


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPosition: TEXCOORD01;
            };

            float4 _MainTex_ST;
            sampler2D _MainTex;

            sampler2D _Pattern;
            sampler2D _Rock;

            v2f vert (appdata v)
            {
                v2f o;
                o.worldPosition = mul(UNITY_MATRIX_M, float4(v.vertex.xyz, 1));// object to world position

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            
            float4 frag (v2f i) : SV_Target
            {
                float2 topDownProjection = i.worldPosition.xz;

               

                float4 col = tex2D(_MainTex, topDownProjection);
                float4 rock = tex2D(_Rock, topDownProjection);
                float4 pattern = tex2D( _Pattern, i.uv);

                float4 finalColor = lerp( rock, col, pattern );

                return finalColor;
            }
            ENDCG
        }
    }
}
