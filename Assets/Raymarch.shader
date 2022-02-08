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
            #define MAX_DIST 200
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
                o.uv = v.uv;
                return o;
            }

            float GetDist(float3 p) {
                float dstA = dot(sin(p * 2.0f), 1);
                float dstB = dot(p % 2, 1);

                return lerp(dstA, dstB, 0.5f);
            }

            float Raymarch(float3 origin, float3 direction) {
                float distanceFromOrigin = 0.0f;
                float distanceFromScene;

                while (distanceFromOrigin < MAX_DIST) {
                    float3 p = origin + distanceFromOrigin * direction;
                    distanceFromScene = GetDist(p);
                    distanceFromOrigin += distanceFromScene;

                    if (distanceFromScene < SURF_DIST)
                        break;
                }

                return distanceFromOrigin;
            }

            float3 GetNormal(float3 p) {
                float2 e = float2(0.001, 0);
                float3 n = GetDist(p) - float3(
                    GetDist(p - e.xyy), 
                    GetDist(p - e.yxy), 
                    GetDist(p - e.yyx)
                    );

                return normalize(n);
            }

            fixed4 fp(v2f i) : SV_Target {
                float2 uv = i.uv - 0.5f;
                float3 origin = mul(unity_CameraToWorld, float4(0, 0, 0, 1)).xyz;
                float3 direction = mul(unity_CameraInvProjection, float4(uv, 0, 1)).xyz;
                direction = mul(unity_CameraToWorld, float4(direction,0)).xyz;
                direction = normalize(direction);

                float d = Raymarch(origin, direction);

                fixed4 col = 0.0f;
                
                if (d < MAX_DIST) {
                    float3 p = origin + direction * d;
                    float3 n = GetNormal(p);
                    col.rgb = n;
                }
                
                return col;
            }

            ENDCG
        }
    }
}
