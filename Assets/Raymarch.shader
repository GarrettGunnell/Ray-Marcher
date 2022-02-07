Shader "Unlit/Raymarch" {
    
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }
    
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            #include "UnityCG.cginc"

            #define MAX_STEPS 100
            #define MAX_DIST 100
            #define SURF_DIST 0.001

            struct VertexData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vp(VertexData v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float GetDist(float3 p) {
                float d = length(p) - 0.5f;
            
                return d;
            }

            float Raymarch(float3 origin, float3 direction) {
                float distanceFromOrigin = 0.0f;
                float distanceFromScene;

                for (int i = 0; i < MAX_STEPS; ++i) {
                    float3 p = origin + distanceFromOrigin * direction;
                    distanceFromScene = GetDist(p);
                    distanceFromOrigin += distanceFromScene;

                    if (distanceFromScene < SURF_DIST || distanceFromOrigin > MAX_DIST)
                        break;
                }

                return distanceFromOrigin;
            }

            fixed4 fp(v2f i) : SV_Target {
                float2 uv = i.uv - 0.5f;
                float3 origin = float3(0.0f, 0.0f, -3.0f);
                float3 direction = normalize(float3(uv.x, uv.y, 1.0f));

                float d = Raymarch(origin, direction);

                fixed4 col = 0.0f;
                
                if (d < MAX_DIST) {
                    col.r = 1.0f;
                }
                
                return col;
            }

            ENDCG
        }
    }
}
