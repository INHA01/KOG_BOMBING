Shader "Custom/Sha_Trail_Distort_04"
{
    Properties
    {
        _Tiling("Tiling", Vector) = (1, 1, 0, 0)
        _Tiling2("Tiling2", Vector) = (1, 1, 0, 0)
        _Speed("Speed", Vector) = (-2, 0, 0, 0)
        _Distort("Distort", Float) = 0.11
        [HDR]_Color("Color", Color) = (1, 1, 1, 0)
        _Intensity("Intensity", Float) = 1
        _Expose("Expose", Float) = 0.18
        _Alpha("Alpha", Float) = 2
        [NonModifiableTextureData][NoScaleOffset]_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D("Texture2D", 2D) = "white" {}
        [NonModifiableTextureData][NoScaleOffset]_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D("Texture2D", 2D) = "white" {}
        [NonModifiableTextureData][NoScaleOffset]_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D("Texture2D", 2D) = "white" {}
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
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
        }

        ZWrite On
        Stencil
        {
            Ref 1
            Comp Equal
        }

        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull Back
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
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
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
             float4 color : COLOR;
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
             float4 color;
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
             float4 VertexColor;
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
             float4 texCoord0 : INTERP0;
             float4 color : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
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
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
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
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
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
        float4 _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D_TexelSize;
        float2 _Tiling2;
        float2 _Tiling;
        float2 _Speed;
        float _Distort;
        float4 _Color;
        float _Intensity;
        float _Expose;
        float _Alpha;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D);
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
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
            float4 _Property_b52b564aaae24db08da88f50ff17cf27_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
            float2 _Property_410d6a8f412a467b850e7a9fb9adae67_Out_0_Vector2 = _Tiling;
            float2 _Property_2b12f5d8cc1243649b0a484c68f85957_Out_0_Vector2 = _Speed;
            float2 _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_2b12f5d8cc1243649b0a484c68f85957_Out_0_Vector2, _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2);
            float2 _TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_410d6a8f412a467b850e7a9fb9adae67_Out_0_Vector2, _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2, _TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2);
            float4 _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2) );
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_R_4_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.r;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_G_5_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.g;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_B_6_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.b;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_A_7_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.a;
            float4 _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2) );
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_R_4_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.r;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_G_5_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.g;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_B_6_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.b;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_A_7_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.a;
            float _Property_79ad21a821e24836ad73520de3ae39c9_Out_0_Float = _Distort;
            float _Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_8ef391ff339c449aa100002831067116_R_4_Float, _Property_79ad21a821e24836ad73520de3ae39c9_Out_0_Float, _Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float);
            float4 _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4 = IN.uv0;
            float4 _Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4;
            Unity_Add_float4((_Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float.xxxx), _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4, _Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4);
            float4 _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).GetTransformedUV((_Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4.xy)) );
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_R_4_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.r;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_G_5_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.g;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_B_6_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.b;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_A_7_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.a;
            float _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float;
            Unity_Absolute_float(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_R_4_Float, _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float);
            float _Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_R_4_Float, _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float, _Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float);
            float _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float;
            Unity_Clamp_float(_Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float, float(0), float(1), _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float);
            float _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[0];
            float _Split_9b9092ad759243538c0361cf76f12e4c_G_2_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[1];
            float _Split_9b9092ad759243538c0361cf76f12e4c_B_3_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[2];
            float _Split_9b9092ad759243538c0361cf76f12e4c_A_4_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[3];
            float _Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float;
            Unity_Smoothstep_float(float(0), float(1.3), _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float, _Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float);
            float _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float;
            Unity_Smoothstep_float(float(1), float(0), _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float, _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float);
            float _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float, _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float, _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float);
            float _Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float;
            Unity_Lerp_float(float(0), _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float, _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float, _Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float);
            float _Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float;
            Unity_Clamp_float(_Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float, float(0), float(1), _Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float);
            float4 _Multiply_faa4529a0b3747f9865e5904e3fb99b4_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_b52b564aaae24db08da88f50ff17cf27_Out_0_Vector4, (_Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float.xxxx), _Multiply_faa4529a0b3747f9865e5904e3fb99b4_Out_2_Vector4);
            float _Property_a9f4be3170d74d7996f05508b2dc59a3_Out_0_Float = _Intensity;
            float4 _Multiply_d650b4dea6ed4885bb76cce1cee4fddb_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_faa4529a0b3747f9865e5904e3fb99b4_Out_2_Vector4, (_Property_a9f4be3170d74d7996f05508b2dc59a3_Out_0_Float.xxxx), _Multiply_d650b4dea6ed4885bb76cce1cee4fddb_Out_2_Vector4);
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_R_1_Float = IN.VertexColor[0];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_G_2_Float = IN.VertexColor[1];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_B_3_Float = IN.VertexColor[2];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_A_4_Float = IN.VertexColor[3];
            float _Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float, _Split_03f5513cbc4242bcab3c8fc28e0abd18_A_4_Float, _Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float);
            float _Property_d9bf23b9aa6e43a895008406fb3d758f_Out_0_Float = _Alpha;
            float _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float, _Property_d9bf23b9aa6e43a895008406fb3d758f_Out_0_Float, _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float);
            surface.BaseColor = (_Multiply_d650b4dea6ed4885bb76cce1cee4fddb_Out_2_Vector4.xyz);
            surface.Alpha = _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float;
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
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define _SURFACE_TYPE_TRANSPARENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
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
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
             float4 color;
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
             float4 VertexColor;
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
             float4 texCoord0 : INTERP0;
             float4 color : INTERP1;
             float3 normalWS : INTERP2;
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
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.normalWS.xyz = input.normalWS;
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
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.normalWS = input.normalWS.xyz;
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
        float4 _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D_TexelSize;
        float2 _Tiling2;
        float2 _Tiling;
        float2 _Speed;
        float _Distort;
        float4 _Color;
        float _Intensity;
        float _Expose;
        float _Alpha;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D);
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
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
            float2 _Property_410d6a8f412a467b850e7a9fb9adae67_Out_0_Vector2 = _Tiling;
            float2 _Property_2b12f5d8cc1243649b0a484c68f85957_Out_0_Vector2 = _Speed;
            float2 _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_2b12f5d8cc1243649b0a484c68f85957_Out_0_Vector2, _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2);
            float2 _TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_410d6a8f412a467b850e7a9fb9adae67_Out_0_Vector2, _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2, _TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2);
            float4 _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2) );
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_R_4_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.r;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_G_5_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.g;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_B_6_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.b;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_A_7_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.a;
            float4 _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2) );
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_R_4_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.r;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_G_5_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.g;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_B_6_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.b;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_A_7_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.a;
            float _Property_79ad21a821e24836ad73520de3ae39c9_Out_0_Float = _Distort;
            float _Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_8ef391ff339c449aa100002831067116_R_4_Float, _Property_79ad21a821e24836ad73520de3ae39c9_Out_0_Float, _Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float);
            float4 _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4 = IN.uv0;
            float4 _Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4;
            Unity_Add_float4((_Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float.xxxx), _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4, _Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4);
            float4 _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).GetTransformedUV((_Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4.xy)) );
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_R_4_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.r;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_G_5_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.g;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_B_6_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.b;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_A_7_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.a;
            float _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float;
            Unity_Absolute_float(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_R_4_Float, _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float);
            float _Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_R_4_Float, _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float, _Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float);
            float _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float;
            Unity_Clamp_float(_Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float, float(0), float(1), _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float);
            float _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[0];
            float _Split_9b9092ad759243538c0361cf76f12e4c_G_2_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[1];
            float _Split_9b9092ad759243538c0361cf76f12e4c_B_3_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[2];
            float _Split_9b9092ad759243538c0361cf76f12e4c_A_4_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[3];
            float _Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float;
            Unity_Smoothstep_float(float(0), float(1.3), _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float, _Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float);
            float _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float;
            Unity_Smoothstep_float(float(1), float(0), _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float, _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float);
            float _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float, _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float, _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float);
            float _Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float;
            Unity_Lerp_float(float(0), _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float, _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float, _Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float);
            float _Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float;
            Unity_Clamp_float(_Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float, float(0), float(1), _Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float);
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_R_1_Float = IN.VertexColor[0];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_G_2_Float = IN.VertexColor[1];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_B_3_Float = IN.VertexColor[2];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_A_4_Float = IN.VertexColor[3];
            float _Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float, _Split_03f5513cbc4242bcab3c8fc28e0abd18_A_4_Float, _Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float);
            float _Property_d9bf23b9aa6e43a895008406fb3d758f_Out_0_Float = _Alpha;
            float _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float, _Property_d9bf23b9aa6e43a895008406fb3d758f_Out_0_Float, _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float);
            surface.Alpha = _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float;
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
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        Cull Back
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
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
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
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
             float4 color;
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
             float4 VertexColor;
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
             float4 texCoord0 : INTERP0;
             float4 color : INTERP1;
             float3 normalWS : INTERP2;
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
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.normalWS.xyz = input.normalWS;
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
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.normalWS = input.normalWS.xyz;
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
        float4 _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D_TexelSize;
        float2 _Tiling2;
        float2 _Tiling;
        float2 _Speed;
        float _Distort;
        float4 _Color;
        float _Intensity;
        float _Expose;
        float _Alpha;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D);
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
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
            float2 _Property_410d6a8f412a467b850e7a9fb9adae67_Out_0_Vector2 = _Tiling;
            float2 _Property_2b12f5d8cc1243649b0a484c68f85957_Out_0_Vector2 = _Speed;
            float2 _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_2b12f5d8cc1243649b0a484c68f85957_Out_0_Vector2, _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2);
            float2 _TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_410d6a8f412a467b850e7a9fb9adae67_Out_0_Vector2, _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2, _TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2);
            float4 _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2) );
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_R_4_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.r;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_G_5_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.g;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_B_6_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.b;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_A_7_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.a;
            float4 _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2) );
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_R_4_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.r;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_G_5_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.g;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_B_6_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.b;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_A_7_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.a;
            float _Property_79ad21a821e24836ad73520de3ae39c9_Out_0_Float = _Distort;
            float _Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_8ef391ff339c449aa100002831067116_R_4_Float, _Property_79ad21a821e24836ad73520de3ae39c9_Out_0_Float, _Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float);
            float4 _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4 = IN.uv0;
            float4 _Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4;
            Unity_Add_float4((_Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float.xxxx), _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4, _Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4);
            float4 _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).GetTransformedUV((_Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4.xy)) );
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_R_4_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.r;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_G_5_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.g;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_B_6_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.b;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_A_7_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.a;
            float _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float;
            Unity_Absolute_float(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_R_4_Float, _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float);
            float _Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_R_4_Float, _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float, _Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float);
            float _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float;
            Unity_Clamp_float(_Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float, float(0), float(1), _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float);
            float _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[0];
            float _Split_9b9092ad759243538c0361cf76f12e4c_G_2_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[1];
            float _Split_9b9092ad759243538c0361cf76f12e4c_B_3_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[2];
            float _Split_9b9092ad759243538c0361cf76f12e4c_A_4_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[3];
            float _Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float;
            Unity_Smoothstep_float(float(0), float(1.3), _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float, _Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float);
            float _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float;
            Unity_Smoothstep_float(float(1), float(0), _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float, _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float);
            float _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float, _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float, _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float);
            float _Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float;
            Unity_Lerp_float(float(0), _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float, _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float, _Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float);
            float _Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float;
            Unity_Clamp_float(_Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float, float(0), float(1), _Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float);
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_R_1_Float = IN.VertexColor[0];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_G_2_Float = IN.VertexColor[1];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_B_3_Float = IN.VertexColor[2];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_A_4_Float = IN.VertexColor[3];
            float _Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float, _Split_03f5513cbc4242bcab3c8fc28e0abd18_A_4_Float, _Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float);
            float _Property_d9bf23b9aa6e43a895008406fb3d758f_Out_0_Float = _Alpha;
            float _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float, _Property_d9bf23b9aa6e43a895008406fb3d758f_Out_0_Float, _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float);
            surface.Alpha = _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float;
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
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
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
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _SURFACE_TYPE_TRANSPARENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
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
             float4 color : COLOR;
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
             float4 color;
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
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
             float4 VertexColor;
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
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP0;
            #endif
             float4 texCoord0 : INTERP1;
             float4 color : INTERP2;
             float3 positionWS : INTERP3;
             float3 normalWS : INTERP4;
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
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
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
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
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
        float4 _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D_TexelSize;
        float2 _Tiling2;
        float2 _Tiling;
        float2 _Speed;
        float _Distort;
        float4 _Color;
        float _Intensity;
        float _Expose;
        float _Alpha;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D);
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
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
            float4 _Property_b52b564aaae24db08da88f50ff17cf27_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
            float2 _Property_410d6a8f412a467b850e7a9fb9adae67_Out_0_Vector2 = _Tiling;
            float2 _Property_2b12f5d8cc1243649b0a484c68f85957_Out_0_Vector2 = _Speed;
            float2 _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_2b12f5d8cc1243649b0a484c68f85957_Out_0_Vector2, _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2);
            float2 _TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_410d6a8f412a467b850e7a9fb9adae67_Out_0_Vector2, _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2, _TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2);
            float4 _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2) );
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_R_4_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.r;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_G_5_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.g;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_B_6_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.b;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_A_7_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.a;
            float4 _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2) );
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_R_4_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.r;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_G_5_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.g;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_B_6_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.b;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_A_7_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.a;
            float _Property_79ad21a821e24836ad73520de3ae39c9_Out_0_Float = _Distort;
            float _Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_8ef391ff339c449aa100002831067116_R_4_Float, _Property_79ad21a821e24836ad73520de3ae39c9_Out_0_Float, _Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float);
            float4 _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4 = IN.uv0;
            float4 _Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4;
            Unity_Add_float4((_Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float.xxxx), _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4, _Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4);
            float4 _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).GetTransformedUV((_Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4.xy)) );
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_R_4_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.r;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_G_5_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.g;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_B_6_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.b;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_A_7_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.a;
            float _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float;
            Unity_Absolute_float(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_R_4_Float, _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float);
            float _Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_R_4_Float, _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float, _Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float);
            float _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float;
            Unity_Clamp_float(_Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float, float(0), float(1), _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float);
            float _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[0];
            float _Split_9b9092ad759243538c0361cf76f12e4c_G_2_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[1];
            float _Split_9b9092ad759243538c0361cf76f12e4c_B_3_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[2];
            float _Split_9b9092ad759243538c0361cf76f12e4c_A_4_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[3];
            float _Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float;
            Unity_Smoothstep_float(float(0), float(1.3), _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float, _Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float);
            float _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float;
            Unity_Smoothstep_float(float(1), float(0), _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float, _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float);
            float _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float, _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float, _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float);
            float _Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float;
            Unity_Lerp_float(float(0), _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float, _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float, _Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float);
            float _Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float;
            Unity_Clamp_float(_Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float, float(0), float(1), _Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float);
            float4 _Multiply_faa4529a0b3747f9865e5904e3fb99b4_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_b52b564aaae24db08da88f50ff17cf27_Out_0_Vector4, (_Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float.xxxx), _Multiply_faa4529a0b3747f9865e5904e3fb99b4_Out_2_Vector4);
            float _Property_a9f4be3170d74d7996f05508b2dc59a3_Out_0_Float = _Intensity;
            float4 _Multiply_d650b4dea6ed4885bb76cce1cee4fddb_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_faa4529a0b3747f9865e5904e3fb99b4_Out_2_Vector4, (_Property_a9f4be3170d74d7996f05508b2dc59a3_Out_0_Float.xxxx), _Multiply_d650b4dea6ed4885bb76cce1cee4fddb_Out_2_Vector4);
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_R_1_Float = IN.VertexColor[0];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_G_2_Float = IN.VertexColor[1];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_B_3_Float = IN.VertexColor[2];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_A_4_Float = IN.VertexColor[3];
            float _Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float, _Split_03f5513cbc4242bcab3c8fc28e0abd18_A_4_Float, _Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float);
            float _Property_d9bf23b9aa6e43a895008406fb3d758f_Out_0_Float = _Alpha;
            float _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float, _Property_d9bf23b9aa6e43a895008406fb3d758f_Out_0_Float, _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float);
            surface.BaseColor = (_Multiply_d650b4dea6ed4885bb76cce1cee4fddb_Out_2_Vector4.xyz);
            surface.Alpha = _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float;
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
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitGBufferPass.hlsl"
        
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
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
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
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 color;
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
             float4 VertexColor;
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
             float4 texCoord0 : INTERP0;
             float4 color : INTERP1;
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
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
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
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
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
        float4 _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D_TexelSize;
        float2 _Tiling2;
        float2 _Tiling;
        float2 _Speed;
        float _Distort;
        float4 _Color;
        float _Intensity;
        float _Expose;
        float _Alpha;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D);
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
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
            float2 _Property_410d6a8f412a467b850e7a9fb9adae67_Out_0_Vector2 = _Tiling;
            float2 _Property_2b12f5d8cc1243649b0a484c68f85957_Out_0_Vector2 = _Speed;
            float2 _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_2b12f5d8cc1243649b0a484c68f85957_Out_0_Vector2, _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2);
            float2 _TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_410d6a8f412a467b850e7a9fb9adae67_Out_0_Vector2, _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2, _TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2);
            float4 _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2) );
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_R_4_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.r;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_G_5_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.g;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_B_6_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.b;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_A_7_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.a;
            float4 _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2) );
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_R_4_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.r;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_G_5_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.g;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_B_6_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.b;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_A_7_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.a;
            float _Property_79ad21a821e24836ad73520de3ae39c9_Out_0_Float = _Distort;
            float _Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_8ef391ff339c449aa100002831067116_R_4_Float, _Property_79ad21a821e24836ad73520de3ae39c9_Out_0_Float, _Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float);
            float4 _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4 = IN.uv0;
            float4 _Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4;
            Unity_Add_float4((_Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float.xxxx), _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4, _Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4);
            float4 _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).GetTransformedUV((_Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4.xy)) );
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_R_4_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.r;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_G_5_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.g;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_B_6_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.b;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_A_7_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.a;
            float _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float;
            Unity_Absolute_float(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_R_4_Float, _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float);
            float _Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_R_4_Float, _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float, _Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float);
            float _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float;
            Unity_Clamp_float(_Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float, float(0), float(1), _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float);
            float _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[0];
            float _Split_9b9092ad759243538c0361cf76f12e4c_G_2_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[1];
            float _Split_9b9092ad759243538c0361cf76f12e4c_B_3_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[2];
            float _Split_9b9092ad759243538c0361cf76f12e4c_A_4_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[3];
            float _Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float;
            Unity_Smoothstep_float(float(0), float(1.3), _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float, _Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float);
            float _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float;
            Unity_Smoothstep_float(float(1), float(0), _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float, _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float);
            float _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float, _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float, _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float);
            float _Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float;
            Unity_Lerp_float(float(0), _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float, _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float, _Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float);
            float _Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float;
            Unity_Clamp_float(_Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float, float(0), float(1), _Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float);
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_R_1_Float = IN.VertexColor[0];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_G_2_Float = IN.VertexColor[1];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_B_3_Float = IN.VertexColor[2];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_A_4_Float = IN.VertexColor[3];
            float _Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float, _Split_03f5513cbc4242bcab3c8fc28e0abd18_A_4_Float, _Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float);
            float _Property_d9bf23b9aa6e43a895008406fb3d758f_Out_0_Float = _Alpha;
            float _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float, _Property_d9bf23b9aa6e43a895008406fb3d758f_Out_0_Float, _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float);
            surface.Alpha = _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float;
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
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
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
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 color;
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
             float4 VertexColor;
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
             float4 texCoord0 : INTERP0;
             float4 color : INTERP1;
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
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
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
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
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
        float4 _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D_TexelSize;
        float2 _Tiling2;
        float2 _Tiling;
        float2 _Speed;
        float _Distort;
        float4 _Color;
        float _Intensity;
        float _Expose;
        float _Alpha;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D);
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
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
            float2 _Property_410d6a8f412a467b850e7a9fb9adae67_Out_0_Vector2 = _Tiling;
            float2 _Property_2b12f5d8cc1243649b0a484c68f85957_Out_0_Vector2 = _Speed;
            float2 _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_2b12f5d8cc1243649b0a484c68f85957_Out_0_Vector2, _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2);
            float2 _TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_410d6a8f412a467b850e7a9fb9adae67_Out_0_Vector2, _Multiply_68c54a4ee022417f9ee9a250d7b8217c_Out_2_Vector2, _TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2);
            float4 _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2) );
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_R_4_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.r;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_G_5_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.g;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_B_6_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.b;
            float _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_A_7_Float = _SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_RGBA_0_Vector4.a;
            float4 _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_8ef391ff339c449aa100002831067116_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_b2ee796c90924db1a6575a0a4dbadcfb_Out_3_Vector2) );
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_R_4_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.r;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_G_5_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.g;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_B_6_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.b;
            float _SampleTexture2D_8ef391ff339c449aa100002831067116_A_7_Float = _SampleTexture2D_8ef391ff339c449aa100002831067116_RGBA_0_Vector4.a;
            float _Property_79ad21a821e24836ad73520de3ae39c9_Out_0_Float = _Distort;
            float _Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_8ef391ff339c449aa100002831067116_R_4_Float, _Property_79ad21a821e24836ad73520de3ae39c9_Out_0_Float, _Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float);
            float4 _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4 = IN.uv0;
            float4 _Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4;
            Unity_Add_float4((_Multiply_a1298fe0d5b148189e75ae6ecd086f5b_Out_2_Float.xxxx), _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4, _Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4);
            float4 _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_Texture_1_Texture2D).GetTransformedUV((_Add_69bc7f2edf484b1b96a4edb7e60f2fa4_Out_2_Vector4.xy)) );
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_R_4_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.r;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_G_5_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.g;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_B_6_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.b;
            float _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_A_7_Float = _SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_RGBA_0_Vector4.a;
            float _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float;
            Unity_Absolute_float(_SampleTexture2D_33a4774edcb941eab2ba97f498ab105a_R_4_Float, _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float);
            float _Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float;
            Unity_Add_float(_SampleTexture2D_060742a6f9a3449fb671e19c74b80dca_R_4_Float, _Absolute_2e9bbe0dc01a4dcdafc85583ccd5dfcd_Out_1_Float, _Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float);
            float _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float;
            Unity_Clamp_float(_Add_52b4f4891d5f4e20af2897f2002b4dac_Out_2_Float, float(0), float(1), _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float);
            float _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[0];
            float _Split_9b9092ad759243538c0361cf76f12e4c_G_2_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[1];
            float _Split_9b9092ad759243538c0361cf76f12e4c_B_3_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[2];
            float _Split_9b9092ad759243538c0361cf76f12e4c_A_4_Float = _UV_d86923c2297f428a9b90c4fdcb96593c_Out_0_Vector4[3];
            float _Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float;
            Unity_Smoothstep_float(float(0), float(1.3), _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float, _Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float);
            float _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float;
            Unity_Smoothstep_float(float(1), float(0), _Split_9b9092ad759243538c0361cf76f12e4c_R_1_Float, _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float);
            float _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_9b142b221f4d4c6ba08ad9f39dd423f5_Out_3_Float, _Smoothstep_307491d73f8340dd9cd9129ddd15ef2f_Out_3_Float, _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float);
            float _Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float;
            Unity_Lerp_float(float(0), _Clamp_b062da80dbea4317838640ecb559e08b_Out_3_Float, _Multiply_833c22dd59f248e0ae5841203e57e43d_Out_2_Float, _Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float);
            float _Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float;
            Unity_Clamp_float(_Lerp_f3f33390bec24b598d6364bb30f54e07_Out_3_Float, float(0), float(1), _Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float);
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_R_1_Float = IN.VertexColor[0];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_G_2_Float = IN.VertexColor[1];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_B_3_Float = IN.VertexColor[2];
            float _Split_03f5513cbc4242bcab3c8fc28e0abd18_A_4_Float = IN.VertexColor[3];
            float _Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_add985500a014f08be2f3d40d6589d55_Out_3_Float, _Split_03f5513cbc4242bcab3c8fc28e0abd18_A_4_Float, _Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float);
            float _Property_d9bf23b9aa6e43a895008406fb3d758f_Out_0_Float = _Alpha;
            float _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_b3136257df3b44198964e3c152be5327_Out_2_Float, _Property_d9bf23b9aa6e43a895008406fb3d758f_Out_0_Float, _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float);
            surface.Alpha = _Multiply_6e1a4b99c2ab4f7485bdf48d91bb9d46_Out_2_Float;
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
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}