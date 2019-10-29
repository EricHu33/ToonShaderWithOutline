Shader "Custom/ToonWithOutline" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_OutlineColor ("Outline Tint", Color) = (0, 0, 0, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		[MaterialToggle]_UseSpecular("_UseSpecular" , Range(0, 1)) = 0
		_SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
		_Glossiness("Glossiness", Float) = 32
		_RimColor ("Rim Color Tint", Color) = (1, 1, 1, 1)
		_RimDistance("Rim Distance", Range(0, 1)) = 1
		_RimThreshold("Rim Threshold", Range(0, 1)) = 1
		[MaterialToggle]_UseDepthEdge("UseDepthEdge" , Range(0, 1)) = 1
		_DepthThreshold("Depth Threshold", Range(0,5)) = 5
		_DepthAngleThreshold("Depth Angle Threshold", Range(-1,1)) = 0
		[MaterialToggle]_UseNormalEdge("UseNormalEdge" , Range(0, 1)) = 1
		_NormalThreshold("Normal Threshold", Range(0, 5)) = 5
		[MaterialToggle]_UseUvEdge("UseUvEdge" , Range(0, 1)) = 1
		_UvThreshold("Uv Threshold", Range(0, 5)) = 5
	}
	SubShader {
		Tags { "RenderType"="Opaque"}
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D _MainTex;
			sampler2D _ScreenUvColorMap;
			sampler2D _ScreenNormalColorMap;
			sampler2D _CameraDepthTexture;

			float4 _MainTex_ST;
			float4 _Color;
			float4 _OutlineColor;
			float4 _SpecularColor;
			float _Glossiness;
			float _RimDistance;
			float _RimThreshold;
			float4 _RimColor;

			float _DepthThreshold;
			float _NormalThreshold;
			float _DepthAngleThreshold;
			float _UvThreshold;
			float4 _CameraDepthTexture_TexelSize;
			fixed _UseSpecular;
			fixed _UseDepthEdge;
			fixed _UseNormalEdge;
			fixed _UseUvEdge;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 uv : TEXCOORD0;
			}; 
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 worldNormal : NORMAL;
				float3 worldPos :TEXCOORD1;
				float4 scrPos :TEXCOORD2;
			};
			
			v2f vert (a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex); 
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex).xyxy;
				o.scrPos = ComputeScreenPos(o.pos);
				return o;
			}
			
			float4 frag(v2f i) : SV_Target { 
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				float NdotL = dot(worldLightDir, worldNormal);

				fixed4 texColor = tex2D(_MainTex, i.uv);
				//float lightIntensity = step(0,NdotL);

				float lightIntensity = smoothstep(0, 0.01, NdotL);
				float4 light = _LightColor0 * lightIntensity;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 halfDir = normalize(worldLightDir+viewDir);
				float NdotH = dot(worldNormal, halfDir);
				float specularIntensity = pow(saturate(NdotH), _Glossiness*_Glossiness);
				float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
				float4 specular = specularIntensitySmooth * _SpecularColor;

				float4 rimDot = 1 - dot(viewDir, worldNormal);
				float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
				rimIntensity = smoothstep(_RimDistance - 0.01, _RimDistance + 0.01, rimIntensity);

				//////SCREEN SPACE EDGE DETECTION
				float2 scrUV = i.scrPos.xy/i.scrPos.w;  

				float3 normal = tex2D(_ScreenNormalColorMap, scrUV);
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, scrUV);
				float linearDepth = Linear01Depth(depth);

				//DEBUG RETURN
				//return float4(linearDepth,linearDepth,linearDepth, 1);
				//return float4(normal, 1);
				//return float4(tex2D(_ScreenUvColorMap, scrUV).rgb, 1);

				float NdotV = (1-saturate(dot((normal*2-1), -viewDir)))*_DepthAngleThreshold;
				
				float halfScaleFloor = floor(1 * 0.5);
				float halfScaleCeil = ceil(1 * 0.5);

				float2 bottomRightUV = scrUV + float2(1,-1) * _CameraDepthTexture_TexelSize.xy;
				float2 topLeftUV = scrUV + float2(-1,1)* _CameraDepthTexture_TexelSize.xy;
				float2 bottomLeftUV = scrUV + float2(-1,-1)* _CameraDepthTexture_TexelSize.xy;
				float2 topRightUV = scrUV +  float2(1,1)* _CameraDepthTexture_TexelSize.xy;
				float3 bl, tr, br, tl;
				float dbl, dtr, dbr, dtl;
				float3 uvBl, uvTr, uvBr, uvTl;

				bl = tex2D(_ScreenNormalColorMap, bottomLeftUV).rgb;
				tr = tex2D(_ScreenNormalColorMap, topRightUV).rgb;
				br = tex2D(_ScreenNormalColorMap, bottomRightUV).rgb;
				tl = tex2D(_ScreenNormalColorMap, topLeftUV).rgb;

				dbl = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, bottomLeftUV));
				dtr = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, topRightUV));
				dbr = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, bottomRightUV));
				dtl = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, topLeftUV));

				uvBl = tex2D(_ScreenUvColorMap, bottomLeftUV).rgb;
				uvTr = tex2D(_ScreenUvColorMap, topRightUV).rgb;
				uvBr = tex2D(_ScreenUvColorMap, bottomRightUV).rgb;
				uvTl = tex2D(_ScreenUvColorMap, topLeftUV).rgb;

				float3 uvDifference0 = uvTr - uvBl;
				float3 uvDifference1 = uvTl - uvBr;

				float3 normalFiniteDifference0 = tr - bl;
				float3 normalFiniteDifference1 = tl - br;
				
				float depthDiff0 = dtr - dbl;
				float depthDiff1 = dtl - dbr;
				
				float edgeDepth = sqrt(pow(depthDiff0, 2) + pow(depthDiff1, 2)) * 100;
				edgeDepth = _UseDepthEdge > 0 ? 1-step(_DepthThreshold * (1-NdotV), edgeDepth) : 1;

				float edgeNormal = sqrt(dot(normalFiniteDifference0, normalFiniteDifference0) + dot(normalFiniteDifference1, normalFiniteDifference1));				
				edgeNormal = _UseNormalEdge > 0 ? 1-step(_NormalThreshold* (1-NdotV), edgeNormal) : 1;
				
				float edgeUv = sqrt(dot(uvDifference0, uvDifference0) + dot(uvDifference1, uvDifference1));
				edgeUv = _UseUvEdge > 0 ? 1-step(_UvThreshold * (1-NdotV), edgeUv) : 1;

				float edge = min(edgeNormal, edgeDepth);
				edge = min(edge, edgeUv);
				
				fixed3 lightsum =  (light + ambient  + rimIntensity*rimDot*_RimColor);
				if(_UseSpecular > 0)
				{
					lightsum += specular;
				}
				
				return edge == 0 ? _OutlineColor : fixed4(_Color *texColor.rgb * lightsum, 1);
				
			}
			ENDCG
		}
		
	}
	FallBack "Mobile/Diffuse"
}
