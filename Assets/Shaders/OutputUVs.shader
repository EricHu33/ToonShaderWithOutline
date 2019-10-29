Shader "Custom/OutputUVs"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "OutputUVs"="On"}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag			
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            float4 frag (v2f i) : SV_Target
            {
                half4 c = frac( i.uv );
                if (any(saturate(i.uv) - i.uv))
                c.b = 0.5;
                return fixed4(c.xyz, 1);
            }
            ENDCG
        }
    }
}