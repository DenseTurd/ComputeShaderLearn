// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Unlit alpha-blended shader.
// - no lighting
// - no lightmap support
// - no per-material color
 
Shader "Unlit/LeavesShader" {
Properties {
    _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
    _SwayAmp ("Sway Amp", Range(0, 10)) = 1
}
 
SubShader {
    Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
    LOD 100
     
    ZWrite Off
    Blend SrcAlpha OneMinusSrcAlpha 
     
    Pass {  
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
             
            #include "UnityCG.cginc"

            #define TAU 6.28318530718

            float _SwayAmp;
 
            struct MeshData {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float2 uv0 : TEXCOORD1;
            };
 
            struct Interpolators {
                float4 vertex : SV_POSITION;
                half2 texcoord : TEXCOORD0;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;

            float GetSway(float4 vertex){

                float sway = cos( vertex.x + (-_Time.y * 0.2) * TAU * 2) * 0.5 + 0.5;
                return sway;
            }
             
            Interpolators vert (MeshData meshData){
                Interpolators o;

                float sway = GetSway(meshData.vertex);
                meshData.vertex.y = sway * _SwayAmp;
                o.vertex = UnityObjectToClipPos(meshData.vertex);
                o.texcoord = TRANSFORM_TEX(meshData.texcoord, _MainTex);
                return o;
            }
             
            float4 frag (Interpolators i) : SV_Target{
                float4 col = tex2D(_MainTex, i.texcoord);
                return col;
                //return float4(GetSway(i.texcoord), 1, 1, 1);
            }
        ENDCG
    }
}
}