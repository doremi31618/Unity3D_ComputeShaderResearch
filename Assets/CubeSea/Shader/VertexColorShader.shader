Shader "PointCloud/VertexColot"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            //shader properties 
            fixed4 _Color;

            struct a2v {
                float3 vertex : POSITION;
                float4 color : COLOR;
            };

            struct v2f {    
                float4 pos : SV_POSITION;
                fixed4 color : TEXCOORD0;
            };

            v2f vert(a2v input){
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.color = _Color * input.color;
                return output;
            }

            fixed4 frag(v2f input) : SV_TARGET
            {
                return input.color;
            }
            ENDCG
        }
    }
}
