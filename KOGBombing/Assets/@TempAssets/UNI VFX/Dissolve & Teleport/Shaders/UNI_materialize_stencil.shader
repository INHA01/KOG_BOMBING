Shader "Custom/UNI_materialize_stencil"
{
    Properties
    {
        [NoScaleOffset]_Texture("Texture", 2D) = "white" {}
        [NoScaleOffset]_MaterializePattern("MaterializePattern", 2D) = "white" {}
        [NoScaleOffset]_MaterializeOverlay("MaterializeOverlay", 2D) = "white" {}
        [NoScaleOffset]_NormalMap("NormalMap", 2D) = "white" {}
        [ToggleUI]_UseMetalicSmoothnessTexture("UseMetalicSmoothnessTexture", Float) = 0
        [NoScaleOffset]_MetalicSmoothnessTexture("MetalicSmoothnessTexture", 2D) = "white" {}
        _Smoothness("Smoothness", Float) = 0.5
        [ToggleUI]_UseAmbientOcclusionTexture("UseAmbientOcclusionTexture", Float) = 0
        [NoScaleOffset]_AmbientOcclusionTexture("AmbientOcclusionTexture", 2D) = "white" {}
        [ToggleUI]_UseEmissionMap("UseEmissionMap", Float) = 0
        [NoScaleOffset]_EmissionMap("EmissionMap", 2D) = "white" {}
        [HDR]_EmissionMapColor("EmissionMapColor", Color) = (0, 0, 0, 0)
        _Materialize("MaterializeProgress", Float) = 0.4
        _MaterializeProgressFuzzyness("MaterializeProgressFuzzyness", Range(0.5, 4)) = 1
        [NoScaleOffset]_MaterializeGradient("MaterializeGradient", 2D) = "white" {}
        [HDR]_MaterializeOverlayColor("MaterializeOverlayColor", Color) = (0, 0.8784314, 11.98431, 0)
        [ToggleUI]_MaterializeOverlayAdditive("MaterializeOverlayAdditive", Float) = 1
        _MaterializeOverlayAnimationMultiplier("MaterializeOverlayAnimationMultiplier", Float) = 0.5
        _MaterializeEdgeThickness("MaterializeEdgeThickness", Float) = 0.5
        [HDR]_MaterializeEdgeColor("MaterializeEdgeColor", Color) = (0, 2.345549, 32, 0)
        _MaterializePatternSpeed("MaterializePatternSpeed", Vector) = (0.2, 0.2, 0, 0)
        _MaterializePatternOffset("MaterializePatternOffset", Vector) = (0, 0, 0, 0)
        _DisplacementMultiplier("DisplacementMultiplier", Float) = 0.225
        _DisplacementNoiseScale("DisplacementNoiseScale", Float) = 1
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
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
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
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        
        
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
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
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
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
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
             float3 TangentSpaceNormal;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
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
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
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
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
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
        float4 _Texture_TexelSize;
        float2 _MaterializePatternSpeed;
        float _Materialize;
        float _MaterializeEdgeThickness;
        float4 _MaterializeEdgeColor;
        float _DisplacementMultiplier;
        float2 _MaterializePatternOffset;
        float4 _MaterializePattern_TexelSize;
        float _DisplacementNoiseScale;
        float _UseMetalicSmoothnessTexture;
        float4 _MetalicSmoothnessTexture_TexelSize;
        float _Smoothness;
        float _UseAmbientOcclusionTexture;
        float4 _AmbientOcclusionTexture_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MaterializeOverlay_TexelSize;
        float4 _MaterializeOverlayColor;
        float _UseEmissionMap;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionMapColor;
        float _MaterializeOverlayAnimationMultiplier;
        float4 _MaterializeGradient_TexelSize;
        float _MaterializeProgressFuzzyness;
        float _MaterializeOverlayAdditive;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);
        TEXTURE2D(_MaterializePattern);
        SAMPLER(sampler_MaterializePattern);
        TEXTURE2D(_MetalicSmoothnessTexture);
        SAMPLER(sampler_MetalicSmoothnessTexture);
        TEXTURE2D(_AmbientOcclusionTexture);
        SAMPLER(sampler_AmbientOcclusionTexture);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MaterializeOverlay);
        SAMPLER(sampler_MaterializeOverlay);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_MaterializeGradient);
        SAMPLER(sampler_MaterializeGradient);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
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
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
        {
            Out = A >= B ? 1 : 0;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_InvertColors_float(float In, float InvertColors, out float Out)
        {
            Out = abs(InvertColors - In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
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
            float _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.75, _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float);
            float3 _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, (_Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float.xxx), _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3);
            float _Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float = _DisplacementNoiseScale;
            float _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float;
            Unity_Multiply_float_float(_Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float, 32, _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float);
            float _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3.xy), _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float, _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float);
            float _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float = _DisplacementMultiplier;
            float _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float, _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float, _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float);
            float3 _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float.xxx), _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3);
            float3 _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3, _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3);
            description.Position = _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
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
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_a3bac5175b994837b4f5281412593963_Out_0_Float = _Materialize;
            float _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean;
            Unity_Comparison_GreaterOrEqual_float(_Property_a3bac5175b994837b4f5281412593963_Out_0_Float, float(1), _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean);
            UnityTexture2D _Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Texture);
            float4 _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D.tex, _Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D.samplerstate, _Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_R_4_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.r;
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_G_5_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.g;
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_B_6_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.b;
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_A_7_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.a;
            float _Property_0ea60c8d6e2544f683a3e4b047f23b1e_Out_0_Boolean = _MaterializeOverlayAdditive;
            float _Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float = _Materialize;
            float _Remap_90912e15fc1e4921a98627b2ed8d3d64_Out_3_Float;
            Unity_Remap_float(_Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float, float2 (0, 1), float2 (1, 0), _Remap_90912e15fc1e4921a98627b2ed8d3d64_Out_3_Float);
            UnityTexture2D _Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializeOverlay);
            float _Property_494983ed5fe14b8abeb57c66e6821b33_Out_0_Float = _MaterializeOverlayAnimationMultiplier;
            float _Multiply_81e791815eb847d59e6e5c437a14b2d5_Out_2_Float;
            Unity_Multiply_float_float(_Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float, _Property_494983ed5fe14b8abeb57c66e6821b33_Out_0_Float, _Multiply_81e791815eb847d59e6e5c437a14b2d5_Out_2_Float);
            float2 _TilingAndOffset_1444b6a7b7184ce08d3aab27f20fc48d_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_81e791815eb847d59e6e5c437a14b2d5_Out_2_Float.xx), _TilingAndOffset_1444b6a7b7184ce08d3aab27f20fc48d_Out_3_Vector2);
            float4 _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D.tex, _Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D.samplerstate, _Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_1444b6a7b7184ce08d3aab27f20fc48d_Out_3_Vector2) );
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_R_4_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.r;
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_G_5_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.g;
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_B_6_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.b;
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_A_7_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.a;
            float4 _Property_15126782a7ba443990248009a1350bb3_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_MaterializeOverlayColor) : _MaterializeOverlayColor;
            float4 _Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4, _Property_15126782a7ba443990248009a1350bb3_Out_0_Vector4, _Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4);
            float4 _Multiply_bccb3756950e40119be06b905e5b6405_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Remap_90912e15fc1e4921a98627b2ed8d3d64_Out_3_Float.xxxx), _Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4, _Multiply_bccb3756950e40119be06b905e5b6405_Out_2_Vector4);
            float4 _Add_f22b18e43a5946c0a31b1f37817ea4ca_Out_2_Vector4;
            Unity_Add_float4(_Multiply_bccb3756950e40119be06b905e5b6405_Out_2_Vector4, _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4, _Add_f22b18e43a5946c0a31b1f37817ea4ca_Out_2_Vector4);
            float _Remap_39a1707f02764a938d7a98d944dcc82e_Out_3_Float;
            Unity_Remap_float(_Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float, float2 (0, 1), float2 (1, 0), _Remap_39a1707f02764a938d7a98d944dcc82e_Out_3_Float);
            float _Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float;
            Unity_Step_float(_Remap_39a1707f02764a938d7a98d944dcc82e_Out_3_Float, _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_A_7_Float, _Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float);
            float4 _Multiply_f43602d028a9492db199f4800ee15fce_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4, (_Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float.xxxx), _Multiply_f43602d028a9492db199f4800ee15fce_Out_2_Vector4);
            float _InvertColors_d91e267a2530448fa9881a3f58cec2e0_Out_1_Float;
            float _InvertColors_d91e267a2530448fa9881a3f58cec2e0_InvertColors = float (1);
            Unity_InvertColors_float(_Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float, _InvertColors_d91e267a2530448fa9881a3f58cec2e0_InvertColors, _InvertColors_d91e267a2530448fa9881a3f58cec2e0_Out_1_Float);
            float4 _Multiply_675b556841c242bb9bab88c13d87487e_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4, (_InvertColors_d91e267a2530448fa9881a3f58cec2e0_Out_1_Float.xxxx), _Multiply_675b556841c242bb9bab88c13d87487e_Out_2_Vector4);
            float4 _Add_a1ca4ae8ae6145059dcefc82c48a6da7_Out_2_Vector4;
            Unity_Add_float4(_Multiply_f43602d028a9492db199f4800ee15fce_Out_2_Vector4, _Multiply_675b556841c242bb9bab88c13d87487e_Out_2_Vector4, _Add_a1ca4ae8ae6145059dcefc82c48a6da7_Out_2_Vector4);
            float4 _Branch_7e5d2836057a4df2b983f61f22e19cfb_Out_3_Vector4;
            Unity_Branch_float4(_Property_0ea60c8d6e2544f683a3e4b047f23b1e_Out_0_Boolean, _Add_f22b18e43a5946c0a31b1f37817ea4ca_Out_2_Vector4, _Add_a1ca4ae8ae6145059dcefc82c48a6da7_Out_2_Vector4, _Branch_7e5d2836057a4df2b983f61f22e19cfb_Out_3_Vector4);
            float4 _Branch_a179767cdc8b44d2bc38d371f2ed7141_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4, _Branch_7e5d2836057a4df2b983f61f22e19cfb_Out_3_Vector4, _Branch_a179767cdc8b44d2bc38d371f2ed7141_Out_3_Vector4);
            UnityTexture2D _Property_db30d1efcb70412f865c031ae7bed0f4_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_db30d1efcb70412f865c031ae7bed0f4_Out_0_Texture2D.tex, _Property_db30d1efcb70412f865c031ae7bed0f4_Out_0_Texture2D.samplerstate, _Property_db30d1efcb70412f865c031ae7bed0f4_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4);
            float _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_R_4_Float = _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.r;
            float _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_G_5_Float = _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.g;
            float _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_B_6_Float = _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.b;
            float _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_A_7_Float = _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.a;
            float _Property_518fc3a8c5d042f29158fcb31d21e33b_Out_0_Boolean = _UseEmissionMap;
            UnityTexture2D _Property_db69d72a62b54c16847eb5f0fd37b574_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_db69d72a62b54c16847eb5f0fd37b574_Out_0_Texture2D.tex, _Property_db69d72a62b54c16847eb5f0fd37b574_Out_0_Texture2D.samplerstate, _Property_db69d72a62b54c16847eb5f0fd37b574_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_R_4_Float = _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4.r;
            float _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_G_5_Float = _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4.g;
            float _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_B_6_Float = _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4.b;
            float _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_A_7_Float = _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4.a;
            float4 _Property_1e14290db73848bba9a45e6e61b7c0b0_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EmissionMapColor) : _EmissionMapColor;
            float4 _Multiply_63b205abc9904d618f247127a58a76a9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4, _Property_1e14290db73848bba9a45e6e61b7c0b0_Out_0_Vector4, _Multiply_63b205abc9904d618f247127a58a76a9_Out_2_Vector4);
            float4 _Branch_c1d25148e2f64c1e9264c83e33ba98bb_Out_3_Vector4;
            Unity_Branch_float4(_Property_518fc3a8c5d042f29158fcb31d21e33b_Out_0_Boolean, _Multiply_63b205abc9904d618f247127a58a76a9_Out_2_Vector4, float4(0, 0, 0, 0), _Branch_c1d25148e2f64c1e9264c83e33ba98bb_Out_3_Vector4);
            UnityTexture2D _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializePattern);
            float2 _Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2 = _MaterializePatternSpeed;
            float2 _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2);
            float2 _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2 = _MaterializePatternOffset;
            float2 _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2;
            Unity_Add_float2(_Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2, _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2, _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2);
            float2 _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2, _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2);
            float4 _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.tex, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.samplerstate, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2) );
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_R_4_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.r;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_G_5_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.g;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_B_6_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.b;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_A_7_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.a;
            float _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float = _MaterializeProgressFuzzyness;
            float _Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float = _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float;
            float4 _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4, (_Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float.xxxx), _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4);
            float4 _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4;
            Unity_Remap_float4(_Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4, float2 (0, 1), float2 (0, 1), _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4);
            float _Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float = _Materialize;
            float _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float;
            Unity_Remap_float(_Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float, float2 (0.5, 4), float2 (-0.48, -4), _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float);
            float2 _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2 = float2(_Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float, float(6.8));
            float _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float;
            Unity_Remap_float(_Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float, float2 (0, 1), _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2, _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float);
            float4 _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4;
            Unity_Add_float4(_Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4, (_Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float.xxxx), _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4);
            UnityTexture2D _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializeGradient);
            float4 _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.tex, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.samplerstate, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_R_4_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.r;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_G_5_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.g;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_B_6_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.b;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_A_7_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.a;
            float _Float_af319994f61d4f36869407adddc4ca24_Out_0_Float = float(6);
            float4 _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4, (_Float_af319994f61d4f36869407adddc4ca24_Out_0_Float.xxxx), _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4);
            float _Property_62462ec80ca54d32801e27ab56457cb5_Out_0_Float = _MaterializeEdgeThickness;
            float4 _Add_cf79ed208d7e4f4597a05f2029693461_Out_2_Vector4;
            Unity_Add_float4(_Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4, (_Property_62462ec80ca54d32801e27ab56457cb5_Out_0_Float.xxxx), _Add_cf79ed208d7e4f4597a05f2029693461_Out_2_Vector4);
            float4 _Step_4e96a5da98ca40e682327543e9f2012a_Out_2_Vector4;
            Unity_Step_float4(_Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4, _Add_cf79ed208d7e4f4597a05f2029693461_Out_2_Vector4, _Step_4e96a5da98ca40e682327543e9f2012a_Out_2_Vector4);
            float4 _Property_fe85e453c9c84c01a99eba30403f5cc0_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_MaterializeEdgeColor) : _MaterializeEdgeColor;
            float4 _Multiply_48862d5d23aa4b43ba1efd05ea712c45_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Step_4e96a5da98ca40e682327543e9f2012a_Out_2_Vector4, _Property_fe85e453c9c84c01a99eba30403f5cc0_Out_0_Vector4, _Multiply_48862d5d23aa4b43ba1efd05ea712c45_Out_2_Vector4);
            float4 _Add_16a704880c23416a9576210959a2150a_Out_2_Vector4;
            Unity_Add_float4(_Multiply_48862d5d23aa4b43ba1efd05ea712c45_Out_2_Vector4, _Branch_c1d25148e2f64c1e9264c83e33ba98bb_Out_3_Vector4, _Add_16a704880c23416a9576210959a2150a_Out_2_Vector4);
            float4 _Branch_f48e6cdeedb64594bc3b04777f15cd0a_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, _Branch_c1d25148e2f64c1e9264c83e33ba98bb_Out_3_Vector4, _Add_16a704880c23416a9576210959a2150a_Out_2_Vector4, _Branch_f48e6cdeedb64594bc3b04777f15cd0a_Out_3_Vector4);
            float _Property_21b603d446cc4a1b8b19776422fd02cc_Out_0_Boolean = _UseMetalicSmoothnessTexture;
            UnityTexture2D _Property_6b4115211b2a419fa4d11fd6ac79cdaf_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MetalicSmoothnessTexture);
            float4 _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6b4115211b2a419fa4d11fd6ac79cdaf_Out_0_Texture2D.tex, _Property_6b4115211b2a419fa4d11fd6ac79cdaf_Out_0_Texture2D.samplerstate, _Property_6b4115211b2a419fa4d11fd6ac79cdaf_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_R_4_Float = _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_RGBA_0_Vector4.r;
            float _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_G_5_Float = _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_RGBA_0_Vector4.g;
            float _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_B_6_Float = _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_RGBA_0_Vector4.b;
            float _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_A_7_Float = _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_RGBA_0_Vector4.a;
            float _Float_8a8bc976b1da47aaad02c2e22fb21ea4_Out_0_Float = float(0);
            float _Branch_bc566b9c32b04cb08410415f06f44ed5_Out_3_Float;
            Unity_Branch_float(_Property_21b603d446cc4a1b8b19776422fd02cc_Out_0_Boolean, _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_R_4_Float, _Float_8a8bc976b1da47aaad02c2e22fb21ea4_Out_0_Float, _Branch_bc566b9c32b04cb08410415f06f44ed5_Out_3_Float);
            float _Property_27853262343a487fb4a80c5cd6e9607f_Out_0_Boolean = _UseMetalicSmoothnessTexture;
            float _Property_c4f33052c5af4c889d7c603d4fae90ff_Out_0_Float = _Smoothness;
            float _Multiply_d8a317f8094f4597a6559e9ee5430fdc_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_A_7_Float, _Property_c4f33052c5af4c889d7c603d4fae90ff_Out_0_Float, _Multiply_d8a317f8094f4597a6559e9ee5430fdc_Out_2_Float);
            float _Branch_7ee3d44922f74917a1b4c10d99579587_Out_3_Float;
            Unity_Branch_float(_Property_27853262343a487fb4a80c5cd6e9607f_Out_0_Boolean, _Multiply_d8a317f8094f4597a6559e9ee5430fdc_Out_2_Float, _Property_c4f33052c5af4c889d7c603d4fae90ff_Out_0_Float, _Branch_7ee3d44922f74917a1b4c10d99579587_Out_3_Float);
            float _Property_4ab3a3fa83e64f02b5c395d18395130c_Out_0_Boolean = _UseAmbientOcclusionTexture;
            UnityTexture2D _Property_68a1e76504e44bdba0c07c3f11f2eb64_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_AmbientOcclusionTexture);
            float4 _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_68a1e76504e44bdba0c07c3f11f2eb64_Out_0_Texture2D.tex, _Property_68a1e76504e44bdba0c07c3f11f2eb64_Out_0_Texture2D.samplerstate, _Property_68a1e76504e44bdba0c07c3f11f2eb64_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_R_4_Float = _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_RGBA_0_Vector4.r;
            float _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_G_5_Float = _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_RGBA_0_Vector4.g;
            float _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_B_6_Float = _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_RGBA_0_Vector4.b;
            float _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_A_7_Float = _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_RGBA_0_Vector4.a;
            float _Float_da627d9ed3714022b2f4406f414952da_Out_0_Float = float(1);
            float4 _Branch_132aa89bcd9844268a33b692ac458494_Out_3_Vector4;
            Unity_Branch_float4(_Property_4ab3a3fa83e64f02b5c395d18395130c_Out_0_Boolean, _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_RGBA_0_Vector4, (_Float_da627d9ed3714022b2f4406f414952da_Out_0_Float.xxxx), _Branch_132aa89bcd9844268a33b692ac458494_Out_3_Vector4);
            float _Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float = float(1);
            float4 _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4;
            Unity_Step_float4(_Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4, _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4, _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4);
            float4 _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, (_Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float.xxxx), _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4, _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4);
            surface.BaseColor = (_Branch_a179767cdc8b44d2bc38d371f2ed7141_Out_3_Vector4.xyz);
            surface.NormalTS = (_SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.xyz);
            surface.Emission = (_Branch_f48e6cdeedb64594bc3b04777f15cd0a_Out_3_Vector4.xyz);
            surface.Metallic = _Branch_bc566b9c32b04cb08410415f06f44ed5_Out_3_Float;
            surface.Smoothness = _Branch_7ee3d44922f74917a1b4c10d99579587_Out_3_Float;
            surface.Occlusion = (_Branch_132aa89bcd9844268a33b692ac458494_Out_3_Vector4).x;
            surface.Alpha = (_Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4).x;
            surface.AlphaClipThreshold = float(0.5);
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
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
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
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        
        
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
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
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
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
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
             float3 TangentSpaceNormal;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
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
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
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
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
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
        float4 _Texture_TexelSize;
        float2 _MaterializePatternSpeed;
        float _Materialize;
        float _MaterializeEdgeThickness;
        float4 _MaterializeEdgeColor;
        float _DisplacementMultiplier;
        float2 _MaterializePatternOffset;
        float4 _MaterializePattern_TexelSize;
        float _DisplacementNoiseScale;
        float _UseMetalicSmoothnessTexture;
        float4 _MetalicSmoothnessTexture_TexelSize;
        float _Smoothness;
        float _UseAmbientOcclusionTexture;
        float4 _AmbientOcclusionTexture_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MaterializeOverlay_TexelSize;
        float4 _MaterializeOverlayColor;
        float _UseEmissionMap;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionMapColor;
        float _MaterializeOverlayAnimationMultiplier;
        float4 _MaterializeGradient_TexelSize;
        float _MaterializeProgressFuzzyness;
        float _MaterializeOverlayAdditive;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);
        TEXTURE2D(_MaterializePattern);
        SAMPLER(sampler_MaterializePattern);
        TEXTURE2D(_MetalicSmoothnessTexture);
        SAMPLER(sampler_MetalicSmoothnessTexture);
        TEXTURE2D(_AmbientOcclusionTexture);
        SAMPLER(sampler_AmbientOcclusionTexture);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MaterializeOverlay);
        SAMPLER(sampler_MaterializeOverlay);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_MaterializeGradient);
        SAMPLER(sampler_MaterializeGradient);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
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
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
        {
            Out = A >= B ? 1 : 0;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_InvertColors_float(float In, float InvertColors, out float Out)
        {
            Out = abs(InvertColors - In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
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
            float _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.75, _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float);
            float3 _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, (_Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float.xxx), _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3);
            float _Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float = _DisplacementNoiseScale;
            float _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float;
            Unity_Multiply_float_float(_Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float, 32, _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float);
            float _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3.xy), _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float, _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float);
            float _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float = _DisplacementMultiplier;
            float _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float, _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float, _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float);
            float3 _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float.xxx), _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3);
            float3 _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3, _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3);
            description.Position = _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
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
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_a3bac5175b994837b4f5281412593963_Out_0_Float = _Materialize;
            float _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean;
            Unity_Comparison_GreaterOrEqual_float(_Property_a3bac5175b994837b4f5281412593963_Out_0_Float, float(1), _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean);
            UnityTexture2D _Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Texture);
            float4 _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D.tex, _Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D.samplerstate, _Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_R_4_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.r;
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_G_5_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.g;
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_B_6_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.b;
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_A_7_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.a;
            float _Property_0ea60c8d6e2544f683a3e4b047f23b1e_Out_0_Boolean = _MaterializeOverlayAdditive;
            float _Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float = _Materialize;
            float _Remap_90912e15fc1e4921a98627b2ed8d3d64_Out_3_Float;
            Unity_Remap_float(_Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float, float2 (0, 1), float2 (1, 0), _Remap_90912e15fc1e4921a98627b2ed8d3d64_Out_3_Float);
            UnityTexture2D _Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializeOverlay);
            float _Property_494983ed5fe14b8abeb57c66e6821b33_Out_0_Float = _MaterializeOverlayAnimationMultiplier;
            float _Multiply_81e791815eb847d59e6e5c437a14b2d5_Out_2_Float;
            Unity_Multiply_float_float(_Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float, _Property_494983ed5fe14b8abeb57c66e6821b33_Out_0_Float, _Multiply_81e791815eb847d59e6e5c437a14b2d5_Out_2_Float);
            float2 _TilingAndOffset_1444b6a7b7184ce08d3aab27f20fc48d_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_81e791815eb847d59e6e5c437a14b2d5_Out_2_Float.xx), _TilingAndOffset_1444b6a7b7184ce08d3aab27f20fc48d_Out_3_Vector2);
            float4 _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D.tex, _Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D.samplerstate, _Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_1444b6a7b7184ce08d3aab27f20fc48d_Out_3_Vector2) );
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_R_4_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.r;
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_G_5_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.g;
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_B_6_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.b;
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_A_7_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.a;
            float4 _Property_15126782a7ba443990248009a1350bb3_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_MaterializeOverlayColor) : _MaterializeOverlayColor;
            float4 _Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4, _Property_15126782a7ba443990248009a1350bb3_Out_0_Vector4, _Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4);
            float4 _Multiply_bccb3756950e40119be06b905e5b6405_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Remap_90912e15fc1e4921a98627b2ed8d3d64_Out_3_Float.xxxx), _Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4, _Multiply_bccb3756950e40119be06b905e5b6405_Out_2_Vector4);
            float4 _Add_f22b18e43a5946c0a31b1f37817ea4ca_Out_2_Vector4;
            Unity_Add_float4(_Multiply_bccb3756950e40119be06b905e5b6405_Out_2_Vector4, _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4, _Add_f22b18e43a5946c0a31b1f37817ea4ca_Out_2_Vector4);
            float _Remap_39a1707f02764a938d7a98d944dcc82e_Out_3_Float;
            Unity_Remap_float(_Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float, float2 (0, 1), float2 (1, 0), _Remap_39a1707f02764a938d7a98d944dcc82e_Out_3_Float);
            float _Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float;
            Unity_Step_float(_Remap_39a1707f02764a938d7a98d944dcc82e_Out_3_Float, _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_A_7_Float, _Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float);
            float4 _Multiply_f43602d028a9492db199f4800ee15fce_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4, (_Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float.xxxx), _Multiply_f43602d028a9492db199f4800ee15fce_Out_2_Vector4);
            float _InvertColors_d91e267a2530448fa9881a3f58cec2e0_Out_1_Float;
            float _InvertColors_d91e267a2530448fa9881a3f58cec2e0_InvertColors = float (1);
            Unity_InvertColors_float(_Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float, _InvertColors_d91e267a2530448fa9881a3f58cec2e0_InvertColors, _InvertColors_d91e267a2530448fa9881a3f58cec2e0_Out_1_Float);
            float4 _Multiply_675b556841c242bb9bab88c13d87487e_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4, (_InvertColors_d91e267a2530448fa9881a3f58cec2e0_Out_1_Float.xxxx), _Multiply_675b556841c242bb9bab88c13d87487e_Out_2_Vector4);
            float4 _Add_a1ca4ae8ae6145059dcefc82c48a6da7_Out_2_Vector4;
            Unity_Add_float4(_Multiply_f43602d028a9492db199f4800ee15fce_Out_2_Vector4, _Multiply_675b556841c242bb9bab88c13d87487e_Out_2_Vector4, _Add_a1ca4ae8ae6145059dcefc82c48a6da7_Out_2_Vector4);
            float4 _Branch_7e5d2836057a4df2b983f61f22e19cfb_Out_3_Vector4;
            Unity_Branch_float4(_Property_0ea60c8d6e2544f683a3e4b047f23b1e_Out_0_Boolean, _Add_f22b18e43a5946c0a31b1f37817ea4ca_Out_2_Vector4, _Add_a1ca4ae8ae6145059dcefc82c48a6da7_Out_2_Vector4, _Branch_7e5d2836057a4df2b983f61f22e19cfb_Out_3_Vector4);
            float4 _Branch_a179767cdc8b44d2bc38d371f2ed7141_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4, _Branch_7e5d2836057a4df2b983f61f22e19cfb_Out_3_Vector4, _Branch_a179767cdc8b44d2bc38d371f2ed7141_Out_3_Vector4);
            UnityTexture2D _Property_db30d1efcb70412f865c031ae7bed0f4_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_db30d1efcb70412f865c031ae7bed0f4_Out_0_Texture2D.tex, _Property_db30d1efcb70412f865c031ae7bed0f4_Out_0_Texture2D.samplerstate, _Property_db30d1efcb70412f865c031ae7bed0f4_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4);
            float _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_R_4_Float = _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.r;
            float _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_G_5_Float = _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.g;
            float _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_B_6_Float = _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.b;
            float _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_A_7_Float = _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.a;
            float _Property_518fc3a8c5d042f29158fcb31d21e33b_Out_0_Boolean = _UseEmissionMap;
            UnityTexture2D _Property_db69d72a62b54c16847eb5f0fd37b574_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_db69d72a62b54c16847eb5f0fd37b574_Out_0_Texture2D.tex, _Property_db69d72a62b54c16847eb5f0fd37b574_Out_0_Texture2D.samplerstate, _Property_db69d72a62b54c16847eb5f0fd37b574_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_R_4_Float = _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4.r;
            float _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_G_5_Float = _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4.g;
            float _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_B_6_Float = _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4.b;
            float _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_A_7_Float = _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4.a;
            float4 _Property_1e14290db73848bba9a45e6e61b7c0b0_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EmissionMapColor) : _EmissionMapColor;
            float4 _Multiply_63b205abc9904d618f247127a58a76a9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4, _Property_1e14290db73848bba9a45e6e61b7c0b0_Out_0_Vector4, _Multiply_63b205abc9904d618f247127a58a76a9_Out_2_Vector4);
            float4 _Branch_c1d25148e2f64c1e9264c83e33ba98bb_Out_3_Vector4;
            Unity_Branch_float4(_Property_518fc3a8c5d042f29158fcb31d21e33b_Out_0_Boolean, _Multiply_63b205abc9904d618f247127a58a76a9_Out_2_Vector4, float4(0, 0, 0, 0), _Branch_c1d25148e2f64c1e9264c83e33ba98bb_Out_3_Vector4);
            UnityTexture2D _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializePattern);
            float2 _Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2 = _MaterializePatternSpeed;
            float2 _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2);
            float2 _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2 = _MaterializePatternOffset;
            float2 _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2;
            Unity_Add_float2(_Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2, _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2, _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2);
            float2 _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2, _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2);
            float4 _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.tex, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.samplerstate, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2) );
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_R_4_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.r;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_G_5_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.g;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_B_6_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.b;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_A_7_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.a;
            float _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float = _MaterializeProgressFuzzyness;
            float _Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float = _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float;
            float4 _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4, (_Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float.xxxx), _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4);
            float4 _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4;
            Unity_Remap_float4(_Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4, float2 (0, 1), float2 (0, 1), _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4);
            float _Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float = _Materialize;
            float _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float;
            Unity_Remap_float(_Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float, float2 (0.5, 4), float2 (-0.48, -4), _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float);
            float2 _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2 = float2(_Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float, float(6.8));
            float _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float;
            Unity_Remap_float(_Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float, float2 (0, 1), _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2, _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float);
            float4 _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4;
            Unity_Add_float4(_Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4, (_Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float.xxxx), _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4);
            UnityTexture2D _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializeGradient);
            float4 _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.tex, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.samplerstate, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_R_4_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.r;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_G_5_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.g;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_B_6_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.b;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_A_7_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.a;
            float _Float_af319994f61d4f36869407adddc4ca24_Out_0_Float = float(6);
            float4 _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4, (_Float_af319994f61d4f36869407adddc4ca24_Out_0_Float.xxxx), _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4);
            float _Property_62462ec80ca54d32801e27ab56457cb5_Out_0_Float = _MaterializeEdgeThickness;
            float4 _Add_cf79ed208d7e4f4597a05f2029693461_Out_2_Vector4;
            Unity_Add_float4(_Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4, (_Property_62462ec80ca54d32801e27ab56457cb5_Out_0_Float.xxxx), _Add_cf79ed208d7e4f4597a05f2029693461_Out_2_Vector4);
            float4 _Step_4e96a5da98ca40e682327543e9f2012a_Out_2_Vector4;
            Unity_Step_float4(_Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4, _Add_cf79ed208d7e4f4597a05f2029693461_Out_2_Vector4, _Step_4e96a5da98ca40e682327543e9f2012a_Out_2_Vector4);
            float4 _Property_fe85e453c9c84c01a99eba30403f5cc0_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_MaterializeEdgeColor) : _MaterializeEdgeColor;
            float4 _Multiply_48862d5d23aa4b43ba1efd05ea712c45_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Step_4e96a5da98ca40e682327543e9f2012a_Out_2_Vector4, _Property_fe85e453c9c84c01a99eba30403f5cc0_Out_0_Vector4, _Multiply_48862d5d23aa4b43ba1efd05ea712c45_Out_2_Vector4);
            float4 _Add_16a704880c23416a9576210959a2150a_Out_2_Vector4;
            Unity_Add_float4(_Multiply_48862d5d23aa4b43ba1efd05ea712c45_Out_2_Vector4, _Branch_c1d25148e2f64c1e9264c83e33ba98bb_Out_3_Vector4, _Add_16a704880c23416a9576210959a2150a_Out_2_Vector4);
            float4 _Branch_f48e6cdeedb64594bc3b04777f15cd0a_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, _Branch_c1d25148e2f64c1e9264c83e33ba98bb_Out_3_Vector4, _Add_16a704880c23416a9576210959a2150a_Out_2_Vector4, _Branch_f48e6cdeedb64594bc3b04777f15cd0a_Out_3_Vector4);
            float _Property_21b603d446cc4a1b8b19776422fd02cc_Out_0_Boolean = _UseMetalicSmoothnessTexture;
            UnityTexture2D _Property_6b4115211b2a419fa4d11fd6ac79cdaf_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MetalicSmoothnessTexture);
            float4 _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_6b4115211b2a419fa4d11fd6ac79cdaf_Out_0_Texture2D.tex, _Property_6b4115211b2a419fa4d11fd6ac79cdaf_Out_0_Texture2D.samplerstate, _Property_6b4115211b2a419fa4d11fd6ac79cdaf_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_R_4_Float = _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_RGBA_0_Vector4.r;
            float _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_G_5_Float = _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_RGBA_0_Vector4.g;
            float _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_B_6_Float = _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_RGBA_0_Vector4.b;
            float _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_A_7_Float = _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_RGBA_0_Vector4.a;
            float _Float_8a8bc976b1da47aaad02c2e22fb21ea4_Out_0_Float = float(0);
            float _Branch_bc566b9c32b04cb08410415f06f44ed5_Out_3_Float;
            Unity_Branch_float(_Property_21b603d446cc4a1b8b19776422fd02cc_Out_0_Boolean, _SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_R_4_Float, _Float_8a8bc976b1da47aaad02c2e22fb21ea4_Out_0_Float, _Branch_bc566b9c32b04cb08410415f06f44ed5_Out_3_Float);
            float _Property_27853262343a487fb4a80c5cd6e9607f_Out_0_Boolean = _UseMetalicSmoothnessTexture;
            float _Property_c4f33052c5af4c889d7c603d4fae90ff_Out_0_Float = _Smoothness;
            float _Multiply_d8a317f8094f4597a6559e9ee5430fdc_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_66acc5d8658849a2b97632f29ae8ee54_A_7_Float, _Property_c4f33052c5af4c889d7c603d4fae90ff_Out_0_Float, _Multiply_d8a317f8094f4597a6559e9ee5430fdc_Out_2_Float);
            float _Branch_7ee3d44922f74917a1b4c10d99579587_Out_3_Float;
            Unity_Branch_float(_Property_27853262343a487fb4a80c5cd6e9607f_Out_0_Boolean, _Multiply_d8a317f8094f4597a6559e9ee5430fdc_Out_2_Float, _Property_c4f33052c5af4c889d7c603d4fae90ff_Out_0_Float, _Branch_7ee3d44922f74917a1b4c10d99579587_Out_3_Float);
            float _Property_4ab3a3fa83e64f02b5c395d18395130c_Out_0_Boolean = _UseAmbientOcclusionTexture;
            UnityTexture2D _Property_68a1e76504e44bdba0c07c3f11f2eb64_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_AmbientOcclusionTexture);
            float4 _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_68a1e76504e44bdba0c07c3f11f2eb64_Out_0_Texture2D.tex, _Property_68a1e76504e44bdba0c07c3f11f2eb64_Out_0_Texture2D.samplerstate, _Property_68a1e76504e44bdba0c07c3f11f2eb64_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_R_4_Float = _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_RGBA_0_Vector4.r;
            float _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_G_5_Float = _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_RGBA_0_Vector4.g;
            float _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_B_6_Float = _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_RGBA_0_Vector4.b;
            float _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_A_7_Float = _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_RGBA_0_Vector4.a;
            float _Float_da627d9ed3714022b2f4406f414952da_Out_0_Float = float(1);
            float4 _Branch_132aa89bcd9844268a33b692ac458494_Out_3_Vector4;
            Unity_Branch_float4(_Property_4ab3a3fa83e64f02b5c395d18395130c_Out_0_Boolean, _SampleTexture2D_6b9b95be9ad045dc850c59745ff4a4b9_RGBA_0_Vector4, (_Float_da627d9ed3714022b2f4406f414952da_Out_0_Float.xxxx), _Branch_132aa89bcd9844268a33b692ac458494_Out_3_Vector4);
            float _Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float = float(1);
            float4 _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4;
            Unity_Step_float4(_Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4, _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4, _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4);
            float4 _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, (_Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float.xxxx), _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4, _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4);
            surface.BaseColor = (_Branch_a179767cdc8b44d2bc38d371f2ed7141_Out_3_Vector4.xyz);
            surface.NormalTS = (_SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.xyz);
            surface.Emission = (_Branch_f48e6cdeedb64594bc3b04777f15cd0a_Out_3_Vector4.xyz);
            surface.Metallic = _Branch_bc566b9c32b04cb08410415f06f44ed5_Out_3_Float;
            surface.Smoothness = _Branch_7ee3d44922f74917a1b4c10d99579587_Out_3_Float;
            surface.Occlusion = (_Branch_132aa89bcd9844268a33b692ac458494_Out_3_Vector4).x;
            surface.Alpha = (_Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4).x;
            surface.AlphaClipThreshold = float(0.5);
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
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
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
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
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
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        
        
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
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 normalWS : INTERP1;
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
        float4 _Texture_TexelSize;
        float2 _MaterializePatternSpeed;
        float _Materialize;
        float _MaterializeEdgeThickness;
        float4 _MaterializeEdgeColor;
        float _DisplacementMultiplier;
        float2 _MaterializePatternOffset;
        float4 _MaterializePattern_TexelSize;
        float _DisplacementNoiseScale;
        float _UseMetalicSmoothnessTexture;
        float4 _MetalicSmoothnessTexture_TexelSize;
        float _Smoothness;
        float _UseAmbientOcclusionTexture;
        float4 _AmbientOcclusionTexture_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MaterializeOverlay_TexelSize;
        float4 _MaterializeOverlayColor;
        float _UseEmissionMap;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionMapColor;
        float _MaterializeOverlayAnimationMultiplier;
        float4 _MaterializeGradient_TexelSize;
        float _MaterializeProgressFuzzyness;
        float _MaterializeOverlayAdditive;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);
        TEXTURE2D(_MaterializePattern);
        SAMPLER(sampler_MaterializePattern);
        TEXTURE2D(_MetalicSmoothnessTexture);
        SAMPLER(sampler_MetalicSmoothnessTexture);
        TEXTURE2D(_AmbientOcclusionTexture);
        SAMPLER(sampler_AmbientOcclusionTexture);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MaterializeOverlay);
        SAMPLER(sampler_MaterializeOverlay);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_MaterializeGradient);
        SAMPLER(sampler_MaterializeGradient);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
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
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
        {
            Out = A >= B ? 1 : 0;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
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
            float _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.75, _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float);
            float3 _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, (_Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float.xxx), _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3);
            float _Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float = _DisplacementNoiseScale;
            float _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float;
            Unity_Multiply_float_float(_Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float, 32, _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float);
            float _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3.xy), _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float, _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float);
            float _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float = _DisplacementMultiplier;
            float _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float, _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float, _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float);
            float3 _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float.xxx), _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3);
            float3 _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3, _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3);
            description.Position = _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
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
            float _Property_a3bac5175b994837b4f5281412593963_Out_0_Float = _Materialize;
            float _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean;
            Unity_Comparison_GreaterOrEqual_float(_Property_a3bac5175b994837b4f5281412593963_Out_0_Float, float(1), _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean);
            float _Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float = float(1);
            UnityTexture2D _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializeGradient);
            float4 _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.tex, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.samplerstate, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_R_4_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.r;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_G_5_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.g;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_B_6_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.b;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_A_7_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.a;
            float _Float_af319994f61d4f36869407adddc4ca24_Out_0_Float = float(6);
            float4 _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4, (_Float_af319994f61d4f36869407adddc4ca24_Out_0_Float.xxxx), _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4);
            UnityTexture2D _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializePattern);
            float2 _Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2 = _MaterializePatternSpeed;
            float2 _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2);
            float2 _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2 = _MaterializePatternOffset;
            float2 _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2;
            Unity_Add_float2(_Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2, _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2, _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2);
            float2 _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2, _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2);
            float4 _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.tex, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.samplerstate, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2) );
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_R_4_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.r;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_G_5_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.g;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_B_6_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.b;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_A_7_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.a;
            float _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float = _MaterializeProgressFuzzyness;
            float _Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float = _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float;
            float4 _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4, (_Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float.xxxx), _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4);
            float4 _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4;
            Unity_Remap_float4(_Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4, float2 (0, 1), float2 (0, 1), _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4);
            float _Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float = _Materialize;
            float _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float;
            Unity_Remap_float(_Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float, float2 (0.5, 4), float2 (-0.48, -4), _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float);
            float2 _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2 = float2(_Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float, float(6.8));
            float _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float;
            Unity_Remap_float(_Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float, float2 (0, 1), _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2, _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float);
            float4 _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4;
            Unity_Add_float4(_Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4, (_Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float.xxxx), _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4);
            float4 _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4;
            Unity_Step_float4(_Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4, _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4, _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4);
            float4 _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, (_Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float.xxxx), _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4, _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4);
            surface.Alpha = (_Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4).x;
            surface.AlphaClipThreshold = float(0.5);
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
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask R
        
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
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define _ALPHATEST_ON 1
        
        
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
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
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
        float4 _Texture_TexelSize;
        float2 _MaterializePatternSpeed;
        float _Materialize;
        float _MaterializeEdgeThickness;
        float4 _MaterializeEdgeColor;
        float _DisplacementMultiplier;
        float2 _MaterializePatternOffset;
        float4 _MaterializePattern_TexelSize;
        float _DisplacementNoiseScale;
        float _UseMetalicSmoothnessTexture;
        float4 _MetalicSmoothnessTexture_TexelSize;
        float _Smoothness;
        float _UseAmbientOcclusionTexture;
        float4 _AmbientOcclusionTexture_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MaterializeOverlay_TexelSize;
        float4 _MaterializeOverlayColor;
        float _UseEmissionMap;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionMapColor;
        float _MaterializeOverlayAnimationMultiplier;
        float4 _MaterializeGradient_TexelSize;
        float _MaterializeProgressFuzzyness;
        float _MaterializeOverlayAdditive;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);
        TEXTURE2D(_MaterializePattern);
        SAMPLER(sampler_MaterializePattern);
        TEXTURE2D(_MetalicSmoothnessTexture);
        SAMPLER(sampler_MetalicSmoothnessTexture);
        TEXTURE2D(_AmbientOcclusionTexture);
        SAMPLER(sampler_AmbientOcclusionTexture);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MaterializeOverlay);
        SAMPLER(sampler_MaterializeOverlay);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_MaterializeGradient);
        SAMPLER(sampler_MaterializeGradient);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
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
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
        {
            Out = A >= B ? 1 : 0;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
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
            float _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.75, _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float);
            float3 _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, (_Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float.xxx), _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3);
            float _Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float = _DisplacementNoiseScale;
            float _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float;
            Unity_Multiply_float_float(_Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float, 32, _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float);
            float _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3.xy), _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float, _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float);
            float _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float = _DisplacementMultiplier;
            float _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float, _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float, _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float);
            float3 _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float.xxx), _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3);
            float3 _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3, _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3);
            description.Position = _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
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
            float _Property_a3bac5175b994837b4f5281412593963_Out_0_Float = _Materialize;
            float _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean;
            Unity_Comparison_GreaterOrEqual_float(_Property_a3bac5175b994837b4f5281412593963_Out_0_Float, float(1), _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean);
            float _Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float = float(1);
            UnityTexture2D _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializeGradient);
            float4 _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.tex, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.samplerstate, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_R_4_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.r;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_G_5_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.g;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_B_6_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.b;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_A_7_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.a;
            float _Float_af319994f61d4f36869407adddc4ca24_Out_0_Float = float(6);
            float4 _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4, (_Float_af319994f61d4f36869407adddc4ca24_Out_0_Float.xxxx), _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4);
            UnityTexture2D _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializePattern);
            float2 _Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2 = _MaterializePatternSpeed;
            float2 _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2);
            float2 _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2 = _MaterializePatternOffset;
            float2 _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2;
            Unity_Add_float2(_Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2, _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2, _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2);
            float2 _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2, _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2);
            float4 _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.tex, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.samplerstate, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2) );
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_R_4_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.r;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_G_5_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.g;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_B_6_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.b;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_A_7_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.a;
            float _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float = _MaterializeProgressFuzzyness;
            float _Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float = _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float;
            float4 _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4, (_Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float.xxxx), _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4);
            float4 _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4;
            Unity_Remap_float4(_Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4, float2 (0, 1), float2 (0, 1), _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4);
            float _Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float = _Materialize;
            float _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float;
            Unity_Remap_float(_Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float, float2 (0.5, 4), float2 (-0.48, -4), _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float);
            float2 _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2 = float2(_Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float, float(6.8));
            float _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float;
            Unity_Remap_float(_Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float, float2 (0, 1), _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2, _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float);
            float4 _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4;
            Unity_Add_float4(_Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4, (_Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float.xxxx), _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4);
            float4 _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4;
            Unity_Step_float4(_Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4, _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4, _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4);
            float4 _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, (_Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float.xxxx), _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4, _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4);
            surface.Alpha = (_Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4).x;
            surface.AlphaClipThreshold = float(0.5);
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
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
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
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        
        
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
             float3 TangentSpaceNormal;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
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
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
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
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
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
        float4 _Texture_TexelSize;
        float2 _MaterializePatternSpeed;
        float _Materialize;
        float _MaterializeEdgeThickness;
        float4 _MaterializeEdgeColor;
        float _DisplacementMultiplier;
        float2 _MaterializePatternOffset;
        float4 _MaterializePattern_TexelSize;
        float _DisplacementNoiseScale;
        float _UseMetalicSmoothnessTexture;
        float4 _MetalicSmoothnessTexture_TexelSize;
        float _Smoothness;
        float _UseAmbientOcclusionTexture;
        float4 _AmbientOcclusionTexture_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MaterializeOverlay_TexelSize;
        float4 _MaterializeOverlayColor;
        float _UseEmissionMap;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionMapColor;
        float _MaterializeOverlayAnimationMultiplier;
        float4 _MaterializeGradient_TexelSize;
        float _MaterializeProgressFuzzyness;
        float _MaterializeOverlayAdditive;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);
        TEXTURE2D(_MaterializePattern);
        SAMPLER(sampler_MaterializePattern);
        TEXTURE2D(_MetalicSmoothnessTexture);
        SAMPLER(sampler_MetalicSmoothnessTexture);
        TEXTURE2D(_AmbientOcclusionTexture);
        SAMPLER(sampler_AmbientOcclusionTexture);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MaterializeOverlay);
        SAMPLER(sampler_MaterializeOverlay);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_MaterializeGradient);
        SAMPLER(sampler_MaterializeGradient);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
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
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
        {
            Out = A >= B ? 1 : 0;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
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
            float _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.75, _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float);
            float3 _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, (_Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float.xxx), _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3);
            float _Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float = _DisplacementNoiseScale;
            float _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float;
            Unity_Multiply_float_float(_Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float, 32, _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float);
            float _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3.xy), _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float, _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float);
            float _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float = _DisplacementMultiplier;
            float _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float, _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float, _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float);
            float3 _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float.xxx), _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3);
            float3 _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3, _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3);
            description.Position = _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
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
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_db30d1efcb70412f865c031ae7bed0f4_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
            float4 _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_db30d1efcb70412f865c031ae7bed0f4_Out_0_Texture2D.tex, _Property_db30d1efcb70412f865c031ae7bed0f4_Out_0_Texture2D.samplerstate, _Property_db30d1efcb70412f865c031ae7bed0f4_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4);
            float _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_R_4_Float = _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.r;
            float _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_G_5_Float = _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.g;
            float _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_B_6_Float = _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.b;
            float _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_A_7_Float = _SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.a;
            float _Property_a3bac5175b994837b4f5281412593963_Out_0_Float = _Materialize;
            float _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean;
            Unity_Comparison_GreaterOrEqual_float(_Property_a3bac5175b994837b4f5281412593963_Out_0_Float, float(1), _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean);
            float _Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float = float(1);
            UnityTexture2D _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializeGradient);
            float4 _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.tex, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.samplerstate, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_R_4_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.r;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_G_5_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.g;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_B_6_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.b;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_A_7_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.a;
            float _Float_af319994f61d4f36869407adddc4ca24_Out_0_Float = float(6);
            float4 _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4, (_Float_af319994f61d4f36869407adddc4ca24_Out_0_Float.xxxx), _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4);
            UnityTexture2D _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializePattern);
            float2 _Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2 = _MaterializePatternSpeed;
            float2 _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2);
            float2 _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2 = _MaterializePatternOffset;
            float2 _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2;
            Unity_Add_float2(_Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2, _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2, _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2);
            float2 _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2, _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2);
            float4 _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.tex, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.samplerstate, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2) );
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_R_4_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.r;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_G_5_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.g;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_B_6_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.b;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_A_7_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.a;
            float _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float = _MaterializeProgressFuzzyness;
            float _Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float = _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float;
            float4 _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4, (_Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float.xxxx), _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4);
            float4 _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4;
            Unity_Remap_float4(_Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4, float2 (0, 1), float2 (0, 1), _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4);
            float _Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float = _Materialize;
            float _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float;
            Unity_Remap_float(_Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float, float2 (0.5, 4), float2 (-0.48, -4), _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float);
            float2 _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2 = float2(_Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float, float(6.8));
            float _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float;
            Unity_Remap_float(_Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float, float2 (0, 1), _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2, _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float);
            float4 _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4;
            Unity_Add_float4(_Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4, (_Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float.xxxx), _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4);
            float4 _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4;
            Unity_Step_float4(_Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4, _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4, _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4);
            float4 _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, (_Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float.xxxx), _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4, _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4);
            surface.NormalTS = (_SampleTexture2D_bb66f6d226764e7fb5d5bbfe4027befa_RGBA_0_Vector4.xyz);
            surface.Alpha = (_Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4).x;
            surface.AlphaClipThreshold = float(0.5);
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
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
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
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
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
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        
        
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
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
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
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
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
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
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
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
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
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
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
        float4 _Texture_TexelSize;
        float2 _MaterializePatternSpeed;
        float _Materialize;
        float _MaterializeEdgeThickness;
        float4 _MaterializeEdgeColor;
        float _DisplacementMultiplier;
        float2 _MaterializePatternOffset;
        float4 _MaterializePattern_TexelSize;
        float _DisplacementNoiseScale;
        float _UseMetalicSmoothnessTexture;
        float4 _MetalicSmoothnessTexture_TexelSize;
        float _Smoothness;
        float _UseAmbientOcclusionTexture;
        float4 _AmbientOcclusionTexture_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MaterializeOverlay_TexelSize;
        float4 _MaterializeOverlayColor;
        float _UseEmissionMap;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionMapColor;
        float _MaterializeOverlayAnimationMultiplier;
        float4 _MaterializeGradient_TexelSize;
        float _MaterializeProgressFuzzyness;
        float _MaterializeOverlayAdditive;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);
        TEXTURE2D(_MaterializePattern);
        SAMPLER(sampler_MaterializePattern);
        TEXTURE2D(_MetalicSmoothnessTexture);
        SAMPLER(sampler_MetalicSmoothnessTexture);
        TEXTURE2D(_AmbientOcclusionTexture);
        SAMPLER(sampler_AmbientOcclusionTexture);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MaterializeOverlay);
        SAMPLER(sampler_MaterializeOverlay);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_MaterializeGradient);
        SAMPLER(sampler_MaterializeGradient);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
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
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
        {
            Out = A >= B ? 1 : 0;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_InvertColors_float(float In, float InvertColors, out float Out)
        {
            Out = abs(InvertColors - In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
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
            float _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.75, _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float);
            float3 _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, (_Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float.xxx), _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3);
            float _Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float = _DisplacementNoiseScale;
            float _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float;
            Unity_Multiply_float_float(_Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float, 32, _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float);
            float _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3.xy), _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float, _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float);
            float _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float = _DisplacementMultiplier;
            float _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float, _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float, _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float);
            float3 _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float.xxx), _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3);
            float3 _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3, _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3);
            description.Position = _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
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
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_a3bac5175b994837b4f5281412593963_Out_0_Float = _Materialize;
            float _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean;
            Unity_Comparison_GreaterOrEqual_float(_Property_a3bac5175b994837b4f5281412593963_Out_0_Float, float(1), _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean);
            UnityTexture2D _Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Texture);
            float4 _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D.tex, _Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D.samplerstate, _Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_R_4_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.r;
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_G_5_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.g;
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_B_6_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.b;
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_A_7_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.a;
            float _Property_0ea60c8d6e2544f683a3e4b047f23b1e_Out_0_Boolean = _MaterializeOverlayAdditive;
            float _Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float = _Materialize;
            float _Remap_90912e15fc1e4921a98627b2ed8d3d64_Out_3_Float;
            Unity_Remap_float(_Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float, float2 (0, 1), float2 (1, 0), _Remap_90912e15fc1e4921a98627b2ed8d3d64_Out_3_Float);
            UnityTexture2D _Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializeOverlay);
            float _Property_494983ed5fe14b8abeb57c66e6821b33_Out_0_Float = _MaterializeOverlayAnimationMultiplier;
            float _Multiply_81e791815eb847d59e6e5c437a14b2d5_Out_2_Float;
            Unity_Multiply_float_float(_Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float, _Property_494983ed5fe14b8abeb57c66e6821b33_Out_0_Float, _Multiply_81e791815eb847d59e6e5c437a14b2d5_Out_2_Float);
            float2 _TilingAndOffset_1444b6a7b7184ce08d3aab27f20fc48d_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_81e791815eb847d59e6e5c437a14b2d5_Out_2_Float.xx), _TilingAndOffset_1444b6a7b7184ce08d3aab27f20fc48d_Out_3_Vector2);
            float4 _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D.tex, _Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D.samplerstate, _Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_1444b6a7b7184ce08d3aab27f20fc48d_Out_3_Vector2) );
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_R_4_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.r;
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_G_5_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.g;
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_B_6_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.b;
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_A_7_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.a;
            float4 _Property_15126782a7ba443990248009a1350bb3_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_MaterializeOverlayColor) : _MaterializeOverlayColor;
            float4 _Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4, _Property_15126782a7ba443990248009a1350bb3_Out_0_Vector4, _Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4);
            float4 _Multiply_bccb3756950e40119be06b905e5b6405_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Remap_90912e15fc1e4921a98627b2ed8d3d64_Out_3_Float.xxxx), _Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4, _Multiply_bccb3756950e40119be06b905e5b6405_Out_2_Vector4);
            float4 _Add_f22b18e43a5946c0a31b1f37817ea4ca_Out_2_Vector4;
            Unity_Add_float4(_Multiply_bccb3756950e40119be06b905e5b6405_Out_2_Vector4, _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4, _Add_f22b18e43a5946c0a31b1f37817ea4ca_Out_2_Vector4);
            float _Remap_39a1707f02764a938d7a98d944dcc82e_Out_3_Float;
            Unity_Remap_float(_Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float, float2 (0, 1), float2 (1, 0), _Remap_39a1707f02764a938d7a98d944dcc82e_Out_3_Float);
            float _Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float;
            Unity_Step_float(_Remap_39a1707f02764a938d7a98d944dcc82e_Out_3_Float, _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_A_7_Float, _Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float);
            float4 _Multiply_f43602d028a9492db199f4800ee15fce_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4, (_Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float.xxxx), _Multiply_f43602d028a9492db199f4800ee15fce_Out_2_Vector4);
            float _InvertColors_d91e267a2530448fa9881a3f58cec2e0_Out_1_Float;
            float _InvertColors_d91e267a2530448fa9881a3f58cec2e0_InvertColors = float (1);
            Unity_InvertColors_float(_Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float, _InvertColors_d91e267a2530448fa9881a3f58cec2e0_InvertColors, _InvertColors_d91e267a2530448fa9881a3f58cec2e0_Out_1_Float);
            float4 _Multiply_675b556841c242bb9bab88c13d87487e_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4, (_InvertColors_d91e267a2530448fa9881a3f58cec2e0_Out_1_Float.xxxx), _Multiply_675b556841c242bb9bab88c13d87487e_Out_2_Vector4);
            float4 _Add_a1ca4ae8ae6145059dcefc82c48a6da7_Out_2_Vector4;
            Unity_Add_float4(_Multiply_f43602d028a9492db199f4800ee15fce_Out_2_Vector4, _Multiply_675b556841c242bb9bab88c13d87487e_Out_2_Vector4, _Add_a1ca4ae8ae6145059dcefc82c48a6da7_Out_2_Vector4);
            float4 _Branch_7e5d2836057a4df2b983f61f22e19cfb_Out_3_Vector4;
            Unity_Branch_float4(_Property_0ea60c8d6e2544f683a3e4b047f23b1e_Out_0_Boolean, _Add_f22b18e43a5946c0a31b1f37817ea4ca_Out_2_Vector4, _Add_a1ca4ae8ae6145059dcefc82c48a6da7_Out_2_Vector4, _Branch_7e5d2836057a4df2b983f61f22e19cfb_Out_3_Vector4);
            float4 _Branch_a179767cdc8b44d2bc38d371f2ed7141_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4, _Branch_7e5d2836057a4df2b983f61f22e19cfb_Out_3_Vector4, _Branch_a179767cdc8b44d2bc38d371f2ed7141_Out_3_Vector4);
            float _Property_518fc3a8c5d042f29158fcb31d21e33b_Out_0_Boolean = _UseEmissionMap;
            UnityTexture2D _Property_db69d72a62b54c16847eb5f0fd37b574_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_db69d72a62b54c16847eb5f0fd37b574_Out_0_Texture2D.tex, _Property_db69d72a62b54c16847eb5f0fd37b574_Out_0_Texture2D.samplerstate, _Property_db69d72a62b54c16847eb5f0fd37b574_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_R_4_Float = _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4.r;
            float _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_G_5_Float = _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4.g;
            float _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_B_6_Float = _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4.b;
            float _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_A_7_Float = _SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4.a;
            float4 _Property_1e14290db73848bba9a45e6e61b7c0b0_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EmissionMapColor) : _EmissionMapColor;
            float4 _Multiply_63b205abc9904d618f247127a58a76a9_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_122a290984c34e02a1140b079d4faa8c_RGBA_0_Vector4, _Property_1e14290db73848bba9a45e6e61b7c0b0_Out_0_Vector4, _Multiply_63b205abc9904d618f247127a58a76a9_Out_2_Vector4);
            float4 _Branch_c1d25148e2f64c1e9264c83e33ba98bb_Out_3_Vector4;
            Unity_Branch_float4(_Property_518fc3a8c5d042f29158fcb31d21e33b_Out_0_Boolean, _Multiply_63b205abc9904d618f247127a58a76a9_Out_2_Vector4, float4(0, 0, 0, 0), _Branch_c1d25148e2f64c1e9264c83e33ba98bb_Out_3_Vector4);
            UnityTexture2D _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializePattern);
            float2 _Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2 = _MaterializePatternSpeed;
            float2 _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2);
            float2 _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2 = _MaterializePatternOffset;
            float2 _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2;
            Unity_Add_float2(_Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2, _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2, _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2);
            float2 _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2, _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2);
            float4 _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.tex, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.samplerstate, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2) );
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_R_4_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.r;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_G_5_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.g;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_B_6_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.b;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_A_7_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.a;
            float _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float = _MaterializeProgressFuzzyness;
            float _Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float = _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float;
            float4 _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4, (_Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float.xxxx), _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4);
            float4 _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4;
            Unity_Remap_float4(_Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4, float2 (0, 1), float2 (0, 1), _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4);
            float _Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float = _Materialize;
            float _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float;
            Unity_Remap_float(_Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float, float2 (0.5, 4), float2 (-0.48, -4), _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float);
            float2 _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2 = float2(_Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float, float(6.8));
            float _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float;
            Unity_Remap_float(_Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float, float2 (0, 1), _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2, _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float);
            float4 _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4;
            Unity_Add_float4(_Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4, (_Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float.xxxx), _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4);
            UnityTexture2D _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializeGradient);
            float4 _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.tex, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.samplerstate, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_R_4_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.r;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_G_5_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.g;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_B_6_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.b;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_A_7_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.a;
            float _Float_af319994f61d4f36869407adddc4ca24_Out_0_Float = float(6);
            float4 _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4, (_Float_af319994f61d4f36869407adddc4ca24_Out_0_Float.xxxx), _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4);
            float _Property_62462ec80ca54d32801e27ab56457cb5_Out_0_Float = _MaterializeEdgeThickness;
            float4 _Add_cf79ed208d7e4f4597a05f2029693461_Out_2_Vector4;
            Unity_Add_float4(_Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4, (_Property_62462ec80ca54d32801e27ab56457cb5_Out_0_Float.xxxx), _Add_cf79ed208d7e4f4597a05f2029693461_Out_2_Vector4);
            float4 _Step_4e96a5da98ca40e682327543e9f2012a_Out_2_Vector4;
            Unity_Step_float4(_Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4, _Add_cf79ed208d7e4f4597a05f2029693461_Out_2_Vector4, _Step_4e96a5da98ca40e682327543e9f2012a_Out_2_Vector4);
            float4 _Property_fe85e453c9c84c01a99eba30403f5cc0_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_MaterializeEdgeColor) : _MaterializeEdgeColor;
            float4 _Multiply_48862d5d23aa4b43ba1efd05ea712c45_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Step_4e96a5da98ca40e682327543e9f2012a_Out_2_Vector4, _Property_fe85e453c9c84c01a99eba30403f5cc0_Out_0_Vector4, _Multiply_48862d5d23aa4b43ba1efd05ea712c45_Out_2_Vector4);
            float4 _Add_16a704880c23416a9576210959a2150a_Out_2_Vector4;
            Unity_Add_float4(_Multiply_48862d5d23aa4b43ba1efd05ea712c45_Out_2_Vector4, _Branch_c1d25148e2f64c1e9264c83e33ba98bb_Out_3_Vector4, _Add_16a704880c23416a9576210959a2150a_Out_2_Vector4);
            float4 _Branch_f48e6cdeedb64594bc3b04777f15cd0a_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, _Branch_c1d25148e2f64c1e9264c83e33ba98bb_Out_3_Vector4, _Add_16a704880c23416a9576210959a2150a_Out_2_Vector4, _Branch_f48e6cdeedb64594bc3b04777f15cd0a_Out_3_Vector4);
            float _Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float = float(1);
            float4 _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4;
            Unity_Step_float4(_Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4, _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4, _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4);
            float4 _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, (_Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float.xxxx), _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4, _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4);
            surface.BaseColor = (_Branch_a179767cdc8b44d2bc38d371f2ed7141_Out_3_Vector4.xyz);
            surface.Emission = (_Branch_f48e6cdeedb64594bc3b04777f15cd0a_Out_3_Vector4.xyz);
            surface.Alpha = (_Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4).x;
            surface.AlphaClipThreshold = float(0.5);
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
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
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
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        
        
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
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
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
        float4 _Texture_TexelSize;
        float2 _MaterializePatternSpeed;
        float _Materialize;
        float _MaterializeEdgeThickness;
        float4 _MaterializeEdgeColor;
        float _DisplacementMultiplier;
        float2 _MaterializePatternOffset;
        float4 _MaterializePattern_TexelSize;
        float _DisplacementNoiseScale;
        float _UseMetalicSmoothnessTexture;
        float4 _MetalicSmoothnessTexture_TexelSize;
        float _Smoothness;
        float _UseAmbientOcclusionTexture;
        float4 _AmbientOcclusionTexture_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MaterializeOverlay_TexelSize;
        float4 _MaterializeOverlayColor;
        float _UseEmissionMap;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionMapColor;
        float _MaterializeOverlayAnimationMultiplier;
        float4 _MaterializeGradient_TexelSize;
        float _MaterializeProgressFuzzyness;
        float _MaterializeOverlayAdditive;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);
        TEXTURE2D(_MaterializePattern);
        SAMPLER(sampler_MaterializePattern);
        TEXTURE2D(_MetalicSmoothnessTexture);
        SAMPLER(sampler_MetalicSmoothnessTexture);
        TEXTURE2D(_AmbientOcclusionTexture);
        SAMPLER(sampler_AmbientOcclusionTexture);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MaterializeOverlay);
        SAMPLER(sampler_MaterializeOverlay);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_MaterializeGradient);
        SAMPLER(sampler_MaterializeGradient);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
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
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
        {
            Out = A >= B ? 1 : 0;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
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
            float _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.75, _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float);
            float3 _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, (_Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float.xxx), _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3);
            float _Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float = _DisplacementNoiseScale;
            float _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float;
            Unity_Multiply_float_float(_Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float, 32, _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float);
            float _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3.xy), _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float, _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float);
            float _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float = _DisplacementMultiplier;
            float _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float, _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float, _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float);
            float3 _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float.xxx), _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3);
            float3 _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3, _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3);
            description.Position = _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
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
            float _Property_a3bac5175b994837b4f5281412593963_Out_0_Float = _Materialize;
            float _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean;
            Unity_Comparison_GreaterOrEqual_float(_Property_a3bac5175b994837b4f5281412593963_Out_0_Float, float(1), _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean);
            float _Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float = float(1);
            UnityTexture2D _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializeGradient);
            float4 _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.tex, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.samplerstate, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_R_4_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.r;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_G_5_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.g;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_B_6_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.b;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_A_7_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.a;
            float _Float_af319994f61d4f36869407adddc4ca24_Out_0_Float = float(6);
            float4 _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4, (_Float_af319994f61d4f36869407adddc4ca24_Out_0_Float.xxxx), _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4);
            UnityTexture2D _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializePattern);
            float2 _Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2 = _MaterializePatternSpeed;
            float2 _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2);
            float2 _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2 = _MaterializePatternOffset;
            float2 _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2;
            Unity_Add_float2(_Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2, _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2, _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2);
            float2 _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2, _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2);
            float4 _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.tex, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.samplerstate, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2) );
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_R_4_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.r;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_G_5_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.g;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_B_6_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.b;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_A_7_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.a;
            float _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float = _MaterializeProgressFuzzyness;
            float _Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float = _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float;
            float4 _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4, (_Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float.xxxx), _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4);
            float4 _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4;
            Unity_Remap_float4(_Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4, float2 (0, 1), float2 (0, 1), _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4);
            float _Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float = _Materialize;
            float _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float;
            Unity_Remap_float(_Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float, float2 (0.5, 4), float2 (-0.48, -4), _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float);
            float2 _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2 = float2(_Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float, float(6.8));
            float _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float;
            Unity_Remap_float(_Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float, float2 (0, 1), _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2, _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float);
            float4 _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4;
            Unity_Add_float4(_Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4, (_Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float.xxxx), _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4);
            float4 _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4;
            Unity_Step_float4(_Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4, _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4, _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4);
            float4 _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, (_Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float.xxxx), _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4, _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4);
            surface.Alpha = (_Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4).x;
            surface.AlphaClipThreshold = float(0.5);
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
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        
        
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
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
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
        float4 _Texture_TexelSize;
        float2 _MaterializePatternSpeed;
        float _Materialize;
        float _MaterializeEdgeThickness;
        float4 _MaterializeEdgeColor;
        float _DisplacementMultiplier;
        float2 _MaterializePatternOffset;
        float4 _MaterializePattern_TexelSize;
        float _DisplacementNoiseScale;
        float _UseMetalicSmoothnessTexture;
        float4 _MetalicSmoothnessTexture_TexelSize;
        float _Smoothness;
        float _UseAmbientOcclusionTexture;
        float4 _AmbientOcclusionTexture_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MaterializeOverlay_TexelSize;
        float4 _MaterializeOverlayColor;
        float _UseEmissionMap;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionMapColor;
        float _MaterializeOverlayAnimationMultiplier;
        float4 _MaterializeGradient_TexelSize;
        float _MaterializeProgressFuzzyness;
        float _MaterializeOverlayAdditive;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);
        TEXTURE2D(_MaterializePattern);
        SAMPLER(sampler_MaterializePattern);
        TEXTURE2D(_MetalicSmoothnessTexture);
        SAMPLER(sampler_MetalicSmoothnessTexture);
        TEXTURE2D(_AmbientOcclusionTexture);
        SAMPLER(sampler_AmbientOcclusionTexture);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MaterializeOverlay);
        SAMPLER(sampler_MaterializeOverlay);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_MaterializeGradient);
        SAMPLER(sampler_MaterializeGradient);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
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
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
        {
            Out = A >= B ? 1 : 0;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
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
            float _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.75, _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float);
            float3 _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, (_Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float.xxx), _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3);
            float _Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float = _DisplacementNoiseScale;
            float _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float;
            Unity_Multiply_float_float(_Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float, 32, _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float);
            float _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3.xy), _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float, _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float);
            float _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float = _DisplacementMultiplier;
            float _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float, _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float, _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float);
            float3 _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float.xxx), _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3);
            float3 _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3, _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3);
            description.Position = _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
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
            float _Property_a3bac5175b994837b4f5281412593963_Out_0_Float = _Materialize;
            float _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean;
            Unity_Comparison_GreaterOrEqual_float(_Property_a3bac5175b994837b4f5281412593963_Out_0_Float, float(1), _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean);
            float _Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float = float(1);
            UnityTexture2D _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializeGradient);
            float4 _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.tex, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.samplerstate, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_R_4_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.r;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_G_5_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.g;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_B_6_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.b;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_A_7_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.a;
            float _Float_af319994f61d4f36869407adddc4ca24_Out_0_Float = float(6);
            float4 _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4, (_Float_af319994f61d4f36869407adddc4ca24_Out_0_Float.xxxx), _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4);
            UnityTexture2D _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializePattern);
            float2 _Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2 = _MaterializePatternSpeed;
            float2 _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2);
            float2 _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2 = _MaterializePatternOffset;
            float2 _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2;
            Unity_Add_float2(_Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2, _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2, _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2);
            float2 _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2, _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2);
            float4 _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.tex, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.samplerstate, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2) );
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_R_4_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.r;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_G_5_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.g;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_B_6_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.b;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_A_7_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.a;
            float _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float = _MaterializeProgressFuzzyness;
            float _Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float = _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float;
            float4 _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4, (_Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float.xxxx), _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4);
            float4 _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4;
            Unity_Remap_float4(_Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4, float2 (0, 1), float2 (0, 1), _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4);
            float _Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float = _Materialize;
            float _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float;
            Unity_Remap_float(_Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float, float2 (0.5, 4), float2 (-0.48, -4), _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float);
            float2 _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2 = float2(_Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float, float(6.8));
            float _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float;
            Unity_Remap_float(_Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float, float2 (0, 1), _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2, _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float);
            float4 _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4;
            Unity_Add_float4(_Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4, (_Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float.xxxx), _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4);
            float4 _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4;
            Unity_Step_float4(_Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4, _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4, _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4);
            float4 _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, (_Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float.xxxx), _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4, _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4);
            surface.Alpha = (_Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4).x;
            surface.AlphaClipThreshold = float(0.5);
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
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
            Name "Universal 2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
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
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        
        
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
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
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
        float4 _Texture_TexelSize;
        float2 _MaterializePatternSpeed;
        float _Materialize;
        float _MaterializeEdgeThickness;
        float4 _MaterializeEdgeColor;
        float _DisplacementMultiplier;
        float2 _MaterializePatternOffset;
        float4 _MaterializePattern_TexelSize;
        float _DisplacementNoiseScale;
        float _UseMetalicSmoothnessTexture;
        float4 _MetalicSmoothnessTexture_TexelSize;
        float _Smoothness;
        float _UseAmbientOcclusionTexture;
        float4 _AmbientOcclusionTexture_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MaterializeOverlay_TexelSize;
        float4 _MaterializeOverlayColor;
        float _UseEmissionMap;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionMapColor;
        float _MaterializeOverlayAnimationMultiplier;
        float4 _MaterializeGradient_TexelSize;
        float _MaterializeProgressFuzzyness;
        float _MaterializeOverlayAdditive;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Texture);
        SAMPLER(sampler_Texture);
        TEXTURE2D(_MaterializePattern);
        SAMPLER(sampler_MaterializePattern);
        TEXTURE2D(_MetalicSmoothnessTexture);
        SAMPLER(sampler_MetalicSmoothnessTexture);
        TEXTURE2D(_AmbientOcclusionTexture);
        SAMPLER(sampler_AmbientOcclusionTexture);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MaterializeOverlay);
        SAMPLER(sampler_MaterializeOverlay);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_MaterializeGradient);
        SAMPLER(sampler_MaterializeGradient);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
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
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        float Unity_SimpleNoise_ValueNoise_LegacySine_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0; Hash_LegacySine_2_1_float(c0, r0);
            float r1; Hash_LegacySine_2_1_float(c1, r1);
            float r2; Hash_LegacySine_2_1_float(c2, r2);
            float r3; Hash_LegacySine_2_1_float(c3, r3);
            float bottomOfGrid = lerp(r0, r1, f.x);
            float topOfGrid = lerp(r2, r3, f.x);
            float t = lerp(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        
        void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
        {
            float freq, amp;
            Out = 0.0f;
            freq = pow(2.0, float(0));
            amp = pow(0.5, float(3-0));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy*(Scale/freq)))*amp;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Comparison_GreaterOrEqual_float(float A, float B, out float Out)
        {
            Out = A >= B ? 1 : 0;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_InvertColors_float(float In, float InvertColors, out float Out)
        {
            Out = abs(InvertColors - In);
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
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
            float _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float;
            Unity_Multiply_float_float(IN.TimeParameters.x, 0.75, _Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float);
            float3 _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, (_Multiply_0a3264c42bd74a849cb53ba063d18d2d_Out_2_Float.xxx), _Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3);
            float _Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float = _DisplacementNoiseScale;
            float _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float;
            Unity_Multiply_float_float(_Property_387f8f86f9374f3686d7f97d8024a73b_Out_0_Float, 32, _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float);
            float _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float;
            Unity_SimpleNoise_LegacySine_float((_Add_d9d8bc6cf94240e4a81047fa562462a8_Out_2_Vector3.xy), _Multiply_f936535c21a84d30a76fbafa2390098e_Out_2_Float, _SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float);
            float _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float = _DisplacementMultiplier;
            float _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float;
            Unity_Multiply_float_float(_SimpleNoise_3f9074fcd1a546fca08d5ac6504e8057_Out_2_Float, _Property_b2256d28e187461c909aa3f6fd527587_Out_0_Float, _Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float);
            float3 _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Multiply_ddea9e17a6d24cd99daab0758b3d8913_Out_2_Float.xxx), _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3);
            float3 _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_61ea600647cd40238ff3ad582c149a40_Out_2_Vector3, _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3);
            description.Position = _Add_db2d0ec0989f4e22bb6ff084e06d5933_Out_2_Vector3;
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
            float _Property_a3bac5175b994837b4f5281412593963_Out_0_Float = _Materialize;
            float _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean;
            Unity_Comparison_GreaterOrEqual_float(_Property_a3bac5175b994837b4f5281412593963_Out_0_Float, float(1), _Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean);
            UnityTexture2D _Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Texture);
            float4 _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D.tex, _Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D.samplerstate, _Property_1afefa9fe3db465d9ceda6fbba50e20f_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_R_4_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.r;
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_G_5_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.g;
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_B_6_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.b;
            float _SampleTexture2D_f369f3759b164758a61b434213bde0ce_A_7_Float = _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4.a;
            float _Property_0ea60c8d6e2544f683a3e4b047f23b1e_Out_0_Boolean = _MaterializeOverlayAdditive;
            float _Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float = _Materialize;
            float _Remap_90912e15fc1e4921a98627b2ed8d3d64_Out_3_Float;
            Unity_Remap_float(_Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float, float2 (0, 1), float2 (1, 0), _Remap_90912e15fc1e4921a98627b2ed8d3d64_Out_3_Float);
            UnityTexture2D _Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializeOverlay);
            float _Property_494983ed5fe14b8abeb57c66e6821b33_Out_0_Float = _MaterializeOverlayAnimationMultiplier;
            float _Multiply_81e791815eb847d59e6e5c437a14b2d5_Out_2_Float;
            Unity_Multiply_float_float(_Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float, _Property_494983ed5fe14b8abeb57c66e6821b33_Out_0_Float, _Multiply_81e791815eb847d59e6e5c437a14b2d5_Out_2_Float);
            float2 _TilingAndOffset_1444b6a7b7184ce08d3aab27f20fc48d_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_81e791815eb847d59e6e5c437a14b2d5_Out_2_Float.xx), _TilingAndOffset_1444b6a7b7184ce08d3aab27f20fc48d_Out_3_Vector2);
            float4 _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D.tex, _Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D.samplerstate, _Property_2d1baffa135d40619d4fa056deb92550_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_1444b6a7b7184ce08d3aab27f20fc48d_Out_3_Vector2) );
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_R_4_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.r;
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_G_5_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.g;
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_B_6_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.b;
            float _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_A_7_Float = _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4.a;
            float4 _Property_15126782a7ba443990248009a1350bb3_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_MaterializeOverlayColor) : _MaterializeOverlayColor;
            float4 _Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_802db6706e534c05aaf8626df8f84f73_RGBA_0_Vector4, _Property_15126782a7ba443990248009a1350bb3_Out_0_Vector4, _Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4);
            float4 _Multiply_bccb3756950e40119be06b905e5b6405_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Remap_90912e15fc1e4921a98627b2ed8d3d64_Out_3_Float.xxxx), _Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4, _Multiply_bccb3756950e40119be06b905e5b6405_Out_2_Vector4);
            float4 _Add_f22b18e43a5946c0a31b1f37817ea4ca_Out_2_Vector4;
            Unity_Add_float4(_Multiply_bccb3756950e40119be06b905e5b6405_Out_2_Vector4, _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4, _Add_f22b18e43a5946c0a31b1f37817ea4ca_Out_2_Vector4);
            float _Remap_39a1707f02764a938d7a98d944dcc82e_Out_3_Float;
            Unity_Remap_float(_Property_d70b6e17e32d456d917726e6c4b9d794_Out_0_Float, float2 (0, 1), float2 (1, 0), _Remap_39a1707f02764a938d7a98d944dcc82e_Out_3_Float);
            float _Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float;
            Unity_Step_float(_Remap_39a1707f02764a938d7a98d944dcc82e_Out_3_Float, _SampleTexture2D_802db6706e534c05aaf8626df8f84f73_A_7_Float, _Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float);
            float4 _Multiply_f43602d028a9492db199f4800ee15fce_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4, (_Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float.xxxx), _Multiply_f43602d028a9492db199f4800ee15fce_Out_2_Vector4);
            float _InvertColors_d91e267a2530448fa9881a3f58cec2e0_Out_1_Float;
            float _InvertColors_d91e267a2530448fa9881a3f58cec2e0_InvertColors = float (1);
            Unity_InvertColors_float(_Step_3ad295337e8743f7a9a75416fb8061b8_Out_2_Float, _InvertColors_d91e267a2530448fa9881a3f58cec2e0_InvertColors, _InvertColors_d91e267a2530448fa9881a3f58cec2e0_Out_1_Float);
            float4 _Multiply_675b556841c242bb9bab88c13d87487e_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_0a86858ca97a4c01bcadca3cd79c32ad_Out_2_Vector4, (_InvertColors_d91e267a2530448fa9881a3f58cec2e0_Out_1_Float.xxxx), _Multiply_675b556841c242bb9bab88c13d87487e_Out_2_Vector4);
            float4 _Add_a1ca4ae8ae6145059dcefc82c48a6da7_Out_2_Vector4;
            Unity_Add_float4(_Multiply_f43602d028a9492db199f4800ee15fce_Out_2_Vector4, _Multiply_675b556841c242bb9bab88c13d87487e_Out_2_Vector4, _Add_a1ca4ae8ae6145059dcefc82c48a6da7_Out_2_Vector4);
            float4 _Branch_7e5d2836057a4df2b983f61f22e19cfb_Out_3_Vector4;
            Unity_Branch_float4(_Property_0ea60c8d6e2544f683a3e4b047f23b1e_Out_0_Boolean, _Add_f22b18e43a5946c0a31b1f37817ea4ca_Out_2_Vector4, _Add_a1ca4ae8ae6145059dcefc82c48a6da7_Out_2_Vector4, _Branch_7e5d2836057a4df2b983f61f22e19cfb_Out_3_Vector4);
            float4 _Branch_a179767cdc8b44d2bc38d371f2ed7141_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, _SampleTexture2D_f369f3759b164758a61b434213bde0ce_RGBA_0_Vector4, _Branch_7e5d2836057a4df2b983f61f22e19cfb_Out_3_Vector4, _Branch_a179767cdc8b44d2bc38d371f2ed7141_Out_3_Vector4);
            float _Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float = float(1);
            UnityTexture2D _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializeGradient);
            float4 _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.tex, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.samplerstate, _Property_9e7f22de8660424aaf6b12dabd9684ff_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_R_4_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.r;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_G_5_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.g;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_B_6_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.b;
            float _SampleTexture2D_929441cc7c194036901becc3bf2b947c_A_7_Float = _SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4.a;
            float _Float_af319994f61d4f36869407adddc4ca24_Out_0_Float = float(6);
            float4 _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_929441cc7c194036901becc3bf2b947c_RGBA_0_Vector4, (_Float_af319994f61d4f36869407adddc4ca24_Out_0_Float.xxxx), _Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4);
            UnityTexture2D _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MaterializePattern);
            float2 _Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2 = _MaterializePatternSpeed;
            float2 _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_dfca0ede28b84789bd177954e7e8b50b_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2);
            float2 _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2 = _MaterializePatternOffset;
            float2 _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2;
            Unity_Add_float2(_Multiply_268f0d7889b24dd3a2dcc6b3ca9c64c1_Out_2_Vector2, _Property_d1a1a117c5c146d6a0cd980f10aa257e_Out_0_Vector2, _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2);
            float2 _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Add_fccc12f2072742fdae76079a920e40ad_Out_2_Vector2, _TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2);
            float4 _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.tex, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.samplerstate, _Property_0f40a61ede4e4d66b55ccdd665d3d9f1_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_d63a05b46d6142878508a2437e73e290_Out_3_Vector2) );
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_R_4_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.r;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_G_5_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.g;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_B_6_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.b;
            float _SampleTexture2D_7b425cbee5934ec398227ff3df068614_A_7_Float = _SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4.a;
            float _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float = _MaterializeProgressFuzzyness;
            float _Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float = _Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float;
            float4 _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_7b425cbee5934ec398227ff3df068614_RGBA_0_Vector4, (_Float_8e349fb3e6d24e0097e78b342ddb14c4_Out_0_Float.xxxx), _Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4);
            float4 _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4;
            Unity_Remap_float4(_Multiply_0734e28c06f74f14aa585d51f0c637b5_Out_2_Vector4, float2 (0, 1), float2 (0, 1), _Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4);
            float _Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float = _Materialize;
            float _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float;
            Unity_Remap_float(_Property_fd99a85a425c4e338124e4475d335aa3_Out_0_Float, float2 (0.5, 4), float2 (-0.48, -4), _Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float);
            float2 _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2 = float2(_Remap_86aadc058d66469fba3ef48d75007636_Out_3_Float, float(6.8));
            float _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float;
            Unity_Remap_float(_Property_adbbc8bdc7dd485494737a8942725907_Out_0_Float, float2 (0, 1), _Vector2_41cdb480ffdd43d3bfc9d6764f0f3c9b_Out_0_Vector2, _Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float);
            float4 _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4;
            Unity_Add_float4(_Remap_d78608eae966462f9d2f2d4e8379f323_Out_3_Vector4, (_Remap_7ae1ad2dbdbb4d71be4f6ccd1d239e19_Out_3_Float.xxxx), _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4);
            float4 _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4;
            Unity_Step_float4(_Multiply_95f95bdbe3414482ac5cc9d3b22b9395_Out_2_Vector4, _Add_ab18476892d742d7bef1fb66a71668ef_Out_2_Vector4, _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4);
            float4 _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4;
            Unity_Branch_float4(_Comparison_d809f710cedc45519681304b5f330de4_Out_2_Boolean, (_Float_61aedc5b073b4c7fa73e4d849b5d66ff_Out_0_Float.xxxx), _Step_c322f82defdf4758b13ef655473cd1e7_Out_2_Vector4, _Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4);
            surface.BaseColor = (_Branch_a179767cdc8b44d2bc38d371f2ed7141_Out_3_Vector4.xyz);
            surface.Alpha = (_Branch_7d7aa22d1fcc4a6fbf08a0eaa8f279a1_Out_3_Vector4).x;
            surface.AlphaClipThreshold = float(0.5);
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
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}