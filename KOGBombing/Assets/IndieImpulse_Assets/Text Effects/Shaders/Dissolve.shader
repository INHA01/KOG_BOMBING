Shader "IndieImpulse/Unlit/Dissolve"
{
    Properties
    {
        [NoScaleOffset]_MainTexure("MainTexure", 2D) = "white" {}
        _DissolveAmount("DissolveAmount", Range(0, 1)) = 0.5
        _OutlineThickness("OutlineThickness", Range(0, 1)) = 0.1
        _DissolveScale("DissolveScale", Range(0, 500)) = 30
        [HDR]_OutlineColor("OutlineColor", Color) = (0, 0, 0, 0)
        [NoScaleOffset]_Mask("Mask", 2D) = "white" {}
        [HDR]_Color("Color", Color) = (0, 0, 0, 0)
        _Width("Width", Float) = -0.01
        _Speed("Speed", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            output.interp3.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexure_TexelSize;
        float _DissolveAmount;
        float _OutlineThickness;
        float _DissolveScale;
        float4 _OutlineColor;
        float4 _Mask_TexelSize;
        float4 _Color;
        float _Width;
        float _Speed;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexure);
        SAMPLER(sampler_MainTexure);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_SampleGradientV1_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < Gradient.colorsLength; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifdef UNITY_COLORSPACE_GAMMA
            color = LinearToSRGB(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < Gradient.alphasLength; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a - 1].y) / (Gradient.alphas[a].y - Gradient.alphas[a - 1].y)) * step(a, Gradient.alphasLength - 1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Rectangle_Fastest_float(float2 UV, float Width, float Height, out float Out)
        {
            float2 d = abs(UV * 2 - 1) - float2(Width, Height);
        #if defined(SHADER_STAGE_RAY_TRACING)
            d = saturate((1 - saturate(d * 1e7)));
        #else
            d = saturate(1 - d / fwidth(d));
        #endif
            Out = min(d.x, d.y);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexure);
            float4 _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.tex, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.samplerstate, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_R_4 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.r;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_G_5 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.g;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_B_6 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.b;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_A_7 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.a;
            float4 _Property_4ac38d7f7f62415b97645e631b345ba8_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
            float4 _Multiply_c0f33db78e7d46e5947a3c032f438992_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Property_4ac38d7f7f62415b97645e631b345ba8_Out_0, _Multiply_c0f33db78e7d46e5947a3c032f438992_Out_2);
            UnityTexture2D _Property_b472a836ec5f4871a294a78220f5eb07_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0 = _Speed;
            float _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _Vector2_25bac9fb598946de910318698c573f6a_Out_0 = float2(0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_25bac9fb598946de910318698c573f6a_Out_0, _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3);
            float4 _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b472a836ec5f4871a294a78220f5eb07_Out_0.tex, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.samplerstate, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.GetTransformedUV(_TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3));
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_R_4 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.r;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_G_5 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.g;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_B_6 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.b;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_A_7 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.a;
            float _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0 = _Width;
            float _Multiply_8226381011c64bab92a3f6445c001be6_Out_2;
            Unity_Multiply_float_float(_Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 0.9, _Multiply_8226381011c64bab92a3f6445c001be6_Out_2);
            float _Property_c63414226d0d4120a635c6a6937eb05d_Out_0 = _DissolveAmount;
            float _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2;
            Unity_Multiply_float_float(_Multiply_8226381011c64bab92a3f6445c001be6_Out_2, _Property_c63414226d0d4120a635c6a6937eb05d_Out_0, _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2);
            float _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1;
            Unity_OneMinus_float(_Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2, _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1);
            float _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0 = _OutlineThickness;
            float _Add_0183421596364a6394286bf2daa81501_Out_2;
            Unity_Add_float(_OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1, _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0, _Add_0183421596364a6394286bf2daa81501_Out_2);
            float4 _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2;
            Unity_Step_float4(_SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0, (_Add_0183421596364a6394286bf2daa81501_Out_2.xxxx), _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2);
            float4 _Step_ac5dfd1ef79644a68d63e072cffbab2e_Out_2;
            Unity_Step_float4(_SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0, (_OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1.xxxx), _Step_ac5dfd1ef79644a68d63e072cffbab2e_Out_2);
            float4 _Subtract_a02461f92df742599802b9f4be3b7778_Out_2;
            Unity_Subtract_float4(_Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2, _Step_ac5dfd1ef79644a68d63e072cffbab2e_Out_2, _Subtract_a02461f92df742599802b9f4be3b7778_Out_2);
            float4 _Subtract_01cb3a0df5a046a1bdcc5c2a53578127_Out_2;
            Unity_Subtract_float4(_Multiply_c0f33db78e7d46e5947a3c032f438992_Out_2, _Subtract_a02461f92df742599802b9f4be3b7778_Out_2, _Subtract_01cb3a0df5a046a1bdcc5c2a53578127_Out_2);
            float4 _Property_c4ccf1008b9948e183ada99bfaac0d09_Out_0 = IsGammaSpace() ? LinearToSRGB(_OutlineColor) : _OutlineColor;
            float4 _Multiply_df229b36db2b4d3e8792af6391694015_Out_2;
            Unity_Multiply_float4_float4(_Subtract_a02461f92df742599802b9f4be3b7778_Out_2, _Property_c4ccf1008b9948e183ada99bfaac0d09_Out_0, _Multiply_df229b36db2b4d3e8792af6391694015_Out_2);
            float4 _Add_b37feeb3701c4e6d8e60a7e838c1cdbb_Out_2;
            Unity_Add_float4(_Subtract_01cb3a0df5a046a1bdcc5c2a53578127_Out_2, _Multiply_df229b36db2b4d3e8792af6391694015_Out_2, _Add_b37feeb3701c4e6d8e60a7e838c1cdbb_Out_2);
            float4 _SampleGradient_8541697807b2446dbe3b467321191095_Out_2;
            Unity_SampleGradientV1_float(NewGradient(0, 5, 2, float4(0, 0, 0, 0),float4(0.2, 0.2, 0.2, 0.2235294),float4(1, 1, 1, 0.5058824),float4(0.1981132, 0.1981132, 0.1981132, 0.8382391),float4(0, 0, 0, 1),float4(0, 0, 0, 0),float4(0, 0, 0, 0),float4(0, 0, 0, 0), float2(1, 0),float2(1, 1),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0)), _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, _SampleGradient_8541697807b2446dbe3b467321191095_Out_2);
            float4 _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1;
            Unity_OneMinus_float4(_SampleGradient_8541697807b2446dbe3b467321191095_Out_2, _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1);
            float2 _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3);
            float _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3;
            Unity_Rectangle_Fastest_float(_TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3, _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 1, _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3);
            float4 _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2;
            Unity_Multiply_float4_float4(_OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1, (_Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3.xxxx), _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2);
            float4 _Multiply_3ea76396dc904389b74b40d4d2c90376_Out_2;
            Unity_Multiply_float4_float4(_Add_b37feeb3701c4e6d8e60a7e838c1cdbb_Out_2, _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2, _Multiply_3ea76396dc904389b74b40d4d2c90376_Out_2);
            float4 _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2, _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2);
            float4 _Multiply_e508ba038e3541ad80d34830566710b3_Out_2;
            Unity_Multiply_float4_float4(_Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2, _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2, _Multiply_e508ba038e3541ad80d34830566710b3_Out_2);
            surface.BaseColor = (_Multiply_3ea76396dc904389b74b40d4d2c90376_Out_2.xyz);
            surface.Alpha = (_Multiply_e508ba038e3541ad80d34830566710b3_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexure_TexelSize;
        float _DissolveAmount;
        float _OutlineThickness;
        float _DissolveScale;
        float4 _OutlineColor;
        float4 _Mask_TexelSize;
        float4 _Color;
        float _Width;
        float _Speed;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexure);
        SAMPLER(sampler_MainTexure);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SampleGradientV1_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < Gradient.colorsLength; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifdef UNITY_COLORSPACE_GAMMA
            color = LinearToSRGB(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < Gradient.alphasLength; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a - 1].y) / (Gradient.alphas[a].y - Gradient.alphas[a - 1].y)) * step(a, Gradient.alphasLength - 1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Rectangle_Fastest_float(float2 UV, float Width, float Height, out float Out)
        {
            float2 d = abs(UV * 2 - 1) - float2(Width, Height);
        #if defined(SHADER_STAGE_RAY_TRACING)
            d = saturate((1 - saturate(d * 1e7)));
        #else
            d = saturate(1 - d / fwidth(d));
        #endif
            Out = min(d.x, d.y);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexure);
            float4 _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.tex, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.samplerstate, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_R_4 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.r;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_G_5 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.g;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_B_6 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.b;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_A_7 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.a;
            UnityTexture2D _Property_b472a836ec5f4871a294a78220f5eb07_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0 = _Speed;
            float _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _Vector2_25bac9fb598946de910318698c573f6a_Out_0 = float2(0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_25bac9fb598946de910318698c573f6a_Out_0, _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3);
            float4 _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b472a836ec5f4871a294a78220f5eb07_Out_0.tex, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.samplerstate, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.GetTransformedUV(_TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3));
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_R_4 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.r;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_G_5 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.g;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_B_6 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.b;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_A_7 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.a;
            float _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0 = _Width;
            float _Multiply_8226381011c64bab92a3f6445c001be6_Out_2;
            Unity_Multiply_float_float(_Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 0.9, _Multiply_8226381011c64bab92a3f6445c001be6_Out_2);
            float _Property_c63414226d0d4120a635c6a6937eb05d_Out_0 = _DissolveAmount;
            float _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2;
            Unity_Multiply_float_float(_Multiply_8226381011c64bab92a3f6445c001be6_Out_2, _Property_c63414226d0d4120a635c6a6937eb05d_Out_0, _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2);
            float _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1;
            Unity_OneMinus_float(_Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2, _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1);
            float _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0 = _OutlineThickness;
            float _Add_0183421596364a6394286bf2daa81501_Out_2;
            Unity_Add_float(_OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1, _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0, _Add_0183421596364a6394286bf2daa81501_Out_2);
            float4 _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2;
            Unity_Step_float4(_SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0, (_Add_0183421596364a6394286bf2daa81501_Out_2.xxxx), _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2);
            float4 _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2, _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2);
            float4 _SampleGradient_8541697807b2446dbe3b467321191095_Out_2;
            Unity_SampleGradientV1_float(NewGradient(0, 5, 2, float4(0, 0, 0, 0),float4(0.2, 0.2, 0.2, 0.2235294),float4(1, 1, 1, 0.5058824),float4(0.1981132, 0.1981132, 0.1981132, 0.8382391),float4(0, 0, 0, 1),float4(0, 0, 0, 0),float4(0, 0, 0, 0),float4(0, 0, 0, 0), float2(1, 0),float2(1, 1),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0)), _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, _SampleGradient_8541697807b2446dbe3b467321191095_Out_2);
            float4 _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1;
            Unity_OneMinus_float4(_SampleGradient_8541697807b2446dbe3b467321191095_Out_2, _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1);
            float2 _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3);
            float _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3;
            Unity_Rectangle_Fastest_float(_TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3, _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 1, _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3);
            float4 _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2;
            Unity_Multiply_float4_float4(_OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1, (_Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3.xxxx), _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2);
            float4 _Multiply_e508ba038e3541ad80d34830566710b3_Out_2;
            Unity_Multiply_float4_float4(_Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2, _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2, _Multiply_e508ba038e3541ad80d34830566710b3_Out_2);
            surface.Alpha = (_Multiply_e508ba038e3541ad80d34830566710b3_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexure_TexelSize;
        float _DissolveAmount;
        float _OutlineThickness;
        float _DissolveScale;
        float4 _OutlineColor;
        float4 _Mask_TexelSize;
        float4 _Color;
        float _Width;
        float _Speed;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexure);
        SAMPLER(sampler_MainTexure);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SampleGradientV1_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < Gradient.colorsLength; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifdef UNITY_COLORSPACE_GAMMA
            color = LinearToSRGB(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < Gradient.alphasLength; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a - 1].y) / (Gradient.alphas[a].y - Gradient.alphas[a - 1].y)) * step(a, Gradient.alphasLength - 1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Rectangle_Fastest_float(float2 UV, float Width, float Height, out float Out)
        {
            float2 d = abs(UV * 2 - 1) - float2(Width, Height);
        #if defined(SHADER_STAGE_RAY_TRACING)
            d = saturate((1 - saturate(d * 1e7)));
        #else
            d = saturate(1 - d / fwidth(d));
        #endif
            Out = min(d.x, d.y);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexure);
            float4 _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.tex, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.samplerstate, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_R_4 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.r;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_G_5 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.g;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_B_6 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.b;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_A_7 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.a;
            UnityTexture2D _Property_b472a836ec5f4871a294a78220f5eb07_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0 = _Speed;
            float _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _Vector2_25bac9fb598946de910318698c573f6a_Out_0 = float2(0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_25bac9fb598946de910318698c573f6a_Out_0, _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3);
            float4 _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b472a836ec5f4871a294a78220f5eb07_Out_0.tex, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.samplerstate, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.GetTransformedUV(_TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3));
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_R_4 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.r;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_G_5 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.g;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_B_6 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.b;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_A_7 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.a;
            float _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0 = _Width;
            float _Multiply_8226381011c64bab92a3f6445c001be6_Out_2;
            Unity_Multiply_float_float(_Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 0.9, _Multiply_8226381011c64bab92a3f6445c001be6_Out_2);
            float _Property_c63414226d0d4120a635c6a6937eb05d_Out_0 = _DissolveAmount;
            float _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2;
            Unity_Multiply_float_float(_Multiply_8226381011c64bab92a3f6445c001be6_Out_2, _Property_c63414226d0d4120a635c6a6937eb05d_Out_0, _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2);
            float _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1;
            Unity_OneMinus_float(_Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2, _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1);
            float _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0 = _OutlineThickness;
            float _Add_0183421596364a6394286bf2daa81501_Out_2;
            Unity_Add_float(_OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1, _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0, _Add_0183421596364a6394286bf2daa81501_Out_2);
            float4 _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2;
            Unity_Step_float4(_SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0, (_Add_0183421596364a6394286bf2daa81501_Out_2.xxxx), _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2);
            float4 _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2, _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2);
            float4 _SampleGradient_8541697807b2446dbe3b467321191095_Out_2;
            Unity_SampleGradientV1_float(NewGradient(0, 5, 2, float4(0, 0, 0, 0),float4(0.2, 0.2, 0.2, 0.2235294),float4(1, 1, 1, 0.5058824),float4(0.1981132, 0.1981132, 0.1981132, 0.8382391),float4(0, 0, 0, 1),float4(0, 0, 0, 0),float4(0, 0, 0, 0),float4(0, 0, 0, 0), float2(1, 0),float2(1, 1),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0)), _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, _SampleGradient_8541697807b2446dbe3b467321191095_Out_2);
            float4 _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1;
            Unity_OneMinus_float4(_SampleGradient_8541697807b2446dbe3b467321191095_Out_2, _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1);
            float2 _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3);
            float _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3;
            Unity_Rectangle_Fastest_float(_TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3, _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 1, _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3);
            float4 _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2;
            Unity_Multiply_float4_float4(_OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1, (_Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3.xxxx), _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2);
            float4 _Multiply_e508ba038e3541ad80d34830566710b3_Out_2;
            Unity_Multiply_float4_float4(_Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2, _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2, _Multiply_e508ba038e3541ad80d34830566710b3_Out_2);
            surface.Alpha = (_Multiply_e508ba038e3541ad80d34830566710b3_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexure_TexelSize;
        float _DissolveAmount;
        float _OutlineThickness;
        float _DissolveScale;
        float4 _OutlineColor;
        float4 _Mask_TexelSize;
        float4 _Color;
        float _Width;
        float _Speed;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexure);
        SAMPLER(sampler_MainTexure);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SampleGradientV1_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < Gradient.colorsLength; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifdef UNITY_COLORSPACE_GAMMA
            color = LinearToSRGB(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < Gradient.alphasLength; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a - 1].y) / (Gradient.alphas[a].y - Gradient.alphas[a - 1].y)) * step(a, Gradient.alphasLength - 1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Rectangle_Fastest_float(float2 UV, float Width, float Height, out float Out)
        {
            float2 d = abs(UV * 2 - 1) - float2(Width, Height);
        #if defined(SHADER_STAGE_RAY_TRACING)
            d = saturate((1 - saturate(d * 1e7)));
        #else
            d = saturate(1 - d / fwidth(d));
        #endif
            Out = min(d.x, d.y);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexure);
            float4 _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.tex, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.samplerstate, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_R_4 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.r;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_G_5 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.g;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_B_6 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.b;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_A_7 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.a;
            UnityTexture2D _Property_b472a836ec5f4871a294a78220f5eb07_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0 = _Speed;
            float _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _Vector2_25bac9fb598946de910318698c573f6a_Out_0 = float2(0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_25bac9fb598946de910318698c573f6a_Out_0, _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3);
            float4 _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b472a836ec5f4871a294a78220f5eb07_Out_0.tex, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.samplerstate, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.GetTransformedUV(_TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3));
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_R_4 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.r;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_G_5 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.g;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_B_6 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.b;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_A_7 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.a;
            float _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0 = _Width;
            float _Multiply_8226381011c64bab92a3f6445c001be6_Out_2;
            Unity_Multiply_float_float(_Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 0.9, _Multiply_8226381011c64bab92a3f6445c001be6_Out_2);
            float _Property_c63414226d0d4120a635c6a6937eb05d_Out_0 = _DissolveAmount;
            float _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2;
            Unity_Multiply_float_float(_Multiply_8226381011c64bab92a3f6445c001be6_Out_2, _Property_c63414226d0d4120a635c6a6937eb05d_Out_0, _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2);
            float _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1;
            Unity_OneMinus_float(_Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2, _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1);
            float _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0 = _OutlineThickness;
            float _Add_0183421596364a6394286bf2daa81501_Out_2;
            Unity_Add_float(_OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1, _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0, _Add_0183421596364a6394286bf2daa81501_Out_2);
            float4 _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2;
            Unity_Step_float4(_SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0, (_Add_0183421596364a6394286bf2daa81501_Out_2.xxxx), _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2);
            float4 _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2, _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2);
            float4 _SampleGradient_8541697807b2446dbe3b467321191095_Out_2;
            Unity_SampleGradientV1_float(NewGradient(0, 5, 2, float4(0, 0, 0, 0),float4(0.2, 0.2, 0.2, 0.2235294),float4(1, 1, 1, 0.5058824),float4(0.1981132, 0.1981132, 0.1981132, 0.8382391),float4(0, 0, 0, 1),float4(0, 0, 0, 0),float4(0, 0, 0, 0),float4(0, 0, 0, 0), float2(1, 0),float2(1, 1),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0)), _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, _SampleGradient_8541697807b2446dbe3b467321191095_Out_2);
            float4 _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1;
            Unity_OneMinus_float4(_SampleGradient_8541697807b2446dbe3b467321191095_Out_2, _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1);
            float2 _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3);
            float _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3;
            Unity_Rectangle_Fastest_float(_TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3, _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 1, _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3);
            float4 _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2;
            Unity_Multiply_float4_float4(_OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1, (_Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3.xxxx), _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2);
            float4 _Multiply_e508ba038e3541ad80d34830566710b3_Out_2;
            Unity_Multiply_float4_float4(_Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2, _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2, _Multiply_e508ba038e3541ad80d34830566710b3_Out_2);
            surface.Alpha = (_Multiply_e508ba038e3541ad80d34830566710b3_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexure_TexelSize;
        float _DissolveAmount;
        float _OutlineThickness;
        float _DissolveScale;
        float4 _OutlineColor;
        float4 _Mask_TexelSize;
        float4 _Color;
        float _Width;
        float _Speed;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexure);
        SAMPLER(sampler_MainTexure);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SampleGradientV1_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < Gradient.colorsLength; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifdef UNITY_COLORSPACE_GAMMA
            color = LinearToSRGB(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < Gradient.alphasLength; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a - 1].y) / (Gradient.alphas[a].y - Gradient.alphas[a - 1].y)) * step(a, Gradient.alphasLength - 1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Rectangle_Fastest_float(float2 UV, float Width, float Height, out float Out)
        {
            float2 d = abs(UV * 2 - 1) - float2(Width, Height);
        #if defined(SHADER_STAGE_RAY_TRACING)
            d = saturate((1 - saturate(d * 1e7)));
        #else
            d = saturate(1 - d / fwidth(d));
        #endif
            Out = min(d.x, d.y);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexure);
            float4 _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.tex, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.samplerstate, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_R_4 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.r;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_G_5 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.g;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_B_6 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.b;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_A_7 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.a;
            UnityTexture2D _Property_b472a836ec5f4871a294a78220f5eb07_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0 = _Speed;
            float _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _Vector2_25bac9fb598946de910318698c573f6a_Out_0 = float2(0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_25bac9fb598946de910318698c573f6a_Out_0, _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3);
            float4 _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b472a836ec5f4871a294a78220f5eb07_Out_0.tex, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.samplerstate, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.GetTransformedUV(_TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3));
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_R_4 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.r;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_G_5 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.g;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_B_6 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.b;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_A_7 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.a;
            float _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0 = _Width;
            float _Multiply_8226381011c64bab92a3f6445c001be6_Out_2;
            Unity_Multiply_float_float(_Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 0.9, _Multiply_8226381011c64bab92a3f6445c001be6_Out_2);
            float _Property_c63414226d0d4120a635c6a6937eb05d_Out_0 = _DissolveAmount;
            float _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2;
            Unity_Multiply_float_float(_Multiply_8226381011c64bab92a3f6445c001be6_Out_2, _Property_c63414226d0d4120a635c6a6937eb05d_Out_0, _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2);
            float _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1;
            Unity_OneMinus_float(_Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2, _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1);
            float _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0 = _OutlineThickness;
            float _Add_0183421596364a6394286bf2daa81501_Out_2;
            Unity_Add_float(_OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1, _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0, _Add_0183421596364a6394286bf2daa81501_Out_2);
            float4 _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2;
            Unity_Step_float4(_SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0, (_Add_0183421596364a6394286bf2daa81501_Out_2.xxxx), _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2);
            float4 _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2, _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2);
            float4 _SampleGradient_8541697807b2446dbe3b467321191095_Out_2;
            Unity_SampleGradientV1_float(NewGradient(0, 5, 2, float4(0, 0, 0, 0),float4(0.2, 0.2, 0.2, 0.2235294),float4(1, 1, 1, 0.5058824),float4(0.1981132, 0.1981132, 0.1981132, 0.8382391),float4(0, 0, 0, 1),float4(0, 0, 0, 0),float4(0, 0, 0, 0),float4(0, 0, 0, 0), float2(1, 0),float2(1, 1),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0)), _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, _SampleGradient_8541697807b2446dbe3b467321191095_Out_2);
            float4 _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1;
            Unity_OneMinus_float4(_SampleGradient_8541697807b2446dbe3b467321191095_Out_2, _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1);
            float2 _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3);
            float _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3;
            Unity_Rectangle_Fastest_float(_TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3, _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 1, _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3);
            float4 _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2;
            Unity_Multiply_float4_float4(_OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1, (_Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3.xxxx), _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2);
            float4 _Multiply_e508ba038e3541ad80d34830566710b3_Out_2;
            Unity_Multiply_float4_float4(_Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2, _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2, _Multiply_e508ba038e3541ad80d34830566710b3_Out_2);
            surface.Alpha = (_Multiply_e508ba038e3541ad80d34830566710b3_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define _SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexure_TexelSize;
        float _DissolveAmount;
        float _OutlineThickness;
        float _DissolveScale;
        float4 _OutlineColor;
        float4 _Mask_TexelSize;
        float4 _Color;
        float _Width;
        float _Speed;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexure);
        SAMPLER(sampler_MainTexure);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SampleGradientV1_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < Gradient.colorsLength; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifdef UNITY_COLORSPACE_GAMMA
            color = LinearToSRGB(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < Gradient.alphasLength; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a - 1].y) / (Gradient.alphas[a].y - Gradient.alphas[a - 1].y)) * step(a, Gradient.alphasLength - 1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Rectangle_Fastest_float(float2 UV, float Width, float Height, out float Out)
        {
            float2 d = abs(UV * 2 - 1) - float2(Width, Height);
        #if defined(SHADER_STAGE_RAY_TRACING)
            d = saturate((1 - saturate(d * 1e7)));
        #else
            d = saturate(1 - d / fwidth(d));
        #endif
            Out = min(d.x, d.y);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexure);
            float4 _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.tex, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.samplerstate, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_R_4 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.r;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_G_5 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.g;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_B_6 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.b;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_A_7 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.a;
            UnityTexture2D _Property_b472a836ec5f4871a294a78220f5eb07_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0 = _Speed;
            float _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _Vector2_25bac9fb598946de910318698c573f6a_Out_0 = float2(0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_25bac9fb598946de910318698c573f6a_Out_0, _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3);
            float4 _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b472a836ec5f4871a294a78220f5eb07_Out_0.tex, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.samplerstate, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.GetTransformedUV(_TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3));
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_R_4 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.r;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_G_5 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.g;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_B_6 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.b;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_A_7 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.a;
            float _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0 = _Width;
            float _Multiply_8226381011c64bab92a3f6445c001be6_Out_2;
            Unity_Multiply_float_float(_Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 0.9, _Multiply_8226381011c64bab92a3f6445c001be6_Out_2);
            float _Property_c63414226d0d4120a635c6a6937eb05d_Out_0 = _DissolveAmount;
            float _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2;
            Unity_Multiply_float_float(_Multiply_8226381011c64bab92a3f6445c001be6_Out_2, _Property_c63414226d0d4120a635c6a6937eb05d_Out_0, _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2);
            float _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1;
            Unity_OneMinus_float(_Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2, _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1);
            float _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0 = _OutlineThickness;
            float _Add_0183421596364a6394286bf2daa81501_Out_2;
            Unity_Add_float(_OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1, _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0, _Add_0183421596364a6394286bf2daa81501_Out_2);
            float4 _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2;
            Unity_Step_float4(_SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0, (_Add_0183421596364a6394286bf2daa81501_Out_2.xxxx), _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2);
            float4 _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2, _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2);
            float4 _SampleGradient_8541697807b2446dbe3b467321191095_Out_2;
            Unity_SampleGradientV1_float(NewGradient(0, 5, 2, float4(0, 0, 0, 0),float4(0.2, 0.2, 0.2, 0.2235294),float4(1, 1, 1, 0.5058824),float4(0.1981132, 0.1981132, 0.1981132, 0.8382391),float4(0, 0, 0, 1),float4(0, 0, 0, 0),float4(0, 0, 0, 0),float4(0, 0, 0, 0), float2(1, 0),float2(1, 1),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0)), _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, _SampleGradient_8541697807b2446dbe3b467321191095_Out_2);
            float4 _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1;
            Unity_OneMinus_float4(_SampleGradient_8541697807b2446dbe3b467321191095_Out_2, _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1);
            float2 _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3);
            float _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3;
            Unity_Rectangle_Fastest_float(_TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3, _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 1, _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3);
            float4 _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2;
            Unity_Multiply_float4_float4(_OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1, (_Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3.xxxx), _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2);
            float4 _Multiply_e508ba038e3541ad80d34830566710b3_Out_2;
            Unity_Multiply_float4_float4(_Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2, _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2, _Multiply_e508ba038e3541ad80d34830566710b3_Out_2);
            surface.Alpha = (_Multiply_e508ba038e3541ad80d34830566710b3_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            output.interp3.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexure_TexelSize;
        float _DissolveAmount;
        float _OutlineThickness;
        float _DissolveScale;
        float4 _OutlineColor;
        float4 _Mask_TexelSize;
        float4 _Color;
        float _Width;
        float _Speed;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexure);
        SAMPLER(sampler_MainTexure);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_SampleGradientV1_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < Gradient.colorsLength; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifdef UNITY_COLORSPACE_GAMMA
            color = LinearToSRGB(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < Gradient.alphasLength; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a - 1].y) / (Gradient.alphas[a].y - Gradient.alphas[a - 1].y)) * step(a, Gradient.alphasLength - 1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Rectangle_Fastest_float(float2 UV, float Width, float Height, out float Out)
        {
            float2 d = abs(UV * 2 - 1) - float2(Width, Height);
        #if defined(SHADER_STAGE_RAY_TRACING)
            d = saturate((1 - saturate(d * 1e7)));
        #else
            d = saturate(1 - d / fwidth(d));
        #endif
            Out = min(d.x, d.y);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexure);
            float4 _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.tex, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.samplerstate, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_R_4 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.r;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_G_5 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.g;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_B_6 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.b;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_A_7 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.a;
            float4 _Property_4ac38d7f7f62415b97645e631b345ba8_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
            float4 _Multiply_c0f33db78e7d46e5947a3c032f438992_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Property_4ac38d7f7f62415b97645e631b345ba8_Out_0, _Multiply_c0f33db78e7d46e5947a3c032f438992_Out_2);
            UnityTexture2D _Property_b472a836ec5f4871a294a78220f5eb07_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0 = _Speed;
            float _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _Vector2_25bac9fb598946de910318698c573f6a_Out_0 = float2(0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_25bac9fb598946de910318698c573f6a_Out_0, _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3);
            float4 _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b472a836ec5f4871a294a78220f5eb07_Out_0.tex, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.samplerstate, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.GetTransformedUV(_TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3));
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_R_4 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.r;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_G_5 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.g;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_B_6 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.b;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_A_7 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.a;
            float _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0 = _Width;
            float _Multiply_8226381011c64bab92a3f6445c001be6_Out_2;
            Unity_Multiply_float_float(_Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 0.9, _Multiply_8226381011c64bab92a3f6445c001be6_Out_2);
            float _Property_c63414226d0d4120a635c6a6937eb05d_Out_0 = _DissolveAmount;
            float _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2;
            Unity_Multiply_float_float(_Multiply_8226381011c64bab92a3f6445c001be6_Out_2, _Property_c63414226d0d4120a635c6a6937eb05d_Out_0, _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2);
            float _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1;
            Unity_OneMinus_float(_Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2, _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1);
            float _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0 = _OutlineThickness;
            float _Add_0183421596364a6394286bf2daa81501_Out_2;
            Unity_Add_float(_OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1, _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0, _Add_0183421596364a6394286bf2daa81501_Out_2);
            float4 _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2;
            Unity_Step_float4(_SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0, (_Add_0183421596364a6394286bf2daa81501_Out_2.xxxx), _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2);
            float4 _Step_ac5dfd1ef79644a68d63e072cffbab2e_Out_2;
            Unity_Step_float4(_SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0, (_OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1.xxxx), _Step_ac5dfd1ef79644a68d63e072cffbab2e_Out_2);
            float4 _Subtract_a02461f92df742599802b9f4be3b7778_Out_2;
            Unity_Subtract_float4(_Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2, _Step_ac5dfd1ef79644a68d63e072cffbab2e_Out_2, _Subtract_a02461f92df742599802b9f4be3b7778_Out_2);
            float4 _Subtract_01cb3a0df5a046a1bdcc5c2a53578127_Out_2;
            Unity_Subtract_float4(_Multiply_c0f33db78e7d46e5947a3c032f438992_Out_2, _Subtract_a02461f92df742599802b9f4be3b7778_Out_2, _Subtract_01cb3a0df5a046a1bdcc5c2a53578127_Out_2);
            float4 _Property_c4ccf1008b9948e183ada99bfaac0d09_Out_0 = IsGammaSpace() ? LinearToSRGB(_OutlineColor) : _OutlineColor;
            float4 _Multiply_df229b36db2b4d3e8792af6391694015_Out_2;
            Unity_Multiply_float4_float4(_Subtract_a02461f92df742599802b9f4be3b7778_Out_2, _Property_c4ccf1008b9948e183ada99bfaac0d09_Out_0, _Multiply_df229b36db2b4d3e8792af6391694015_Out_2);
            float4 _Add_b37feeb3701c4e6d8e60a7e838c1cdbb_Out_2;
            Unity_Add_float4(_Subtract_01cb3a0df5a046a1bdcc5c2a53578127_Out_2, _Multiply_df229b36db2b4d3e8792af6391694015_Out_2, _Add_b37feeb3701c4e6d8e60a7e838c1cdbb_Out_2);
            float4 _SampleGradient_8541697807b2446dbe3b467321191095_Out_2;
            Unity_SampleGradientV1_float(NewGradient(0, 5, 2, float4(0, 0, 0, 0),float4(0.2, 0.2, 0.2, 0.2235294),float4(1, 1, 1, 0.5058824),float4(0.1981132, 0.1981132, 0.1981132, 0.8382391),float4(0, 0, 0, 1),float4(0, 0, 0, 0),float4(0, 0, 0, 0),float4(0, 0, 0, 0), float2(1, 0),float2(1, 1),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0)), _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, _SampleGradient_8541697807b2446dbe3b467321191095_Out_2);
            float4 _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1;
            Unity_OneMinus_float4(_SampleGradient_8541697807b2446dbe3b467321191095_Out_2, _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1);
            float2 _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3);
            float _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3;
            Unity_Rectangle_Fastest_float(_TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3, _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 1, _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3);
            float4 _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2;
            Unity_Multiply_float4_float4(_OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1, (_Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3.xxxx), _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2);
            float4 _Multiply_3ea76396dc904389b74b40d4d2c90376_Out_2;
            Unity_Multiply_float4_float4(_Add_b37feeb3701c4e6d8e60a7e838c1cdbb_Out_2, _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2, _Multiply_3ea76396dc904389b74b40d4d2c90376_Out_2);
            float4 _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2, _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2);
            float4 _Multiply_e508ba038e3541ad80d34830566710b3_Out_2;
            Unity_Multiply_float4_float4(_Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2, _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2, _Multiply_e508ba038e3541ad80d34830566710b3_Out_2);
            surface.BaseColor = (_Multiply_3ea76396dc904389b74b40d4d2c90376_Out_2.xyz);
            surface.Alpha = (_Multiply_e508ba038e3541ad80d34830566710b3_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexure_TexelSize;
        float _DissolveAmount;
        float _OutlineThickness;
        float _DissolveScale;
        float4 _OutlineColor;
        float4 _Mask_TexelSize;
        float4 _Color;
        float _Width;
        float _Speed;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexure);
        SAMPLER(sampler_MainTexure);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SampleGradientV1_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < Gradient.colorsLength; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifdef UNITY_COLORSPACE_GAMMA
            color = LinearToSRGB(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < Gradient.alphasLength; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a - 1].y) / (Gradient.alphas[a].y - Gradient.alphas[a - 1].y)) * step(a, Gradient.alphasLength - 1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Rectangle_Fastest_float(float2 UV, float Width, float Height, out float Out)
        {
            float2 d = abs(UV * 2 - 1) - float2(Width, Height);
        #if defined(SHADER_STAGE_RAY_TRACING)
            d = saturate((1 - saturate(d * 1e7)));
        #else
            d = saturate(1 - d / fwidth(d));
        #endif
            Out = min(d.x, d.y);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexure);
            float4 _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.tex, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.samplerstate, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_R_4 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.r;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_G_5 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.g;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_B_6 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.b;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_A_7 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.a;
            UnityTexture2D _Property_b472a836ec5f4871a294a78220f5eb07_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0 = _Speed;
            float _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _Vector2_25bac9fb598946de910318698c573f6a_Out_0 = float2(0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_25bac9fb598946de910318698c573f6a_Out_0, _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3);
            float4 _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b472a836ec5f4871a294a78220f5eb07_Out_0.tex, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.samplerstate, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.GetTransformedUV(_TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3));
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_R_4 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.r;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_G_5 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.g;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_B_6 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.b;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_A_7 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.a;
            float _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0 = _Width;
            float _Multiply_8226381011c64bab92a3f6445c001be6_Out_2;
            Unity_Multiply_float_float(_Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 0.9, _Multiply_8226381011c64bab92a3f6445c001be6_Out_2);
            float _Property_c63414226d0d4120a635c6a6937eb05d_Out_0 = _DissolveAmount;
            float _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2;
            Unity_Multiply_float_float(_Multiply_8226381011c64bab92a3f6445c001be6_Out_2, _Property_c63414226d0d4120a635c6a6937eb05d_Out_0, _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2);
            float _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1;
            Unity_OneMinus_float(_Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2, _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1);
            float _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0 = _OutlineThickness;
            float _Add_0183421596364a6394286bf2daa81501_Out_2;
            Unity_Add_float(_OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1, _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0, _Add_0183421596364a6394286bf2daa81501_Out_2);
            float4 _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2;
            Unity_Step_float4(_SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0, (_Add_0183421596364a6394286bf2daa81501_Out_2.xxxx), _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2);
            float4 _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2, _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2);
            float4 _SampleGradient_8541697807b2446dbe3b467321191095_Out_2;
            Unity_SampleGradientV1_float(NewGradient(0, 5, 2, float4(0, 0, 0, 0),float4(0.2, 0.2, 0.2, 0.2235294),float4(1, 1, 1, 0.5058824),float4(0.1981132, 0.1981132, 0.1981132, 0.8382391),float4(0, 0, 0, 1),float4(0, 0, 0, 0),float4(0, 0, 0, 0),float4(0, 0, 0, 0), float2(1, 0),float2(1, 1),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0)), _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, _SampleGradient_8541697807b2446dbe3b467321191095_Out_2);
            float4 _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1;
            Unity_OneMinus_float4(_SampleGradient_8541697807b2446dbe3b467321191095_Out_2, _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1);
            float2 _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3);
            float _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3;
            Unity_Rectangle_Fastest_float(_TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3, _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 1, _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3);
            float4 _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2;
            Unity_Multiply_float4_float4(_OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1, (_Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3.xxxx), _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2);
            float4 _Multiply_e508ba038e3541ad80d34830566710b3_Out_2;
            Unity_Multiply_float4_float4(_Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2, _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2, _Multiply_e508ba038e3541ad80d34830566710b3_Out_2);
            surface.Alpha = (_Multiply_e508ba038e3541ad80d34830566710b3_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexure_TexelSize;
        float _DissolveAmount;
        float _OutlineThickness;
        float _DissolveScale;
        float4 _OutlineColor;
        float4 _Mask_TexelSize;
        float4 _Color;
        float _Width;
        float _Speed;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexure);
        SAMPLER(sampler_MainTexure);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SampleGradientV1_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < Gradient.colorsLength; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifdef UNITY_COLORSPACE_GAMMA
            color = LinearToSRGB(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < Gradient.alphasLength; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a - 1].y) / (Gradient.alphas[a].y - Gradient.alphas[a - 1].y)) * step(a, Gradient.alphasLength - 1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Rectangle_Fastest_float(float2 UV, float Width, float Height, out float Out)
        {
            float2 d = abs(UV * 2 - 1) - float2(Width, Height);
        #if defined(SHADER_STAGE_RAY_TRACING)
            d = saturate((1 - saturate(d * 1e7)));
        #else
            d = saturate(1 - d / fwidth(d));
        #endif
            Out = min(d.x, d.y);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexure);
            float4 _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.tex, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.samplerstate, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_R_4 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.r;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_G_5 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.g;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_B_6 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.b;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_A_7 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.a;
            UnityTexture2D _Property_b472a836ec5f4871a294a78220f5eb07_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0 = _Speed;
            float _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _Vector2_25bac9fb598946de910318698c573f6a_Out_0 = float2(0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_25bac9fb598946de910318698c573f6a_Out_0, _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3);
            float4 _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b472a836ec5f4871a294a78220f5eb07_Out_0.tex, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.samplerstate, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.GetTransformedUV(_TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3));
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_R_4 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.r;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_G_5 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.g;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_B_6 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.b;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_A_7 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.a;
            float _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0 = _Width;
            float _Multiply_8226381011c64bab92a3f6445c001be6_Out_2;
            Unity_Multiply_float_float(_Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 0.9, _Multiply_8226381011c64bab92a3f6445c001be6_Out_2);
            float _Property_c63414226d0d4120a635c6a6937eb05d_Out_0 = _DissolveAmount;
            float _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2;
            Unity_Multiply_float_float(_Multiply_8226381011c64bab92a3f6445c001be6_Out_2, _Property_c63414226d0d4120a635c6a6937eb05d_Out_0, _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2);
            float _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1;
            Unity_OneMinus_float(_Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2, _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1);
            float _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0 = _OutlineThickness;
            float _Add_0183421596364a6394286bf2daa81501_Out_2;
            Unity_Add_float(_OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1, _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0, _Add_0183421596364a6394286bf2daa81501_Out_2);
            float4 _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2;
            Unity_Step_float4(_SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0, (_Add_0183421596364a6394286bf2daa81501_Out_2.xxxx), _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2);
            float4 _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2, _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2);
            float4 _SampleGradient_8541697807b2446dbe3b467321191095_Out_2;
            Unity_SampleGradientV1_float(NewGradient(0, 5, 2, float4(0, 0, 0, 0),float4(0.2, 0.2, 0.2, 0.2235294),float4(1, 1, 1, 0.5058824),float4(0.1981132, 0.1981132, 0.1981132, 0.8382391),float4(0, 0, 0, 1),float4(0, 0, 0, 0),float4(0, 0, 0, 0),float4(0, 0, 0, 0), float2(1, 0),float2(1, 1),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0)), _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, _SampleGradient_8541697807b2446dbe3b467321191095_Out_2);
            float4 _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1;
            Unity_OneMinus_float4(_SampleGradient_8541697807b2446dbe3b467321191095_Out_2, _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1);
            float2 _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3);
            float _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3;
            Unity_Rectangle_Fastest_float(_TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3, _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 1, _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3);
            float4 _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2;
            Unity_Multiply_float4_float4(_OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1, (_Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3.xxxx), _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2);
            float4 _Multiply_e508ba038e3541ad80d34830566710b3_Out_2;
            Unity_Multiply_float4_float4(_Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2, _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2, _Multiply_e508ba038e3541ad80d34830566710b3_Out_2);
            surface.Alpha = (_Multiply_e508ba038e3541ad80d34830566710b3_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexure_TexelSize;
        float _DissolveAmount;
        float _OutlineThickness;
        float _DissolveScale;
        float4 _OutlineColor;
        float4 _Mask_TexelSize;
        float4 _Color;
        float _Width;
        float _Speed;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexure);
        SAMPLER(sampler_MainTexure);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SampleGradientV1_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < Gradient.colorsLength; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifdef UNITY_COLORSPACE_GAMMA
            color = LinearToSRGB(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < Gradient.alphasLength; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a - 1].y) / (Gradient.alphas[a].y - Gradient.alphas[a - 1].y)) * step(a, Gradient.alphasLength - 1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Rectangle_Fastest_float(float2 UV, float Width, float Height, out float Out)
        {
            float2 d = abs(UV * 2 - 1) - float2(Width, Height);
        #if defined(SHADER_STAGE_RAY_TRACING)
            d = saturate((1 - saturate(d * 1e7)));
        #else
            d = saturate(1 - d / fwidth(d));
        #endif
            Out = min(d.x, d.y);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexure);
            float4 _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.tex, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.samplerstate, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_R_4 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.r;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_G_5 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.g;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_B_6 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.b;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_A_7 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.a;
            UnityTexture2D _Property_b472a836ec5f4871a294a78220f5eb07_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0 = _Speed;
            float _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _Vector2_25bac9fb598946de910318698c573f6a_Out_0 = float2(0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_25bac9fb598946de910318698c573f6a_Out_0, _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3);
            float4 _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b472a836ec5f4871a294a78220f5eb07_Out_0.tex, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.samplerstate, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.GetTransformedUV(_TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3));
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_R_4 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.r;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_G_5 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.g;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_B_6 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.b;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_A_7 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.a;
            float _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0 = _Width;
            float _Multiply_8226381011c64bab92a3f6445c001be6_Out_2;
            Unity_Multiply_float_float(_Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 0.9, _Multiply_8226381011c64bab92a3f6445c001be6_Out_2);
            float _Property_c63414226d0d4120a635c6a6937eb05d_Out_0 = _DissolveAmount;
            float _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2;
            Unity_Multiply_float_float(_Multiply_8226381011c64bab92a3f6445c001be6_Out_2, _Property_c63414226d0d4120a635c6a6937eb05d_Out_0, _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2);
            float _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1;
            Unity_OneMinus_float(_Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2, _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1);
            float _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0 = _OutlineThickness;
            float _Add_0183421596364a6394286bf2daa81501_Out_2;
            Unity_Add_float(_OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1, _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0, _Add_0183421596364a6394286bf2daa81501_Out_2);
            float4 _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2;
            Unity_Step_float4(_SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0, (_Add_0183421596364a6394286bf2daa81501_Out_2.xxxx), _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2);
            float4 _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2, _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2);
            float4 _SampleGradient_8541697807b2446dbe3b467321191095_Out_2;
            Unity_SampleGradientV1_float(NewGradient(0, 5, 2, float4(0, 0, 0, 0),float4(0.2, 0.2, 0.2, 0.2235294),float4(1, 1, 1, 0.5058824),float4(0.1981132, 0.1981132, 0.1981132, 0.8382391),float4(0, 0, 0, 1),float4(0, 0, 0, 0),float4(0, 0, 0, 0),float4(0, 0, 0, 0), float2(1, 0),float2(1, 1),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0)), _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, _SampleGradient_8541697807b2446dbe3b467321191095_Out_2);
            float4 _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1;
            Unity_OneMinus_float4(_SampleGradient_8541697807b2446dbe3b467321191095_Out_2, _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1);
            float2 _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3);
            float _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3;
            Unity_Rectangle_Fastest_float(_TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3, _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 1, _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3);
            float4 _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2;
            Unity_Multiply_float4_float4(_OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1, (_Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3.xxxx), _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2);
            float4 _Multiply_e508ba038e3541ad80d34830566710b3_Out_2;
            Unity_Multiply_float4_float4(_Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2, _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2, _Multiply_e508ba038e3541ad80d34830566710b3_Out_2);
            surface.Alpha = (_Multiply_e508ba038e3541ad80d34830566710b3_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexure_TexelSize;
        float _DissolveAmount;
        float _OutlineThickness;
        float _DissolveScale;
        float4 _OutlineColor;
        float4 _Mask_TexelSize;
        float4 _Color;
        float _Width;
        float _Speed;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexure);
        SAMPLER(sampler_MainTexure);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SampleGradientV1_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < Gradient.colorsLength; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifdef UNITY_COLORSPACE_GAMMA
            color = LinearToSRGB(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < Gradient.alphasLength; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a - 1].y) / (Gradient.alphas[a].y - Gradient.alphas[a - 1].y)) * step(a, Gradient.alphasLength - 1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Rectangle_Fastest_float(float2 UV, float Width, float Height, out float Out)
        {
            float2 d = abs(UV * 2 - 1) - float2(Width, Height);
        #if defined(SHADER_STAGE_RAY_TRACING)
            d = saturate((1 - saturate(d * 1e7)));
        #else
            d = saturate(1 - d / fwidth(d));
        #endif
            Out = min(d.x, d.y);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexure);
            float4 _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.tex, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.samplerstate, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_R_4 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.r;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_G_5 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.g;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_B_6 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.b;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_A_7 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.a;
            UnityTexture2D _Property_b472a836ec5f4871a294a78220f5eb07_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0 = _Speed;
            float _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _Vector2_25bac9fb598946de910318698c573f6a_Out_0 = float2(0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_25bac9fb598946de910318698c573f6a_Out_0, _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3);
            float4 _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b472a836ec5f4871a294a78220f5eb07_Out_0.tex, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.samplerstate, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.GetTransformedUV(_TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3));
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_R_4 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.r;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_G_5 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.g;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_B_6 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.b;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_A_7 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.a;
            float _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0 = _Width;
            float _Multiply_8226381011c64bab92a3f6445c001be6_Out_2;
            Unity_Multiply_float_float(_Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 0.9, _Multiply_8226381011c64bab92a3f6445c001be6_Out_2);
            float _Property_c63414226d0d4120a635c6a6937eb05d_Out_0 = _DissolveAmount;
            float _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2;
            Unity_Multiply_float_float(_Multiply_8226381011c64bab92a3f6445c001be6_Out_2, _Property_c63414226d0d4120a635c6a6937eb05d_Out_0, _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2);
            float _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1;
            Unity_OneMinus_float(_Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2, _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1);
            float _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0 = _OutlineThickness;
            float _Add_0183421596364a6394286bf2daa81501_Out_2;
            Unity_Add_float(_OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1, _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0, _Add_0183421596364a6394286bf2daa81501_Out_2);
            float4 _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2;
            Unity_Step_float4(_SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0, (_Add_0183421596364a6394286bf2daa81501_Out_2.xxxx), _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2);
            float4 _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2, _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2);
            float4 _SampleGradient_8541697807b2446dbe3b467321191095_Out_2;
            Unity_SampleGradientV1_float(NewGradient(0, 5, 2, float4(0, 0, 0, 0),float4(0.2, 0.2, 0.2, 0.2235294),float4(1, 1, 1, 0.5058824),float4(0.1981132, 0.1981132, 0.1981132, 0.8382391),float4(0, 0, 0, 1),float4(0, 0, 0, 0),float4(0, 0, 0, 0),float4(0, 0, 0, 0), float2(1, 0),float2(1, 1),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0)), _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, _SampleGradient_8541697807b2446dbe3b467321191095_Out_2);
            float4 _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1;
            Unity_OneMinus_float4(_SampleGradient_8541697807b2446dbe3b467321191095_Out_2, _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1);
            float2 _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3);
            float _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3;
            Unity_Rectangle_Fastest_float(_TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3, _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 1, _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3);
            float4 _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2;
            Unity_Multiply_float4_float4(_OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1, (_Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3.xxxx), _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2);
            float4 _Multiply_e508ba038e3541ad80d34830566710b3_Out_2;
            Unity_Multiply_float4_float4(_Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2, _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2, _Multiply_e508ba038e3541ad80d34830566710b3_Out_2);
            surface.Alpha = (_Multiply_e508ba038e3541ad80d34830566710b3_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define _SURFACE_TYPE_TRANSPARENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTexure_TexelSize;
        float _DissolveAmount;
        float _OutlineThickness;
        float _DissolveScale;
        float4 _OutlineColor;
        float4 _Mask_TexelSize;
        float4 _Color;
        float _Width;
        float _Speed;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexure);
        SAMPLER(sampler_MainTexure);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SampleGradientV1_float(Gradient Gradient, float Time, out float4 Out)
        {
            float3 color = Gradient.colors[0].rgb;
            [unroll]
            for (int c = 1; c < Gradient.colorsLength; c++)
            {
                float colorPos = saturate((Time - Gradient.colors[c - 1].w) / (Gradient.colors[c].w - Gradient.colors[c - 1].w)) * step(c, Gradient.colorsLength - 1);
                color = lerp(color, Gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), Gradient.type));
            }
        #ifdef UNITY_COLORSPACE_GAMMA
            color = LinearToSRGB(color);
        #endif
            float alpha = Gradient.alphas[0].x;
            [unroll]
            for (int a = 1; a < Gradient.alphasLength; a++)
            {
                float alphaPos = saturate((Time - Gradient.alphas[a - 1].y) / (Gradient.alphas[a].y - Gradient.alphas[a - 1].y)) * step(a, Gradient.alphasLength - 1);
                alpha = lerp(alpha, Gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), Gradient.type));
            }
            Out = float4(color, alpha);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Rectangle_Fastest_float(float2 UV, float Width, float Height, out float Out)
        {
            float2 d = abs(UV * 2 - 1) - float2(Width, Height);
        #if defined(SHADER_STAGE_RAY_TRACING)
            d = saturate((1 - saturate(d * 1e7)));
        #else
            d = saturate(1 - d / fwidth(d));
        #endif
            Out = min(d.x, d.y);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexure);
            float4 _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.tex, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.samplerstate, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_R_4 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.r;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_G_5 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.g;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_B_6 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.b;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_A_7 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.a;
            UnityTexture2D _Property_b472a836ec5f4871a294a78220f5eb07_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0 = _Speed;
            float _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d72e2968aa1c4e3ba1bc82fe0c8a3d7b_Out_0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _Vector2_25bac9fb598946de910318698c573f6a_Out_0 = float2(0, _Multiply_879a2aab29394082a7c1013638ad3fa5_Out_2);
            float2 _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_25bac9fb598946de910318698c573f6a_Out_0, _TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3);
            float4 _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b472a836ec5f4871a294a78220f5eb07_Out_0.tex, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.samplerstate, _Property_b472a836ec5f4871a294a78220f5eb07_Out_0.GetTransformedUV(_TilingAndOffset_f0cf05903e8a4d61bf5a1671e4f76df6_Out_3));
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_R_4 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.r;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_G_5 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.g;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_B_6 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.b;
            float _SampleTexture2D_75700b2b558142ce94f61548e01cef93_A_7 = _SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0.a;
            float _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0 = _Width;
            float _Multiply_8226381011c64bab92a3f6445c001be6_Out_2;
            Unity_Multiply_float_float(_Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 0.9, _Multiply_8226381011c64bab92a3f6445c001be6_Out_2);
            float _Property_c63414226d0d4120a635c6a6937eb05d_Out_0 = _DissolveAmount;
            float _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2;
            Unity_Multiply_float_float(_Multiply_8226381011c64bab92a3f6445c001be6_Out_2, _Property_c63414226d0d4120a635c6a6937eb05d_Out_0, _Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2);
            float _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1;
            Unity_OneMinus_float(_Multiply_6f92cd94e56d45f2b128fbc7f8a85ed4_Out_2, _OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1);
            float _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0 = _OutlineThickness;
            float _Add_0183421596364a6394286bf2daa81501_Out_2;
            Unity_Add_float(_OneMinus_9d0bfa87c39145afb97ea82aab940521_Out_1, _Property_f3bc7858ff1c44abb28b6ba0cd39a4e4_Out_0, _Add_0183421596364a6394286bf2daa81501_Out_2);
            float4 _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2;
            Unity_Step_float4(_SampleTexture2D_75700b2b558142ce94f61548e01cef93_RGBA_0, (_Add_0183421596364a6394286bf2daa81501_Out_2.xxxx), _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2);
            float4 _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Step_7122ecd6ee29457db0f5a9de83fbd92d_Out_2, _Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2);
            float4 _SampleGradient_8541697807b2446dbe3b467321191095_Out_2;
            Unity_SampleGradientV1_float(NewGradient(0, 5, 2, float4(0, 0, 0, 0),float4(0.2, 0.2, 0.2, 0.2235294),float4(1, 1, 1, 0.5058824),float4(0.1981132, 0.1981132, 0.1981132, 0.8382391),float4(0, 0, 0, 1),float4(0, 0, 0, 0),float4(0, 0, 0, 0),float4(0, 0, 0, 0), float2(1, 0),float2(1, 1),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0),float2(0, 0)), _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, _SampleGradient_8541697807b2446dbe3b467321191095_Out_2);
            float4 _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1;
            Unity_OneMinus_float4(_SampleGradient_8541697807b2446dbe3b467321191095_Out_2, _OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1);
            float2 _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3);
            float _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3;
            Unity_Rectangle_Fastest_float(_TilingAndOffset_fff93134abbe440b9a1bd7122732a9bd_Out_3, _Property_245d2c1895ff4b0e86a405e8bcd75a8f_Out_0, 1, _Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3);
            float4 _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2;
            Unity_Multiply_float4_float4(_OneMinus_3fa4160135aa4c4daba76acef756d443_Out_1, (_Rectangle_88939279cccd4e7f874f94f715bcee22_Out_3.xxxx), _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2);
            float4 _Multiply_e508ba038e3541ad80d34830566710b3_Out_2;
            Unity_Multiply_float4_float4(_Multiply_d38aaa928daa4b879b3a76f4bfd5a94c_Out_2, _Multiply_f771ac9317eb4eefa1821735fdc4dd9e_Out_2, _Multiply_e508ba038e3541ad80d34830566710b3_Out_2);
            surface.Alpha = (_Multiply_e508ba038e3541ad80d34830566710b3_Out_2).x;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}