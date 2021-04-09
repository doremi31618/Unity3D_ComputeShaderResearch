Shader "Custom/WorldPosMapping"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
        #pragma instancing_options assumeuniformscaling procedural:mappingPosition
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Step;
        

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        //to retrieve position that we caculate at compute shader 
        //we need to declair once again
        //but this we need to check if the UNITY_PROCEDURAL_INSTANCING_ENABLED is enable
        #if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
            StructuredBuffer<float3> _Positions;
        #endif

        void mappingPosition(){
            #if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
            //unity_InstancingID is an unity build-in parameter that automatically assigned by shader
            float3 position = _Positions[unity_InstanceID];

            //the unity_ObjectToWorld is an matrix that auto generated base on the Transform component in unity
            //set all matrix to zero materix 
            unity_ObjectToWorld = 0.0;
            unity_ObjectToWorld._m03_m13_m23_m33 = float4(position.x, position.y, position.z, 1.0);
            unity_ObjectToWorld._m00_m11_m22 = _Step;
            #endif
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            float2 uv = (float2(IN.worldPos.x, IN.worldPos.z) + 1)/2;
            fixed4 c = tex2D (_MainTex, uv) * _Color;
            o.Albedo = c.rgb;//* saturate(IN.worldPos * 0.5 + 0.5)
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
