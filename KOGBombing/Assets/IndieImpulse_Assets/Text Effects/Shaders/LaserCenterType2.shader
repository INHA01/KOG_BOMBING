Shader "IndieImpulse/Unlit/LaserCenterType2"
{
    Properties
    {
        [HDR]Color_18d890ee80824248a51ee0a2b47a330e("Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]Texture2D_bc1d9eb6d4344d4084d949d7b33e529a("Mask", 2D) = "white" {}
        [NoScaleOffset]Texture2D_4f7017334adb4c31b376db39df7ead2d("MainText", 2D) = "white" {}
        Vector2_47b54501113b4c409f7770bf21e02d97("MainTextSpeed", Vector) = (0, 0, 0, 0)
        _CenterMove("CenterMove", Float) = 0
        _RadialScale("RadialScale", Float) = 1
        _LengthScale("LengthScale", Float) = 0
        _GlowPower("GlowPower", Float) = 0
        _TextureUV("TextureUV", Vector) = (0, 0, 0, 0)
        _Offset("Offset", Vector) = (0, 0, 0, 0)
        [HideInInspector]_CastShadows("_CastShadows", Float) = 1
        [HideInInspector]_Surface("_Surface", Float) = 1
        [HideInInspector]_Blend("_Blend", Float) = 0
        [HideInInspector]_AlphaClip("_AlphaClip", Float) = 0
        [HideInInspector]_SrcBlend("_SrcBlend", Float) = 1
        [HideInInspector]_DstBlend("_DstBlend", Float) = 0
        [HideInInspector][ToggleUI]_ZWrite("_ZWrite", Float) = 0
        [HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 0
        [HideInInspector]_ZTest("_ZTest", Float) = 4
        [HideInInspector]_Cull("_Cull", Float) = 0
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
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        
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
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
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
        float4 Color_18d890ee80824248a51ee0a2b47a330e;
        float4 Texture2D_bc1d9eb6d4344d4084d949d7b33e529a_TexelSize;
        float4 Texture2D_4f7017334adb4c31b376db39df7ead2d_TexelSize;
        float2 Vector2_47b54501113b4c409f7770bf21e02d97;
        float _CenterMove;
        float _RadialScale;
        float _LengthScale;
        float _GlowPower;
        float2 _TextureUV;
        float2 _Offset;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        SAMPLER(samplerTexture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        TEXTURE2D(Texture2D_4f7017334adb4c31b376db39df7ead2d);
        SAMPLER(samplerTexture2D_4f7017334adb4c31b376db39df7ead2d);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
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
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_01bbe1e7680b401e874750d026308a46_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_18d890ee80824248a51ee0a2b47a330e) : Color_18d890ee80824248a51ee0a2b47a330e;
            UnityTexture2D _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
            float2 _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0 = _TextureUV;
            float2 _Property_fc0085f8f562417086ae555779a1a5e9_Out_0 = _Offset;
            float2 _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0, _Property_fc0085f8f562417086ae555779a1a5e9_Out_0, _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3);
            float4 _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.tex, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.samplerstate, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.GetTransformedUV(_TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3));
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_R_4 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.r;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_G_5 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.g;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_B_6 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.b;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_A_7 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.a;
            UnityTexture2D _Property_e53f115c5350438db818ee2e25e84f66_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_4f7017334adb4c31b376db39df7ead2d);
            float _Property_9387fc1c17c047f4be709f020e55ec34_Out_0 = _CenterMove;
            float _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9387fc1c17c047f4be709f020e55ec34_Out_0, _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2);
            float _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0 = _RadialScale;
            float _Property_083539affd1242babdd9157da68bf4cb_Out_0 = _LengthScale;
            float2 _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4;
            Unity_PolarCoordinates_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0, _Property_083539affd1242babdd9157da68bf4cb_Out_0, _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4);
            float2 _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2;
            Unity_Add_float2((_Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2.xx), _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4, _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2);
            float4 _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e53f115c5350438db818ee2e25e84f66_Out_0.tex, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.samplerstate, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.GetTransformedUV(_Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2));
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_R_4 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.r;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_G_5 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.g;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_B_6 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.b;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_A_7 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.a;
            float4 _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0, _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2);
            float4 _Multiply_073d50ba797e42daa7dfb3574c85ef1f_Out_2;
            Unity_Multiply_float4_float4(_Property_01bbe1e7680b401e874750d026308a46_Out_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2, _Multiply_073d50ba797e42daa7dfb3574c85ef1f_Out_2);
            float _Split_57fa424231f8454c962dff75f2eb208a_R_1 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[0];
            float _Split_57fa424231f8454c962dff75f2eb208a_G_2 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[1];
            float _Split_57fa424231f8454c962dff75f2eb208a_B_3 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[2];
            float _Split_57fa424231f8454c962dff75f2eb208a_A_4 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[3];
            surface.BaseColor = (_Multiply_073d50ba797e42daa7dfb3574c85ef1f_Out_2.xyz);
            surface.Alpha = _Split_57fa424231f8454c962dff75f2eb208a_R_1;
            surface.AlphaClipThreshold = 0.5;
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
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull [_Cull]
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
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
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
        float4 Color_18d890ee80824248a51ee0a2b47a330e;
        float4 Texture2D_bc1d9eb6d4344d4084d949d7b33e529a_TexelSize;
        float4 Texture2D_4f7017334adb4c31b376db39df7ead2d_TexelSize;
        float2 Vector2_47b54501113b4c409f7770bf21e02d97;
        float _CenterMove;
        float _RadialScale;
        float _LengthScale;
        float _GlowPower;
        float2 _TextureUV;
        float2 _Offset;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        SAMPLER(samplerTexture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        TEXTURE2D(Texture2D_4f7017334adb4c31b376db39df7ead2d);
        SAMPLER(samplerTexture2D_4f7017334adb4c31b376db39df7ead2d);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
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
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
            float2 _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0 = _TextureUV;
            float2 _Property_fc0085f8f562417086ae555779a1a5e9_Out_0 = _Offset;
            float2 _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0, _Property_fc0085f8f562417086ae555779a1a5e9_Out_0, _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3);
            float4 _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.tex, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.samplerstate, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.GetTransformedUV(_TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3));
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_R_4 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.r;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_G_5 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.g;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_B_6 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.b;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_A_7 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.a;
            UnityTexture2D _Property_e53f115c5350438db818ee2e25e84f66_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_4f7017334adb4c31b376db39df7ead2d);
            float _Property_9387fc1c17c047f4be709f020e55ec34_Out_0 = _CenterMove;
            float _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9387fc1c17c047f4be709f020e55ec34_Out_0, _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2);
            float _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0 = _RadialScale;
            float _Property_083539affd1242babdd9157da68bf4cb_Out_0 = _LengthScale;
            float2 _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4;
            Unity_PolarCoordinates_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0, _Property_083539affd1242babdd9157da68bf4cb_Out_0, _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4);
            float2 _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2;
            Unity_Add_float2((_Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2.xx), _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4, _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2);
            float4 _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e53f115c5350438db818ee2e25e84f66_Out_0.tex, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.samplerstate, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.GetTransformedUV(_Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2));
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_R_4 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.r;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_G_5 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.g;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_B_6 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.b;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_A_7 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.a;
            float4 _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0, _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2);
            float _Split_57fa424231f8454c962dff75f2eb208a_R_1 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[0];
            float _Split_57fa424231f8454c962dff75f2eb208a_G_2 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[1];
            float _Split_57fa424231f8454c962dff75f2eb208a_B_3 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[2];
            float _Split_57fa424231f8454c962dff75f2eb208a_A_4 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[3];
            surface.Alpha = _Split_57fa424231f8454c962dff75f2eb208a_R_1;
            surface.AlphaClipThreshold = 0.5;
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
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
        Cull [_Cull]
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
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
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
        float4 Color_18d890ee80824248a51ee0a2b47a330e;
        float4 Texture2D_bc1d9eb6d4344d4084d949d7b33e529a_TexelSize;
        float4 Texture2D_4f7017334adb4c31b376db39df7ead2d_TexelSize;
        float2 Vector2_47b54501113b4c409f7770bf21e02d97;
        float _CenterMove;
        float _RadialScale;
        float _LengthScale;
        float _GlowPower;
        float2 _TextureUV;
        float2 _Offset;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        SAMPLER(samplerTexture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        TEXTURE2D(Texture2D_4f7017334adb4c31b376db39df7ead2d);
        SAMPLER(samplerTexture2D_4f7017334adb4c31b376db39df7ead2d);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
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
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
            float2 _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0 = _TextureUV;
            float2 _Property_fc0085f8f562417086ae555779a1a5e9_Out_0 = _Offset;
            float2 _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0, _Property_fc0085f8f562417086ae555779a1a5e9_Out_0, _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3);
            float4 _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.tex, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.samplerstate, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.GetTransformedUV(_TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3));
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_R_4 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.r;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_G_5 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.g;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_B_6 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.b;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_A_7 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.a;
            UnityTexture2D _Property_e53f115c5350438db818ee2e25e84f66_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_4f7017334adb4c31b376db39df7ead2d);
            float _Property_9387fc1c17c047f4be709f020e55ec34_Out_0 = _CenterMove;
            float _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9387fc1c17c047f4be709f020e55ec34_Out_0, _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2);
            float _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0 = _RadialScale;
            float _Property_083539affd1242babdd9157da68bf4cb_Out_0 = _LengthScale;
            float2 _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4;
            Unity_PolarCoordinates_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0, _Property_083539affd1242babdd9157da68bf4cb_Out_0, _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4);
            float2 _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2;
            Unity_Add_float2((_Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2.xx), _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4, _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2);
            float4 _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e53f115c5350438db818ee2e25e84f66_Out_0.tex, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.samplerstate, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.GetTransformedUV(_Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2));
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_R_4 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.r;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_G_5 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.g;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_B_6 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.b;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_A_7 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.a;
            float4 _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0, _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2);
            float _Split_57fa424231f8454c962dff75f2eb208a_R_1 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[0];
            float _Split_57fa424231f8454c962dff75f2eb208a_G_2 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[1];
            float _Split_57fa424231f8454c962dff75f2eb208a_B_3 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[2];
            float _Split_57fa424231f8454c962dff75f2eb208a_A_4 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[3];
            surface.Alpha = _Split_57fa424231f8454c962dff75f2eb208a_R_1;
            surface.AlphaClipThreshold = 0.5;
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
        Cull [_Cull]
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
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
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
        float4 Color_18d890ee80824248a51ee0a2b47a330e;
        float4 Texture2D_bc1d9eb6d4344d4084d949d7b33e529a_TexelSize;
        float4 Texture2D_4f7017334adb4c31b376db39df7ead2d_TexelSize;
        float2 Vector2_47b54501113b4c409f7770bf21e02d97;
        float _CenterMove;
        float _RadialScale;
        float _LengthScale;
        float _GlowPower;
        float2 _TextureUV;
        float2 _Offset;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        SAMPLER(samplerTexture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        TEXTURE2D(Texture2D_4f7017334adb4c31b376db39df7ead2d);
        SAMPLER(samplerTexture2D_4f7017334adb4c31b376db39df7ead2d);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
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
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
            float2 _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0 = _TextureUV;
            float2 _Property_fc0085f8f562417086ae555779a1a5e9_Out_0 = _Offset;
            float2 _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0, _Property_fc0085f8f562417086ae555779a1a5e9_Out_0, _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3);
            float4 _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.tex, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.samplerstate, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.GetTransformedUV(_TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3));
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_R_4 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.r;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_G_5 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.g;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_B_6 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.b;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_A_7 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.a;
            UnityTexture2D _Property_e53f115c5350438db818ee2e25e84f66_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_4f7017334adb4c31b376db39df7ead2d);
            float _Property_9387fc1c17c047f4be709f020e55ec34_Out_0 = _CenterMove;
            float _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9387fc1c17c047f4be709f020e55ec34_Out_0, _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2);
            float _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0 = _RadialScale;
            float _Property_083539affd1242babdd9157da68bf4cb_Out_0 = _LengthScale;
            float2 _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4;
            Unity_PolarCoordinates_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0, _Property_083539affd1242babdd9157da68bf4cb_Out_0, _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4);
            float2 _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2;
            Unity_Add_float2((_Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2.xx), _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4, _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2);
            float4 _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e53f115c5350438db818ee2e25e84f66_Out_0.tex, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.samplerstate, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.GetTransformedUV(_Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2));
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_R_4 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.r;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_G_5 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.g;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_B_6 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.b;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_A_7 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.a;
            float4 _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0, _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2);
            float _Split_57fa424231f8454c962dff75f2eb208a_R_1 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[0];
            float _Split_57fa424231f8454c962dff75f2eb208a_G_2 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[1];
            float _Split_57fa424231f8454c962dff75f2eb208a_B_3 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[2];
            float _Split_57fa424231f8454c962dff75f2eb208a_A_4 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[3];
            surface.Alpha = _Split_57fa424231f8454c962dff75f2eb208a_R_1;
            surface.AlphaClipThreshold = 0.5;
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
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
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
        float4 Color_18d890ee80824248a51ee0a2b47a330e;
        float4 Texture2D_bc1d9eb6d4344d4084d949d7b33e529a_TexelSize;
        float4 Texture2D_4f7017334adb4c31b376db39df7ead2d_TexelSize;
        float2 Vector2_47b54501113b4c409f7770bf21e02d97;
        float _CenterMove;
        float _RadialScale;
        float _LengthScale;
        float _GlowPower;
        float2 _TextureUV;
        float2 _Offset;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        SAMPLER(samplerTexture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        TEXTURE2D(Texture2D_4f7017334adb4c31b376db39df7ead2d);
        SAMPLER(samplerTexture2D_4f7017334adb4c31b376db39df7ead2d);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
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
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
            float2 _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0 = _TextureUV;
            float2 _Property_fc0085f8f562417086ae555779a1a5e9_Out_0 = _Offset;
            float2 _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0, _Property_fc0085f8f562417086ae555779a1a5e9_Out_0, _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3);
            float4 _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.tex, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.samplerstate, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.GetTransformedUV(_TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3));
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_R_4 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.r;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_G_5 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.g;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_B_6 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.b;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_A_7 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.a;
            UnityTexture2D _Property_e53f115c5350438db818ee2e25e84f66_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_4f7017334adb4c31b376db39df7ead2d);
            float _Property_9387fc1c17c047f4be709f020e55ec34_Out_0 = _CenterMove;
            float _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9387fc1c17c047f4be709f020e55ec34_Out_0, _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2);
            float _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0 = _RadialScale;
            float _Property_083539affd1242babdd9157da68bf4cb_Out_0 = _LengthScale;
            float2 _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4;
            Unity_PolarCoordinates_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0, _Property_083539affd1242babdd9157da68bf4cb_Out_0, _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4);
            float2 _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2;
            Unity_Add_float2((_Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2.xx), _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4, _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2);
            float4 _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e53f115c5350438db818ee2e25e84f66_Out_0.tex, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.samplerstate, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.GetTransformedUV(_Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2));
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_R_4 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.r;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_G_5 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.g;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_B_6 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.b;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_A_7 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.a;
            float4 _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0, _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2);
            float _Split_57fa424231f8454c962dff75f2eb208a_R_1 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[0];
            float _Split_57fa424231f8454c962dff75f2eb208a_G_2 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[1];
            float _Split_57fa424231f8454c962dff75f2eb208a_B_3 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[2];
            float _Split_57fa424231f8454c962dff75f2eb208a_A_4 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[3];
            surface.Alpha = _Split_57fa424231f8454c962dff75f2eb208a_R_1;
            surface.AlphaClipThreshold = 0.5;
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
        Cull [_Cull]
        
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
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
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
        float4 Color_18d890ee80824248a51ee0a2b47a330e;
        float4 Texture2D_bc1d9eb6d4344d4084d949d7b33e529a_TexelSize;
        float4 Texture2D_4f7017334adb4c31b376db39df7ead2d_TexelSize;
        float2 Vector2_47b54501113b4c409f7770bf21e02d97;
        float _CenterMove;
        float _RadialScale;
        float _LengthScale;
        float _GlowPower;
        float2 _TextureUV;
        float2 _Offset;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        SAMPLER(samplerTexture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        TEXTURE2D(Texture2D_4f7017334adb4c31b376db39df7ead2d);
        SAMPLER(samplerTexture2D_4f7017334adb4c31b376db39df7ead2d);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
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
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
            float2 _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0 = _TextureUV;
            float2 _Property_fc0085f8f562417086ae555779a1a5e9_Out_0 = _Offset;
            float2 _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0, _Property_fc0085f8f562417086ae555779a1a5e9_Out_0, _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3);
            float4 _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.tex, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.samplerstate, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.GetTransformedUV(_TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3));
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_R_4 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.r;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_G_5 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.g;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_B_6 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.b;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_A_7 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.a;
            UnityTexture2D _Property_e53f115c5350438db818ee2e25e84f66_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_4f7017334adb4c31b376db39df7ead2d);
            float _Property_9387fc1c17c047f4be709f020e55ec34_Out_0 = _CenterMove;
            float _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9387fc1c17c047f4be709f020e55ec34_Out_0, _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2);
            float _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0 = _RadialScale;
            float _Property_083539affd1242babdd9157da68bf4cb_Out_0 = _LengthScale;
            float2 _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4;
            Unity_PolarCoordinates_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0, _Property_083539affd1242babdd9157da68bf4cb_Out_0, _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4);
            float2 _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2;
            Unity_Add_float2((_Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2.xx), _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4, _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2);
            float4 _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e53f115c5350438db818ee2e25e84f66_Out_0.tex, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.samplerstate, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.GetTransformedUV(_Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2));
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_R_4 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.r;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_G_5 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.g;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_B_6 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.b;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_A_7 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.a;
            float4 _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0, _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2);
            float _Split_57fa424231f8454c962dff75f2eb208a_R_1 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[0];
            float _Split_57fa424231f8454c962dff75f2eb208a_G_2 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[1];
            float _Split_57fa424231f8454c962dff75f2eb208a_B_3 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[2];
            float _Split_57fa424231f8454c962dff75f2eb208a_A_4 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[3];
            surface.Alpha = _Split_57fa424231f8454c962dff75f2eb208a_R_1;
            surface.AlphaClipThreshold = 0.5;
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
        Cull [_Cull]
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
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
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
        float4 Color_18d890ee80824248a51ee0a2b47a330e;
        float4 Texture2D_bc1d9eb6d4344d4084d949d7b33e529a_TexelSize;
        float4 Texture2D_4f7017334adb4c31b376db39df7ead2d_TexelSize;
        float2 Vector2_47b54501113b4c409f7770bf21e02d97;
        float _CenterMove;
        float _RadialScale;
        float _LengthScale;
        float _GlowPower;
        float2 _TextureUV;
        float2 _Offset;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        SAMPLER(samplerTexture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        TEXTURE2D(Texture2D_4f7017334adb4c31b376db39df7ead2d);
        SAMPLER(samplerTexture2D_4f7017334adb4c31b376db39df7ead2d);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
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
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
            float2 _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0 = _TextureUV;
            float2 _Property_fc0085f8f562417086ae555779a1a5e9_Out_0 = _Offset;
            float2 _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0, _Property_fc0085f8f562417086ae555779a1a5e9_Out_0, _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3);
            float4 _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.tex, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.samplerstate, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.GetTransformedUV(_TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3));
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_R_4 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.r;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_G_5 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.g;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_B_6 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.b;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_A_7 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.a;
            UnityTexture2D _Property_e53f115c5350438db818ee2e25e84f66_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_4f7017334adb4c31b376db39df7ead2d);
            float _Property_9387fc1c17c047f4be709f020e55ec34_Out_0 = _CenterMove;
            float _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9387fc1c17c047f4be709f020e55ec34_Out_0, _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2);
            float _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0 = _RadialScale;
            float _Property_083539affd1242babdd9157da68bf4cb_Out_0 = _LengthScale;
            float2 _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4;
            Unity_PolarCoordinates_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0, _Property_083539affd1242babdd9157da68bf4cb_Out_0, _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4);
            float2 _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2;
            Unity_Add_float2((_Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2.xx), _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4, _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2);
            float4 _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e53f115c5350438db818ee2e25e84f66_Out_0.tex, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.samplerstate, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.GetTransformedUV(_Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2));
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_R_4 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.r;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_G_5 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.g;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_B_6 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.b;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_A_7 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.a;
            float4 _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0, _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2);
            float _Split_57fa424231f8454c962dff75f2eb208a_R_1 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[0];
            float _Split_57fa424231f8454c962dff75f2eb208a_G_2 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[1];
            float _Split_57fa424231f8454c962dff75f2eb208a_B_3 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[2];
            float _Split_57fa424231f8454c962dff75f2eb208a_A_4 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[3];
            surface.Alpha = _Split_57fa424231f8454c962dff75f2eb208a_R_1;
            surface.AlphaClipThreshold = 0.5;
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
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        
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
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
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
        float4 Color_18d890ee80824248a51ee0a2b47a330e;
        float4 Texture2D_bc1d9eb6d4344d4084d949d7b33e529a_TexelSize;
        float4 Texture2D_4f7017334adb4c31b376db39df7ead2d_TexelSize;
        float2 Vector2_47b54501113b4c409f7770bf21e02d97;
        float _CenterMove;
        float _RadialScale;
        float _LengthScale;
        float _GlowPower;
        float2 _TextureUV;
        float2 _Offset;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        SAMPLER(samplerTexture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        TEXTURE2D(Texture2D_4f7017334adb4c31b376db39df7ead2d);
        SAMPLER(samplerTexture2D_4f7017334adb4c31b376db39df7ead2d);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
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
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_01bbe1e7680b401e874750d026308a46_Out_0 = IsGammaSpace() ? LinearToSRGB(Color_18d890ee80824248a51ee0a2b47a330e) : Color_18d890ee80824248a51ee0a2b47a330e;
            UnityTexture2D _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
            float2 _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0 = _TextureUV;
            float2 _Property_fc0085f8f562417086ae555779a1a5e9_Out_0 = _Offset;
            float2 _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0, _Property_fc0085f8f562417086ae555779a1a5e9_Out_0, _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3);
            float4 _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.tex, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.samplerstate, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.GetTransformedUV(_TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3));
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_R_4 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.r;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_G_5 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.g;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_B_6 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.b;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_A_7 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.a;
            UnityTexture2D _Property_e53f115c5350438db818ee2e25e84f66_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_4f7017334adb4c31b376db39df7ead2d);
            float _Property_9387fc1c17c047f4be709f020e55ec34_Out_0 = _CenterMove;
            float _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9387fc1c17c047f4be709f020e55ec34_Out_0, _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2);
            float _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0 = _RadialScale;
            float _Property_083539affd1242babdd9157da68bf4cb_Out_0 = _LengthScale;
            float2 _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4;
            Unity_PolarCoordinates_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0, _Property_083539affd1242babdd9157da68bf4cb_Out_0, _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4);
            float2 _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2;
            Unity_Add_float2((_Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2.xx), _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4, _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2);
            float4 _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e53f115c5350438db818ee2e25e84f66_Out_0.tex, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.samplerstate, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.GetTransformedUV(_Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2));
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_R_4 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.r;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_G_5 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.g;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_B_6 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.b;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_A_7 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.a;
            float4 _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0, _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2);
            float4 _Multiply_073d50ba797e42daa7dfb3574c85ef1f_Out_2;
            Unity_Multiply_float4_float4(_Property_01bbe1e7680b401e874750d026308a46_Out_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2, _Multiply_073d50ba797e42daa7dfb3574c85ef1f_Out_2);
            float _Split_57fa424231f8454c962dff75f2eb208a_R_1 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[0];
            float _Split_57fa424231f8454c962dff75f2eb208a_G_2 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[1];
            float _Split_57fa424231f8454c962dff75f2eb208a_B_3 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[2];
            float _Split_57fa424231f8454c962dff75f2eb208a_A_4 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[3];
            surface.BaseColor = (_Multiply_073d50ba797e42daa7dfb3574c85ef1f_Out_2.xyz);
            surface.Alpha = _Split_57fa424231f8454c962dff75f2eb208a_R_1;
            surface.AlphaClipThreshold = 0.5;
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
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull [_Cull]
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
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
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
        float4 Color_18d890ee80824248a51ee0a2b47a330e;
        float4 Texture2D_bc1d9eb6d4344d4084d949d7b33e529a_TexelSize;
        float4 Texture2D_4f7017334adb4c31b376db39df7ead2d_TexelSize;
        float2 Vector2_47b54501113b4c409f7770bf21e02d97;
        float _CenterMove;
        float _RadialScale;
        float _LengthScale;
        float _GlowPower;
        float2 _TextureUV;
        float2 _Offset;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        SAMPLER(samplerTexture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        TEXTURE2D(Texture2D_4f7017334adb4c31b376db39df7ead2d);
        SAMPLER(samplerTexture2D_4f7017334adb4c31b376db39df7ead2d);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
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
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
            float2 _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0 = _TextureUV;
            float2 _Property_fc0085f8f562417086ae555779a1a5e9_Out_0 = _Offset;
            float2 _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0, _Property_fc0085f8f562417086ae555779a1a5e9_Out_0, _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3);
            float4 _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.tex, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.samplerstate, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.GetTransformedUV(_TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3));
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_R_4 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.r;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_G_5 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.g;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_B_6 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.b;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_A_7 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.a;
            UnityTexture2D _Property_e53f115c5350438db818ee2e25e84f66_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_4f7017334adb4c31b376db39df7ead2d);
            float _Property_9387fc1c17c047f4be709f020e55ec34_Out_0 = _CenterMove;
            float _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9387fc1c17c047f4be709f020e55ec34_Out_0, _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2);
            float _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0 = _RadialScale;
            float _Property_083539affd1242babdd9157da68bf4cb_Out_0 = _LengthScale;
            float2 _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4;
            Unity_PolarCoordinates_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0, _Property_083539affd1242babdd9157da68bf4cb_Out_0, _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4);
            float2 _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2;
            Unity_Add_float2((_Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2.xx), _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4, _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2);
            float4 _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e53f115c5350438db818ee2e25e84f66_Out_0.tex, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.samplerstate, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.GetTransformedUV(_Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2));
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_R_4 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.r;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_G_5 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.g;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_B_6 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.b;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_A_7 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.a;
            float4 _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0, _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2);
            float _Split_57fa424231f8454c962dff75f2eb208a_R_1 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[0];
            float _Split_57fa424231f8454c962dff75f2eb208a_G_2 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[1];
            float _Split_57fa424231f8454c962dff75f2eb208a_B_3 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[2];
            float _Split_57fa424231f8454c962dff75f2eb208a_A_4 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[3];
            surface.Alpha = _Split_57fa424231f8454c962dff75f2eb208a_R_1;
            surface.AlphaClipThreshold = 0.5;
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
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
        Cull [_Cull]
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
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
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
        float4 Color_18d890ee80824248a51ee0a2b47a330e;
        float4 Texture2D_bc1d9eb6d4344d4084d949d7b33e529a_TexelSize;
        float4 Texture2D_4f7017334adb4c31b376db39df7ead2d_TexelSize;
        float2 Vector2_47b54501113b4c409f7770bf21e02d97;
        float _CenterMove;
        float _RadialScale;
        float _LengthScale;
        float _GlowPower;
        float2 _TextureUV;
        float2 _Offset;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        SAMPLER(samplerTexture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        TEXTURE2D(Texture2D_4f7017334adb4c31b376db39df7ead2d);
        SAMPLER(samplerTexture2D_4f7017334adb4c31b376db39df7ead2d);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
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
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
            float2 _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0 = _TextureUV;
            float2 _Property_fc0085f8f562417086ae555779a1a5e9_Out_0 = _Offset;
            float2 _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0, _Property_fc0085f8f562417086ae555779a1a5e9_Out_0, _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3);
            float4 _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.tex, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.samplerstate, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.GetTransformedUV(_TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3));
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_R_4 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.r;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_G_5 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.g;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_B_6 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.b;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_A_7 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.a;
            UnityTexture2D _Property_e53f115c5350438db818ee2e25e84f66_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_4f7017334adb4c31b376db39df7ead2d);
            float _Property_9387fc1c17c047f4be709f020e55ec34_Out_0 = _CenterMove;
            float _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9387fc1c17c047f4be709f020e55ec34_Out_0, _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2);
            float _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0 = _RadialScale;
            float _Property_083539affd1242babdd9157da68bf4cb_Out_0 = _LengthScale;
            float2 _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4;
            Unity_PolarCoordinates_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0, _Property_083539affd1242babdd9157da68bf4cb_Out_0, _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4);
            float2 _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2;
            Unity_Add_float2((_Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2.xx), _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4, _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2);
            float4 _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e53f115c5350438db818ee2e25e84f66_Out_0.tex, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.samplerstate, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.GetTransformedUV(_Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2));
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_R_4 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.r;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_G_5 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.g;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_B_6 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.b;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_A_7 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.a;
            float4 _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0, _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2);
            float _Split_57fa424231f8454c962dff75f2eb208a_R_1 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[0];
            float _Split_57fa424231f8454c962dff75f2eb208a_G_2 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[1];
            float _Split_57fa424231f8454c962dff75f2eb208a_B_3 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[2];
            float _Split_57fa424231f8454c962dff75f2eb208a_A_4 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[3];
            surface.Alpha = _Split_57fa424231f8454c962dff75f2eb208a_R_1;
            surface.AlphaClipThreshold = 0.5;
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
        Cull [_Cull]
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
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
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
        float4 Color_18d890ee80824248a51ee0a2b47a330e;
        float4 Texture2D_bc1d9eb6d4344d4084d949d7b33e529a_TexelSize;
        float4 Texture2D_4f7017334adb4c31b376db39df7ead2d_TexelSize;
        float2 Vector2_47b54501113b4c409f7770bf21e02d97;
        float _CenterMove;
        float _RadialScale;
        float _LengthScale;
        float _GlowPower;
        float2 _TextureUV;
        float2 _Offset;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        SAMPLER(samplerTexture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        TEXTURE2D(Texture2D_4f7017334adb4c31b376db39df7ead2d);
        SAMPLER(samplerTexture2D_4f7017334adb4c31b376db39df7ead2d);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
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
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
            float2 _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0 = _TextureUV;
            float2 _Property_fc0085f8f562417086ae555779a1a5e9_Out_0 = _Offset;
            float2 _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0, _Property_fc0085f8f562417086ae555779a1a5e9_Out_0, _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3);
            float4 _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.tex, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.samplerstate, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.GetTransformedUV(_TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3));
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_R_4 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.r;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_G_5 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.g;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_B_6 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.b;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_A_7 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.a;
            UnityTexture2D _Property_e53f115c5350438db818ee2e25e84f66_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_4f7017334adb4c31b376db39df7ead2d);
            float _Property_9387fc1c17c047f4be709f020e55ec34_Out_0 = _CenterMove;
            float _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9387fc1c17c047f4be709f020e55ec34_Out_0, _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2);
            float _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0 = _RadialScale;
            float _Property_083539affd1242babdd9157da68bf4cb_Out_0 = _LengthScale;
            float2 _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4;
            Unity_PolarCoordinates_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0, _Property_083539affd1242babdd9157da68bf4cb_Out_0, _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4);
            float2 _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2;
            Unity_Add_float2((_Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2.xx), _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4, _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2);
            float4 _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e53f115c5350438db818ee2e25e84f66_Out_0.tex, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.samplerstate, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.GetTransformedUV(_Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2));
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_R_4 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.r;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_G_5 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.g;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_B_6 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.b;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_A_7 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.a;
            float4 _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0, _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2);
            float _Split_57fa424231f8454c962dff75f2eb208a_R_1 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[0];
            float _Split_57fa424231f8454c962dff75f2eb208a_G_2 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[1];
            float _Split_57fa424231f8454c962dff75f2eb208a_B_3 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[2];
            float _Split_57fa424231f8454c962dff75f2eb208a_A_4 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[3];
            surface.Alpha = _Split_57fa424231f8454c962dff75f2eb208a_R_1;
            surface.AlphaClipThreshold = 0.5;
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
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
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
        float4 Color_18d890ee80824248a51ee0a2b47a330e;
        float4 Texture2D_bc1d9eb6d4344d4084d949d7b33e529a_TexelSize;
        float4 Texture2D_4f7017334adb4c31b376db39df7ead2d_TexelSize;
        float2 Vector2_47b54501113b4c409f7770bf21e02d97;
        float _CenterMove;
        float _RadialScale;
        float _LengthScale;
        float _GlowPower;
        float2 _TextureUV;
        float2 _Offset;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        SAMPLER(samplerTexture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        TEXTURE2D(Texture2D_4f7017334adb4c31b376db39df7ead2d);
        SAMPLER(samplerTexture2D_4f7017334adb4c31b376db39df7ead2d);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
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
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
            float2 _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0 = _TextureUV;
            float2 _Property_fc0085f8f562417086ae555779a1a5e9_Out_0 = _Offset;
            float2 _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0, _Property_fc0085f8f562417086ae555779a1a5e9_Out_0, _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3);
            float4 _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.tex, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.samplerstate, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.GetTransformedUV(_TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3));
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_R_4 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.r;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_G_5 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.g;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_B_6 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.b;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_A_7 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.a;
            UnityTexture2D _Property_e53f115c5350438db818ee2e25e84f66_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_4f7017334adb4c31b376db39df7ead2d);
            float _Property_9387fc1c17c047f4be709f020e55ec34_Out_0 = _CenterMove;
            float _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9387fc1c17c047f4be709f020e55ec34_Out_0, _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2);
            float _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0 = _RadialScale;
            float _Property_083539affd1242babdd9157da68bf4cb_Out_0 = _LengthScale;
            float2 _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4;
            Unity_PolarCoordinates_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0, _Property_083539affd1242babdd9157da68bf4cb_Out_0, _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4);
            float2 _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2;
            Unity_Add_float2((_Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2.xx), _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4, _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2);
            float4 _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e53f115c5350438db818ee2e25e84f66_Out_0.tex, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.samplerstate, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.GetTransformedUV(_Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2));
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_R_4 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.r;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_G_5 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.g;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_B_6 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.b;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_A_7 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.a;
            float4 _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0, _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2);
            float _Split_57fa424231f8454c962dff75f2eb208a_R_1 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[0];
            float _Split_57fa424231f8454c962dff75f2eb208a_G_2 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[1];
            float _Split_57fa424231f8454c962dff75f2eb208a_B_3 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[2];
            float _Split_57fa424231f8454c962dff75f2eb208a_A_4 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[3];
            surface.Alpha = _Split_57fa424231f8454c962dff75f2eb208a_R_1;
            surface.AlphaClipThreshold = 0.5;
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
        Cull [_Cull]
        
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
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
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
        float4 Color_18d890ee80824248a51ee0a2b47a330e;
        float4 Texture2D_bc1d9eb6d4344d4084d949d7b33e529a_TexelSize;
        float4 Texture2D_4f7017334adb4c31b376db39df7ead2d_TexelSize;
        float2 Vector2_47b54501113b4c409f7770bf21e02d97;
        float _CenterMove;
        float _RadialScale;
        float _LengthScale;
        float _GlowPower;
        float2 _TextureUV;
        float2 _Offset;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        SAMPLER(samplerTexture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        TEXTURE2D(Texture2D_4f7017334adb4c31b376db39df7ead2d);
        SAMPLER(samplerTexture2D_4f7017334adb4c31b376db39df7ead2d);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
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
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
            float2 _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0 = _TextureUV;
            float2 _Property_fc0085f8f562417086ae555779a1a5e9_Out_0 = _Offset;
            float2 _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0, _Property_fc0085f8f562417086ae555779a1a5e9_Out_0, _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3);
            float4 _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.tex, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.samplerstate, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.GetTransformedUV(_TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3));
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_R_4 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.r;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_G_5 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.g;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_B_6 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.b;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_A_7 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.a;
            UnityTexture2D _Property_e53f115c5350438db818ee2e25e84f66_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_4f7017334adb4c31b376db39df7ead2d);
            float _Property_9387fc1c17c047f4be709f020e55ec34_Out_0 = _CenterMove;
            float _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9387fc1c17c047f4be709f020e55ec34_Out_0, _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2);
            float _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0 = _RadialScale;
            float _Property_083539affd1242babdd9157da68bf4cb_Out_0 = _LengthScale;
            float2 _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4;
            Unity_PolarCoordinates_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0, _Property_083539affd1242babdd9157da68bf4cb_Out_0, _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4);
            float2 _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2;
            Unity_Add_float2((_Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2.xx), _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4, _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2);
            float4 _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e53f115c5350438db818ee2e25e84f66_Out_0.tex, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.samplerstate, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.GetTransformedUV(_Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2));
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_R_4 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.r;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_G_5 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.g;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_B_6 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.b;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_A_7 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.a;
            float4 _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0, _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2);
            float _Split_57fa424231f8454c962dff75f2eb208a_R_1 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[0];
            float _Split_57fa424231f8454c962dff75f2eb208a_G_2 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[1];
            float _Split_57fa424231f8454c962dff75f2eb208a_B_3 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[2];
            float _Split_57fa424231f8454c962dff75f2eb208a_A_4 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[3];
            surface.Alpha = _Split_57fa424231f8454c962dff75f2eb208a_R_1;
            surface.AlphaClipThreshold = 0.5;
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
        Cull [_Cull]
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
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
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
        float4 Color_18d890ee80824248a51ee0a2b47a330e;
        float4 Texture2D_bc1d9eb6d4344d4084d949d7b33e529a_TexelSize;
        float4 Texture2D_4f7017334adb4c31b376db39df7ead2d_TexelSize;
        float2 Vector2_47b54501113b4c409f7770bf21e02d97;
        float _CenterMove;
        float _RadialScale;
        float _LengthScale;
        float _GlowPower;
        float2 _TextureUV;
        float2 _Offset;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        SAMPLER(samplerTexture2D_bc1d9eb6d4344d4084d949d7b33e529a);
        TEXTURE2D(Texture2D_4f7017334adb4c31b376db39df7ead2d);
        SAMPLER(samplerTexture2D_4f7017334adb4c31b376db39df7ead2d);
        
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
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale, out float2 Out)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            Out = float2(radius, angle);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
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
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_bc1d9eb6d4344d4084d949d7b33e529a);
            float2 _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0 = _TextureUV;
            float2 _Property_fc0085f8f562417086ae555779a1a5e9_Out_0 = _Offset;
            float2 _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ab841cbd569f4e04a26ed3c5cb81b536_Out_0, _Property_fc0085f8f562417086ae555779a1a5e9_Out_0, _TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3);
            float4 _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.tex, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.samplerstate, _Property_5891bba0aebe4bf2b31acc2e171b012e_Out_0.GetTransformedUV(_TilingAndOffset_1380d1065c91459d87f391d42d863d5b_Out_3));
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_R_4 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.r;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_G_5 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.g;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_B_6 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.b;
            float _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_A_7 = _SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0.a;
            UnityTexture2D _Property_e53f115c5350438db818ee2e25e84f66_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_4f7017334adb4c31b376db39df7ead2d);
            float _Property_9387fc1c17c047f4be709f020e55ec34_Out_0 = _CenterMove;
            float _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_9387fc1c17c047f4be709f020e55ec34_Out_0, _Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2);
            float _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0 = _RadialScale;
            float _Property_083539affd1242babdd9157da68bf4cb_Out_0 = _LengthScale;
            float2 _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4;
            Unity_PolarCoordinates_float(IN.uv0.xy, float2 (0.5, 0.5), _Property_37fc07ab4bc24dca91dd91c05783885a_Out_0, _Property_083539affd1242babdd9157da68bf4cb_Out_0, _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4);
            float2 _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2;
            Unity_Add_float2((_Multiply_a373401042c648f6ac4b2ed2422bc8bc_Out_2.xx), _PolarCoordinates_24cc83dddfd0418c9ba9f8b355330f3d_Out_4, _Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2);
            float4 _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e53f115c5350438db818ee2e25e84f66_Out_0.tex, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.samplerstate, _Property_e53f115c5350438db818ee2e25e84f66_Out_0.GetTransformedUV(_Add_6b18f81639294ea7b3c26d03ec7e3346_Out_2));
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_R_4 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.r;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_G_5 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.g;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_B_6 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.b;
            float _SampleTexture2D_b792db77a11748a88494980d164a77ed_A_7 = _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0.a;
            float4 _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_fe0d963923a94d97b5d0da26f130eab5_RGBA_0, _SampleTexture2D_b792db77a11748a88494980d164a77ed_RGBA_0, _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2);
            float _Split_57fa424231f8454c962dff75f2eb208a_R_1 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[0];
            float _Split_57fa424231f8454c962dff75f2eb208a_G_2 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[1];
            float _Split_57fa424231f8454c962dff75f2eb208a_B_3 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[2];
            float _Split_57fa424231f8454c962dff75f2eb208a_A_4 = _Multiply_5c340ccb4c5f44d7b13f7b4357b90fc6_Out_2[3];
            surface.Alpha = _Split_57fa424231f8454c962dff75f2eb208a_R_1;
            surface.AlphaClipThreshold = 0.5;
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