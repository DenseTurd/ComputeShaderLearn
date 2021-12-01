Shader "Unlit/Shadery"
{
    Properties
    {
        _ColorA ("Color A", Color) = (1,1,1,1)
        _ColorB ("Color B", Color) = (1,1,1,1)
        _ColorStart ("Color Start", Range(0, 1)) = 0
        _ColorEnd ("Color End", Range(0, 1)) = 1

    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        Tags { 
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        Pass
        {
            ZWrite Off
            // ZTest GEqual // Great for seeing things through walls
            Cull Off
            //ZWrite Off
            Blend One One // additive
            //Blend DstColor Zero /// mulitple

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.28318530718

            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;    

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
                float2 uv0 : TEXCOORD0;
                //float2 uv1 : TEXCOORD1; // other tings you can have
                //float3 normals : NORMAL;
                //float4 tangent : TANGENT;
                //float4 color : COLOR;
            };

            // v2f is Unity's default name for data that is passed from vertex shader to fragment shader
            // Freyah likes calling this "Interpoloators"
            struct Interpoloators 
            {
                float4 vertex : SV_POSITION; // clip space position
                float3 normal : TEXCOORD0; 
                float2 uv0 : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            Interpoloators vert (MeshData v)
            {
                Interpoloators o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Converts local space to clip space 
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv0 = v.uv0; //(v.uv0 + _Offset) * _Scale; // passThrough
                // UnityObjectToWorldNormal converts from local to world space
                return o;
            }

            float InverseLerp(float a, float b, float t)
            {
                return (t-a)/(b-a);
            }

            // fixed 4 is a low precision no. Only useful for -1, 1 range. Legacy stuff
            // it was the default return type here, let's use floats everywhere instead
            float4 frag (Interpoloators i) : SV_Target
            {
                //float t = saturate(InverseLerp (_ColorStart, _ColorEnd, i.uv0.x));
                // saturate is like Mathf.Clamp(0, 1, value);
                //t = frac(t); // Useful for debugging, shiz will repeat, takes the floor of a value and subtracts it from that value

                
                //return outColor;
                //return outColor;

                float yOffset = cos(i.uv0.x * TAU * 8) * 0.01;

                float t = cos((i.uv0.y + yOffset + (-_Time.y * 0.3)) * TAU * 8) * 0.5 + 0.5;
                t *= 1 - saturate(i.uv0.y);
                

                float topBottomRemover = t *= abs(i.normal.y) < 0.999;
                float waves = t * topBottomRemover;
                
                float4 gradient = lerp( _ColorA, _ColorB, i.uv0.y);
                return gradient * waves;
            }
            ENDCG
        }
    }
}
