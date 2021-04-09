Shader "Custom/PointCloudShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Smoothness("Smoothness", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows addshadow

        //instancing_options is an Unity built-in instructor 
        //that tells gpu we need an additional option to set the position for every particle
        //and the assumuniformscaling tell gpu every instancing is in the same size(scale)
        //the final instructor procedural tell the gpu how we want to do before into vertext shader
        #pragma instancing_options assumeuniformscaling procedural:ConfigureProcedural
        
        // Use shader model 4.5 target, to get nicer looking lighting
        #pragma target 4.5

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed _Smoothness;
        float _Step;

        #if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
                StructuredBuffer<float3> _Positions;
        #endif
        
        
        void ConfigureProcedural(){
            #if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
                //
                float3 position = _Positions[unity_InstanceID];

                unity_ObjectToWorld = 0.0;
                unity_ObjectToWorld._m03_m13_m23_m33 = float4(position, 1.0);
                unity_ObjectToWorld._m00_m11_m22 = _Step;
            #endif
        }

         void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = saturate(IN.worldPos*0.5+0.5);
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
