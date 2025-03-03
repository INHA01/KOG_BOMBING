Shader "IndieImpulse/Unlit/GlichType2"
{
    Properties
    {
        [NoScaleOffset]_MainTexture("MainTexture", 2D) = "white" {}
        _NoiseScale("NoiseScale", Float) = 200
        _NoiseSpeed("NoiseSpeed", Float) = 1
        _SineScale("SineScale", Float) = 200
        _SineSpeed("SineSpeed", Float) = 2
        [NoScaleOffset]_Mask("Mask", 2D) = "white" {}
        [HDR]_Color("Color", Color) = (0, 0, 0, 0)
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
        float _SineScale;
        float _SineSpeed;
        float4 _MainTexture_TexelSize;
        float _NoiseScale;
        float _NoiseSpeed;
        float4 _Mask_TexelSize;
        float4 _Color;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
        {
             float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
             Out = lerp(Min, Max, randomno);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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
            UnityTexture2D _Property_712f8becc96549708393364882838e40_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Property_081a97c7a7a047c8972e88454611ab72_Out_0 = _NoiseSpeed;
            float _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_081a97c7a7a047c8972e88454611ab72_Out_0, _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2);
            float4 _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0 = IN.uv0;
            float _Split_8752ca323fb546f59bb88575a8aa2451_R_1 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[0];
            float _Split_8752ca323fb546f59bb88575a8aa2451_G_2 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[1];
            float _Split_8752ca323fb546f59bb88575a8aa2451_B_3 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[2];
            float _Split_8752ca323fb546f59bb88575a8aa2451_A_4 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[3];
            float _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2;
            Unity_Add_float(_Multiply_75def10fb0e44c6f937b52556d44eede_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_G_2, _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2);
            float _Property_a21dafd03b564bc1821b192300c6a03d_Out_0 = _NoiseScale;
            float _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2;
            Unity_SimpleNoise_float((_Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2.xx), _Property_a21dafd03b564bc1821b192300c6a03d_Out_0, _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2);
            float _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3;
            Unity_Remap_float(_SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2, float2 (0, 1), float2 (-0.5, 0.5), _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3);
            float _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2;
            Unity_SimpleNoise_float((IN.TimeParameters.x.xx), 200, _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2);
            float _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2;
            Unity_Power_float(_SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2, 2, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2);
            float _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2;
            Unity_Multiply_float_float(_Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2, _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2);
            float _Add_bca220147d64497991700a1caba002e8_Out_2;
            Unity_Add_float(_Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_R_1, _Add_bca220147d64497991700a1caba002e8_Out_2);
            float4 _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0 = SAMPLE_TEXTURE2D(_Property_712f8becc96549708393364882838e40_Out_0.tex, _Property_712f8becc96549708393364882838e40_Out_0.samplerstate, _Property_712f8becc96549708393364882838e40_Out_0.GetTransformedUV((_Add_bca220147d64497991700a1caba002e8_Out_2.xx)));
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_R_4 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.r;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_G_5 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.g;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_B_6 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.b;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_A_7 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.a;
            float4 _Property_317d85fc724f4d6099b72ecea0013cdb_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
            float4 _Multiply_c48a4ad822154db9bca720cd0cd92b3f_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0, _Property_317d85fc724f4d6099b72ecea0013cdb_Out_0, _Multiply_c48a4ad822154db9bca720cd0cd92b3f_Out_2);
            UnityTexture2D _Property_5204891db70249b0a52300a027b0a232_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _RandomRange_836306569ce5434980c448ff62df855d_Out_3;
            Unity_RandomRange_float((IN.TimeParameters.x.xx), 0, 1, _RandomRange_836306569ce5434980c448ff62df855d_Out_3);
            float2 _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_RandomRange_836306569ce5434980c448ff62df855d_Out_3.xx), (_Power_e2a693f75dac463f9f418b87a67a3a52_Out_2.xx), _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3);
            float4 _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5204891db70249b0a52300a027b0a232_Out_0.tex, _Property_5204891db70249b0a52300a027b0a232_Out_0.samplerstate, _Property_5204891db70249b0a52300a027b0a232_Out_0.GetTransformedUV(_TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3));
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_R_4 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.r;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_G_5 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.g;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_B_6 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.b;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_A_7 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.a;
            float4 _Multiply_555c57ef879143edbde63cefe8d08931_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0, _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0, _Multiply_555c57ef879143edbde63cefe8d08931_Out_2);
            surface.BaseColor = (_Multiply_c48a4ad822154db9bca720cd0cd92b3f_Out_2.xyz);
            surface.Alpha = (_Multiply_555c57ef879143edbde63cefe8d08931_Out_2).x;
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
        Cull Back
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
        float _SineScale;
        float _SineSpeed;
        float4 _MainTexture_TexelSize;
        float _NoiseScale;
        float _NoiseSpeed;
        float4 _Mask_TexelSize;
        float4 _Color;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
        {
             float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
             Out = lerp(Min, Max, randomno);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_712f8becc96549708393364882838e40_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Property_081a97c7a7a047c8972e88454611ab72_Out_0 = _NoiseSpeed;
            float _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_081a97c7a7a047c8972e88454611ab72_Out_0, _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2);
            float4 _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0 = IN.uv0;
            float _Split_8752ca323fb546f59bb88575a8aa2451_R_1 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[0];
            float _Split_8752ca323fb546f59bb88575a8aa2451_G_2 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[1];
            float _Split_8752ca323fb546f59bb88575a8aa2451_B_3 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[2];
            float _Split_8752ca323fb546f59bb88575a8aa2451_A_4 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[3];
            float _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2;
            Unity_Add_float(_Multiply_75def10fb0e44c6f937b52556d44eede_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_G_2, _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2);
            float _Property_a21dafd03b564bc1821b192300c6a03d_Out_0 = _NoiseScale;
            float _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2;
            Unity_SimpleNoise_float((_Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2.xx), _Property_a21dafd03b564bc1821b192300c6a03d_Out_0, _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2);
            float _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3;
            Unity_Remap_float(_SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2, float2 (0, 1), float2 (-0.5, 0.5), _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3);
            float _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2;
            Unity_SimpleNoise_float((IN.TimeParameters.x.xx), 200, _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2);
            float _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2;
            Unity_Power_float(_SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2, 2, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2);
            float _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2;
            Unity_Multiply_float_float(_Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2, _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2);
            float _Add_bca220147d64497991700a1caba002e8_Out_2;
            Unity_Add_float(_Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_R_1, _Add_bca220147d64497991700a1caba002e8_Out_2);
            float4 _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0 = SAMPLE_TEXTURE2D(_Property_712f8becc96549708393364882838e40_Out_0.tex, _Property_712f8becc96549708393364882838e40_Out_0.samplerstate, _Property_712f8becc96549708393364882838e40_Out_0.GetTransformedUV((_Add_bca220147d64497991700a1caba002e8_Out_2.xx)));
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_R_4 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.r;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_G_5 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.g;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_B_6 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.b;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_A_7 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.a;
            UnityTexture2D _Property_5204891db70249b0a52300a027b0a232_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _RandomRange_836306569ce5434980c448ff62df855d_Out_3;
            Unity_RandomRange_float((IN.TimeParameters.x.xx), 0, 1, _RandomRange_836306569ce5434980c448ff62df855d_Out_3);
            float2 _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_RandomRange_836306569ce5434980c448ff62df855d_Out_3.xx), (_Power_e2a693f75dac463f9f418b87a67a3a52_Out_2.xx), _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3);
            float4 _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5204891db70249b0a52300a027b0a232_Out_0.tex, _Property_5204891db70249b0a52300a027b0a232_Out_0.samplerstate, _Property_5204891db70249b0a52300a027b0a232_Out_0.GetTransformedUV(_TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3));
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_R_4 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.r;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_G_5 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.g;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_B_6 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.b;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_A_7 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.a;
            float4 _Multiply_555c57ef879143edbde63cefe8d08931_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0, _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0, _Multiply_555c57ef879143edbde63cefe8d08931_Out_2);
            surface.Alpha = (_Multiply_555c57ef879143edbde63cefe8d08931_Out_2).x;
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
        float _SineScale;
        float _SineSpeed;
        float4 _MainTexture_TexelSize;
        float _NoiseScale;
        float _NoiseSpeed;
        float4 _Mask_TexelSize;
        float4 _Color;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
        {
             float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
             Out = lerp(Min, Max, randomno);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_712f8becc96549708393364882838e40_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Property_081a97c7a7a047c8972e88454611ab72_Out_0 = _NoiseSpeed;
            float _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_081a97c7a7a047c8972e88454611ab72_Out_0, _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2);
            float4 _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0 = IN.uv0;
            float _Split_8752ca323fb546f59bb88575a8aa2451_R_1 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[0];
            float _Split_8752ca323fb546f59bb88575a8aa2451_G_2 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[1];
            float _Split_8752ca323fb546f59bb88575a8aa2451_B_3 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[2];
            float _Split_8752ca323fb546f59bb88575a8aa2451_A_4 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[3];
            float _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2;
            Unity_Add_float(_Multiply_75def10fb0e44c6f937b52556d44eede_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_G_2, _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2);
            float _Property_a21dafd03b564bc1821b192300c6a03d_Out_0 = _NoiseScale;
            float _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2;
            Unity_SimpleNoise_float((_Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2.xx), _Property_a21dafd03b564bc1821b192300c6a03d_Out_0, _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2);
            float _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3;
            Unity_Remap_float(_SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2, float2 (0, 1), float2 (-0.5, 0.5), _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3);
            float _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2;
            Unity_SimpleNoise_float((IN.TimeParameters.x.xx), 200, _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2);
            float _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2;
            Unity_Power_float(_SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2, 2, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2);
            float _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2;
            Unity_Multiply_float_float(_Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2, _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2);
            float _Add_bca220147d64497991700a1caba002e8_Out_2;
            Unity_Add_float(_Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_R_1, _Add_bca220147d64497991700a1caba002e8_Out_2);
            float4 _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0 = SAMPLE_TEXTURE2D(_Property_712f8becc96549708393364882838e40_Out_0.tex, _Property_712f8becc96549708393364882838e40_Out_0.samplerstate, _Property_712f8becc96549708393364882838e40_Out_0.GetTransformedUV((_Add_bca220147d64497991700a1caba002e8_Out_2.xx)));
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_R_4 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.r;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_G_5 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.g;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_B_6 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.b;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_A_7 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.a;
            UnityTexture2D _Property_5204891db70249b0a52300a027b0a232_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _RandomRange_836306569ce5434980c448ff62df855d_Out_3;
            Unity_RandomRange_float((IN.TimeParameters.x.xx), 0, 1, _RandomRange_836306569ce5434980c448ff62df855d_Out_3);
            float2 _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_RandomRange_836306569ce5434980c448ff62df855d_Out_3.xx), (_Power_e2a693f75dac463f9f418b87a67a3a52_Out_2.xx), _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3);
            float4 _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5204891db70249b0a52300a027b0a232_Out_0.tex, _Property_5204891db70249b0a52300a027b0a232_Out_0.samplerstate, _Property_5204891db70249b0a52300a027b0a232_Out_0.GetTransformedUV(_TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3));
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_R_4 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.r;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_G_5 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.g;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_B_6 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.b;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_A_7 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.a;
            float4 _Multiply_555c57ef879143edbde63cefe8d08931_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0, _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0, _Multiply_555c57ef879143edbde63cefe8d08931_Out_2);
            surface.Alpha = (_Multiply_555c57ef879143edbde63cefe8d08931_Out_2).x;
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
        float _SineScale;
        float _SineSpeed;
        float4 _MainTexture_TexelSize;
        float _NoiseScale;
        float _NoiseSpeed;
        float4 _Mask_TexelSize;
        float4 _Color;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
        {
             float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
             Out = lerp(Min, Max, randomno);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_712f8becc96549708393364882838e40_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Property_081a97c7a7a047c8972e88454611ab72_Out_0 = _NoiseSpeed;
            float _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_081a97c7a7a047c8972e88454611ab72_Out_0, _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2);
            float4 _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0 = IN.uv0;
            float _Split_8752ca323fb546f59bb88575a8aa2451_R_1 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[0];
            float _Split_8752ca323fb546f59bb88575a8aa2451_G_2 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[1];
            float _Split_8752ca323fb546f59bb88575a8aa2451_B_3 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[2];
            float _Split_8752ca323fb546f59bb88575a8aa2451_A_4 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[3];
            float _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2;
            Unity_Add_float(_Multiply_75def10fb0e44c6f937b52556d44eede_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_G_2, _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2);
            float _Property_a21dafd03b564bc1821b192300c6a03d_Out_0 = _NoiseScale;
            float _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2;
            Unity_SimpleNoise_float((_Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2.xx), _Property_a21dafd03b564bc1821b192300c6a03d_Out_0, _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2);
            float _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3;
            Unity_Remap_float(_SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2, float2 (0, 1), float2 (-0.5, 0.5), _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3);
            float _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2;
            Unity_SimpleNoise_float((IN.TimeParameters.x.xx), 200, _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2);
            float _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2;
            Unity_Power_float(_SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2, 2, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2);
            float _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2;
            Unity_Multiply_float_float(_Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2, _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2);
            float _Add_bca220147d64497991700a1caba002e8_Out_2;
            Unity_Add_float(_Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_R_1, _Add_bca220147d64497991700a1caba002e8_Out_2);
            float4 _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0 = SAMPLE_TEXTURE2D(_Property_712f8becc96549708393364882838e40_Out_0.tex, _Property_712f8becc96549708393364882838e40_Out_0.samplerstate, _Property_712f8becc96549708393364882838e40_Out_0.GetTransformedUV((_Add_bca220147d64497991700a1caba002e8_Out_2.xx)));
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_R_4 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.r;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_G_5 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.g;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_B_6 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.b;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_A_7 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.a;
            UnityTexture2D _Property_5204891db70249b0a52300a027b0a232_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _RandomRange_836306569ce5434980c448ff62df855d_Out_3;
            Unity_RandomRange_float((IN.TimeParameters.x.xx), 0, 1, _RandomRange_836306569ce5434980c448ff62df855d_Out_3);
            float2 _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_RandomRange_836306569ce5434980c448ff62df855d_Out_3.xx), (_Power_e2a693f75dac463f9f418b87a67a3a52_Out_2.xx), _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3);
            float4 _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5204891db70249b0a52300a027b0a232_Out_0.tex, _Property_5204891db70249b0a52300a027b0a232_Out_0.samplerstate, _Property_5204891db70249b0a52300a027b0a232_Out_0.GetTransformedUV(_TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3));
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_R_4 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.r;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_G_5 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.g;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_B_6 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.b;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_A_7 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.a;
            float4 _Multiply_555c57ef879143edbde63cefe8d08931_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0, _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0, _Multiply_555c57ef879143edbde63cefe8d08931_Out_2);
            surface.Alpha = (_Multiply_555c57ef879143edbde63cefe8d08931_Out_2).x;
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
        Cull Back
        
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
        float _SineScale;
        float _SineSpeed;
        float4 _MainTexture_TexelSize;
        float _NoiseScale;
        float _NoiseSpeed;
        float4 _Mask_TexelSize;
        float4 _Color;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
        {
             float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
             Out = lerp(Min, Max, randomno);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_712f8becc96549708393364882838e40_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Property_081a97c7a7a047c8972e88454611ab72_Out_0 = _NoiseSpeed;
            float _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_081a97c7a7a047c8972e88454611ab72_Out_0, _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2);
            float4 _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0 = IN.uv0;
            float _Split_8752ca323fb546f59bb88575a8aa2451_R_1 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[0];
            float _Split_8752ca323fb546f59bb88575a8aa2451_G_2 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[1];
            float _Split_8752ca323fb546f59bb88575a8aa2451_B_3 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[2];
            float _Split_8752ca323fb546f59bb88575a8aa2451_A_4 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[3];
            float _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2;
            Unity_Add_float(_Multiply_75def10fb0e44c6f937b52556d44eede_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_G_2, _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2);
            float _Property_a21dafd03b564bc1821b192300c6a03d_Out_0 = _NoiseScale;
            float _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2;
            Unity_SimpleNoise_float((_Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2.xx), _Property_a21dafd03b564bc1821b192300c6a03d_Out_0, _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2);
            float _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3;
            Unity_Remap_float(_SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2, float2 (0, 1), float2 (-0.5, 0.5), _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3);
            float _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2;
            Unity_SimpleNoise_float((IN.TimeParameters.x.xx), 200, _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2);
            float _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2;
            Unity_Power_float(_SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2, 2, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2);
            float _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2;
            Unity_Multiply_float_float(_Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2, _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2);
            float _Add_bca220147d64497991700a1caba002e8_Out_2;
            Unity_Add_float(_Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_R_1, _Add_bca220147d64497991700a1caba002e8_Out_2);
            float4 _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0 = SAMPLE_TEXTURE2D(_Property_712f8becc96549708393364882838e40_Out_0.tex, _Property_712f8becc96549708393364882838e40_Out_0.samplerstate, _Property_712f8becc96549708393364882838e40_Out_0.GetTransformedUV((_Add_bca220147d64497991700a1caba002e8_Out_2.xx)));
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_R_4 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.r;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_G_5 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.g;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_B_6 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.b;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_A_7 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.a;
            UnityTexture2D _Property_5204891db70249b0a52300a027b0a232_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _RandomRange_836306569ce5434980c448ff62df855d_Out_3;
            Unity_RandomRange_float((IN.TimeParameters.x.xx), 0, 1, _RandomRange_836306569ce5434980c448ff62df855d_Out_3);
            float2 _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_RandomRange_836306569ce5434980c448ff62df855d_Out_3.xx), (_Power_e2a693f75dac463f9f418b87a67a3a52_Out_2.xx), _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3);
            float4 _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5204891db70249b0a52300a027b0a232_Out_0.tex, _Property_5204891db70249b0a52300a027b0a232_Out_0.samplerstate, _Property_5204891db70249b0a52300a027b0a232_Out_0.GetTransformedUV(_TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3));
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_R_4 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.r;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_G_5 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.g;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_B_6 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.b;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_A_7 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.a;
            float4 _Multiply_555c57ef879143edbde63cefe8d08931_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0, _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0, _Multiply_555c57ef879143edbde63cefe8d08931_Out_2);
            surface.Alpha = (_Multiply_555c57ef879143edbde63cefe8d08931_Out_2).x;
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
        Cull Back
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
        float _SineScale;
        float _SineSpeed;
        float4 _MainTexture_TexelSize;
        float _NoiseScale;
        float _NoiseSpeed;
        float4 _Mask_TexelSize;
        float4 _Color;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
        {
             float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
             Out = lerp(Min, Max, randomno);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_712f8becc96549708393364882838e40_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Property_081a97c7a7a047c8972e88454611ab72_Out_0 = _NoiseSpeed;
            float _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_081a97c7a7a047c8972e88454611ab72_Out_0, _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2);
            float4 _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0 = IN.uv0;
            float _Split_8752ca323fb546f59bb88575a8aa2451_R_1 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[0];
            float _Split_8752ca323fb546f59bb88575a8aa2451_G_2 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[1];
            float _Split_8752ca323fb546f59bb88575a8aa2451_B_3 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[2];
            float _Split_8752ca323fb546f59bb88575a8aa2451_A_4 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[3];
            float _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2;
            Unity_Add_float(_Multiply_75def10fb0e44c6f937b52556d44eede_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_G_2, _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2);
            float _Property_a21dafd03b564bc1821b192300c6a03d_Out_0 = _NoiseScale;
            float _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2;
            Unity_SimpleNoise_float((_Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2.xx), _Property_a21dafd03b564bc1821b192300c6a03d_Out_0, _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2);
            float _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3;
            Unity_Remap_float(_SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2, float2 (0, 1), float2 (-0.5, 0.5), _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3);
            float _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2;
            Unity_SimpleNoise_float((IN.TimeParameters.x.xx), 200, _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2);
            float _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2;
            Unity_Power_float(_SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2, 2, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2);
            float _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2;
            Unity_Multiply_float_float(_Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2, _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2);
            float _Add_bca220147d64497991700a1caba002e8_Out_2;
            Unity_Add_float(_Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_R_1, _Add_bca220147d64497991700a1caba002e8_Out_2);
            float4 _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0 = SAMPLE_TEXTURE2D(_Property_712f8becc96549708393364882838e40_Out_0.tex, _Property_712f8becc96549708393364882838e40_Out_0.samplerstate, _Property_712f8becc96549708393364882838e40_Out_0.GetTransformedUV((_Add_bca220147d64497991700a1caba002e8_Out_2.xx)));
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_R_4 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.r;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_G_5 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.g;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_B_6 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.b;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_A_7 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.a;
            UnityTexture2D _Property_5204891db70249b0a52300a027b0a232_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _RandomRange_836306569ce5434980c448ff62df855d_Out_3;
            Unity_RandomRange_float((IN.TimeParameters.x.xx), 0, 1, _RandomRange_836306569ce5434980c448ff62df855d_Out_3);
            float2 _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_RandomRange_836306569ce5434980c448ff62df855d_Out_3.xx), (_Power_e2a693f75dac463f9f418b87a67a3a52_Out_2.xx), _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3);
            float4 _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5204891db70249b0a52300a027b0a232_Out_0.tex, _Property_5204891db70249b0a52300a027b0a232_Out_0.samplerstate, _Property_5204891db70249b0a52300a027b0a232_Out_0.GetTransformedUV(_TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3));
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_R_4 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.r;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_G_5 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.g;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_B_6 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.b;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_A_7 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.a;
            float4 _Multiply_555c57ef879143edbde63cefe8d08931_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0, _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0, _Multiply_555c57ef879143edbde63cefe8d08931_Out_2);
            surface.Alpha = (_Multiply_555c57ef879143edbde63cefe8d08931_Out_2).x;
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
        float _SineScale;
        float _SineSpeed;
        float4 _MainTexture_TexelSize;
        float _NoiseScale;
        float _NoiseSpeed;
        float4 _Mask_TexelSize;
        float4 _Color;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
        {
             float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
             Out = lerp(Min, Max, randomno);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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
            UnityTexture2D _Property_712f8becc96549708393364882838e40_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Property_081a97c7a7a047c8972e88454611ab72_Out_0 = _NoiseSpeed;
            float _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_081a97c7a7a047c8972e88454611ab72_Out_0, _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2);
            float4 _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0 = IN.uv0;
            float _Split_8752ca323fb546f59bb88575a8aa2451_R_1 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[0];
            float _Split_8752ca323fb546f59bb88575a8aa2451_G_2 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[1];
            float _Split_8752ca323fb546f59bb88575a8aa2451_B_3 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[2];
            float _Split_8752ca323fb546f59bb88575a8aa2451_A_4 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[3];
            float _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2;
            Unity_Add_float(_Multiply_75def10fb0e44c6f937b52556d44eede_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_G_2, _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2);
            float _Property_a21dafd03b564bc1821b192300c6a03d_Out_0 = _NoiseScale;
            float _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2;
            Unity_SimpleNoise_float((_Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2.xx), _Property_a21dafd03b564bc1821b192300c6a03d_Out_0, _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2);
            float _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3;
            Unity_Remap_float(_SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2, float2 (0, 1), float2 (-0.5, 0.5), _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3);
            float _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2;
            Unity_SimpleNoise_float((IN.TimeParameters.x.xx), 200, _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2);
            float _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2;
            Unity_Power_float(_SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2, 2, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2);
            float _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2;
            Unity_Multiply_float_float(_Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2, _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2);
            float _Add_bca220147d64497991700a1caba002e8_Out_2;
            Unity_Add_float(_Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_R_1, _Add_bca220147d64497991700a1caba002e8_Out_2);
            float4 _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0 = SAMPLE_TEXTURE2D(_Property_712f8becc96549708393364882838e40_Out_0.tex, _Property_712f8becc96549708393364882838e40_Out_0.samplerstate, _Property_712f8becc96549708393364882838e40_Out_0.GetTransformedUV((_Add_bca220147d64497991700a1caba002e8_Out_2.xx)));
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_R_4 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.r;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_G_5 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.g;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_B_6 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.b;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_A_7 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.a;
            float4 _Property_317d85fc724f4d6099b72ecea0013cdb_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
            float4 _Multiply_c48a4ad822154db9bca720cd0cd92b3f_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0, _Property_317d85fc724f4d6099b72ecea0013cdb_Out_0, _Multiply_c48a4ad822154db9bca720cd0cd92b3f_Out_2);
            UnityTexture2D _Property_5204891db70249b0a52300a027b0a232_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _RandomRange_836306569ce5434980c448ff62df855d_Out_3;
            Unity_RandomRange_float((IN.TimeParameters.x.xx), 0, 1, _RandomRange_836306569ce5434980c448ff62df855d_Out_3);
            float2 _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_RandomRange_836306569ce5434980c448ff62df855d_Out_3.xx), (_Power_e2a693f75dac463f9f418b87a67a3a52_Out_2.xx), _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3);
            float4 _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5204891db70249b0a52300a027b0a232_Out_0.tex, _Property_5204891db70249b0a52300a027b0a232_Out_0.samplerstate, _Property_5204891db70249b0a52300a027b0a232_Out_0.GetTransformedUV(_TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3));
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_R_4 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.r;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_G_5 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.g;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_B_6 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.b;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_A_7 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.a;
            float4 _Multiply_555c57ef879143edbde63cefe8d08931_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0, _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0, _Multiply_555c57ef879143edbde63cefe8d08931_Out_2);
            surface.BaseColor = (_Multiply_c48a4ad822154db9bca720cd0cd92b3f_Out_2.xyz);
            surface.Alpha = (_Multiply_555c57ef879143edbde63cefe8d08931_Out_2).x;
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
        float _SineScale;
        float _SineSpeed;
        float4 _MainTexture_TexelSize;
        float _NoiseScale;
        float _NoiseSpeed;
        float4 _Mask_TexelSize;
        float4 _Color;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
        {
             float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
             Out = lerp(Min, Max, randomno);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_712f8becc96549708393364882838e40_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Property_081a97c7a7a047c8972e88454611ab72_Out_0 = _NoiseSpeed;
            float _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_081a97c7a7a047c8972e88454611ab72_Out_0, _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2);
            float4 _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0 = IN.uv0;
            float _Split_8752ca323fb546f59bb88575a8aa2451_R_1 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[0];
            float _Split_8752ca323fb546f59bb88575a8aa2451_G_2 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[1];
            float _Split_8752ca323fb546f59bb88575a8aa2451_B_3 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[2];
            float _Split_8752ca323fb546f59bb88575a8aa2451_A_4 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[3];
            float _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2;
            Unity_Add_float(_Multiply_75def10fb0e44c6f937b52556d44eede_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_G_2, _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2);
            float _Property_a21dafd03b564bc1821b192300c6a03d_Out_0 = _NoiseScale;
            float _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2;
            Unity_SimpleNoise_float((_Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2.xx), _Property_a21dafd03b564bc1821b192300c6a03d_Out_0, _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2);
            float _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3;
            Unity_Remap_float(_SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2, float2 (0, 1), float2 (-0.5, 0.5), _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3);
            float _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2;
            Unity_SimpleNoise_float((IN.TimeParameters.x.xx), 200, _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2);
            float _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2;
            Unity_Power_float(_SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2, 2, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2);
            float _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2;
            Unity_Multiply_float_float(_Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2, _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2);
            float _Add_bca220147d64497991700a1caba002e8_Out_2;
            Unity_Add_float(_Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_R_1, _Add_bca220147d64497991700a1caba002e8_Out_2);
            float4 _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0 = SAMPLE_TEXTURE2D(_Property_712f8becc96549708393364882838e40_Out_0.tex, _Property_712f8becc96549708393364882838e40_Out_0.samplerstate, _Property_712f8becc96549708393364882838e40_Out_0.GetTransformedUV((_Add_bca220147d64497991700a1caba002e8_Out_2.xx)));
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_R_4 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.r;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_G_5 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.g;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_B_6 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.b;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_A_7 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.a;
            UnityTexture2D _Property_5204891db70249b0a52300a027b0a232_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _RandomRange_836306569ce5434980c448ff62df855d_Out_3;
            Unity_RandomRange_float((IN.TimeParameters.x.xx), 0, 1, _RandomRange_836306569ce5434980c448ff62df855d_Out_3);
            float2 _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_RandomRange_836306569ce5434980c448ff62df855d_Out_3.xx), (_Power_e2a693f75dac463f9f418b87a67a3a52_Out_2.xx), _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3);
            float4 _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5204891db70249b0a52300a027b0a232_Out_0.tex, _Property_5204891db70249b0a52300a027b0a232_Out_0.samplerstate, _Property_5204891db70249b0a52300a027b0a232_Out_0.GetTransformedUV(_TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3));
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_R_4 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.r;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_G_5 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.g;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_B_6 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.b;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_A_7 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.a;
            float4 _Multiply_555c57ef879143edbde63cefe8d08931_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0, _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0, _Multiply_555c57ef879143edbde63cefe8d08931_Out_2);
            surface.Alpha = (_Multiply_555c57ef879143edbde63cefe8d08931_Out_2).x;
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
        float _SineScale;
        float _SineSpeed;
        float4 _MainTexture_TexelSize;
        float _NoiseScale;
        float _NoiseSpeed;
        float4 _Mask_TexelSize;
        float4 _Color;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
        {
             float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
             Out = lerp(Min, Max, randomno);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_712f8becc96549708393364882838e40_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Property_081a97c7a7a047c8972e88454611ab72_Out_0 = _NoiseSpeed;
            float _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_081a97c7a7a047c8972e88454611ab72_Out_0, _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2);
            float4 _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0 = IN.uv0;
            float _Split_8752ca323fb546f59bb88575a8aa2451_R_1 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[0];
            float _Split_8752ca323fb546f59bb88575a8aa2451_G_2 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[1];
            float _Split_8752ca323fb546f59bb88575a8aa2451_B_3 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[2];
            float _Split_8752ca323fb546f59bb88575a8aa2451_A_4 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[3];
            float _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2;
            Unity_Add_float(_Multiply_75def10fb0e44c6f937b52556d44eede_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_G_2, _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2);
            float _Property_a21dafd03b564bc1821b192300c6a03d_Out_0 = _NoiseScale;
            float _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2;
            Unity_SimpleNoise_float((_Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2.xx), _Property_a21dafd03b564bc1821b192300c6a03d_Out_0, _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2);
            float _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3;
            Unity_Remap_float(_SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2, float2 (0, 1), float2 (-0.5, 0.5), _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3);
            float _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2;
            Unity_SimpleNoise_float((IN.TimeParameters.x.xx), 200, _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2);
            float _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2;
            Unity_Power_float(_SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2, 2, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2);
            float _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2;
            Unity_Multiply_float_float(_Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2, _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2);
            float _Add_bca220147d64497991700a1caba002e8_Out_2;
            Unity_Add_float(_Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_R_1, _Add_bca220147d64497991700a1caba002e8_Out_2);
            float4 _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0 = SAMPLE_TEXTURE2D(_Property_712f8becc96549708393364882838e40_Out_0.tex, _Property_712f8becc96549708393364882838e40_Out_0.samplerstate, _Property_712f8becc96549708393364882838e40_Out_0.GetTransformedUV((_Add_bca220147d64497991700a1caba002e8_Out_2.xx)));
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_R_4 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.r;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_G_5 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.g;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_B_6 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.b;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_A_7 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.a;
            UnityTexture2D _Property_5204891db70249b0a52300a027b0a232_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _RandomRange_836306569ce5434980c448ff62df855d_Out_3;
            Unity_RandomRange_float((IN.TimeParameters.x.xx), 0, 1, _RandomRange_836306569ce5434980c448ff62df855d_Out_3);
            float2 _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_RandomRange_836306569ce5434980c448ff62df855d_Out_3.xx), (_Power_e2a693f75dac463f9f418b87a67a3a52_Out_2.xx), _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3);
            float4 _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5204891db70249b0a52300a027b0a232_Out_0.tex, _Property_5204891db70249b0a52300a027b0a232_Out_0.samplerstate, _Property_5204891db70249b0a52300a027b0a232_Out_0.GetTransformedUV(_TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3));
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_R_4 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.r;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_G_5 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.g;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_B_6 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.b;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_A_7 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.a;
            float4 _Multiply_555c57ef879143edbde63cefe8d08931_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0, _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0, _Multiply_555c57ef879143edbde63cefe8d08931_Out_2);
            surface.Alpha = (_Multiply_555c57ef879143edbde63cefe8d08931_Out_2).x;
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
        float _SineScale;
        float _SineSpeed;
        float4 _MainTexture_TexelSize;
        float _NoiseScale;
        float _NoiseSpeed;
        float4 _Mask_TexelSize;
        float4 _Color;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
        {
             float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
             Out = lerp(Min, Max, randomno);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_712f8becc96549708393364882838e40_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Property_081a97c7a7a047c8972e88454611ab72_Out_0 = _NoiseSpeed;
            float _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_081a97c7a7a047c8972e88454611ab72_Out_0, _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2);
            float4 _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0 = IN.uv0;
            float _Split_8752ca323fb546f59bb88575a8aa2451_R_1 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[0];
            float _Split_8752ca323fb546f59bb88575a8aa2451_G_2 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[1];
            float _Split_8752ca323fb546f59bb88575a8aa2451_B_3 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[2];
            float _Split_8752ca323fb546f59bb88575a8aa2451_A_4 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[3];
            float _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2;
            Unity_Add_float(_Multiply_75def10fb0e44c6f937b52556d44eede_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_G_2, _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2);
            float _Property_a21dafd03b564bc1821b192300c6a03d_Out_0 = _NoiseScale;
            float _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2;
            Unity_SimpleNoise_float((_Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2.xx), _Property_a21dafd03b564bc1821b192300c6a03d_Out_0, _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2);
            float _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3;
            Unity_Remap_float(_SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2, float2 (0, 1), float2 (-0.5, 0.5), _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3);
            float _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2;
            Unity_SimpleNoise_float((IN.TimeParameters.x.xx), 200, _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2);
            float _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2;
            Unity_Power_float(_SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2, 2, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2);
            float _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2;
            Unity_Multiply_float_float(_Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2, _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2);
            float _Add_bca220147d64497991700a1caba002e8_Out_2;
            Unity_Add_float(_Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_R_1, _Add_bca220147d64497991700a1caba002e8_Out_2);
            float4 _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0 = SAMPLE_TEXTURE2D(_Property_712f8becc96549708393364882838e40_Out_0.tex, _Property_712f8becc96549708393364882838e40_Out_0.samplerstate, _Property_712f8becc96549708393364882838e40_Out_0.GetTransformedUV((_Add_bca220147d64497991700a1caba002e8_Out_2.xx)));
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_R_4 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.r;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_G_5 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.g;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_B_6 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.b;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_A_7 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.a;
            UnityTexture2D _Property_5204891db70249b0a52300a027b0a232_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _RandomRange_836306569ce5434980c448ff62df855d_Out_3;
            Unity_RandomRange_float((IN.TimeParameters.x.xx), 0, 1, _RandomRange_836306569ce5434980c448ff62df855d_Out_3);
            float2 _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_RandomRange_836306569ce5434980c448ff62df855d_Out_3.xx), (_Power_e2a693f75dac463f9f418b87a67a3a52_Out_2.xx), _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3);
            float4 _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5204891db70249b0a52300a027b0a232_Out_0.tex, _Property_5204891db70249b0a52300a027b0a232_Out_0.samplerstate, _Property_5204891db70249b0a52300a027b0a232_Out_0.GetTransformedUV(_TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3));
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_R_4 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.r;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_G_5 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.g;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_B_6 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.b;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_A_7 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.a;
            float4 _Multiply_555c57ef879143edbde63cefe8d08931_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0, _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0, _Multiply_555c57ef879143edbde63cefe8d08931_Out_2);
            surface.Alpha = (_Multiply_555c57ef879143edbde63cefe8d08931_Out_2).x;
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
        Cull Back
        
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
        float _SineScale;
        float _SineSpeed;
        float4 _MainTexture_TexelSize;
        float _NoiseScale;
        float _NoiseSpeed;
        float4 _Mask_TexelSize;
        float4 _Color;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
        {
             float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
             Out = lerp(Min, Max, randomno);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_712f8becc96549708393364882838e40_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Property_081a97c7a7a047c8972e88454611ab72_Out_0 = _NoiseSpeed;
            float _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_081a97c7a7a047c8972e88454611ab72_Out_0, _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2);
            float4 _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0 = IN.uv0;
            float _Split_8752ca323fb546f59bb88575a8aa2451_R_1 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[0];
            float _Split_8752ca323fb546f59bb88575a8aa2451_G_2 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[1];
            float _Split_8752ca323fb546f59bb88575a8aa2451_B_3 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[2];
            float _Split_8752ca323fb546f59bb88575a8aa2451_A_4 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[3];
            float _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2;
            Unity_Add_float(_Multiply_75def10fb0e44c6f937b52556d44eede_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_G_2, _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2);
            float _Property_a21dafd03b564bc1821b192300c6a03d_Out_0 = _NoiseScale;
            float _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2;
            Unity_SimpleNoise_float((_Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2.xx), _Property_a21dafd03b564bc1821b192300c6a03d_Out_0, _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2);
            float _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3;
            Unity_Remap_float(_SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2, float2 (0, 1), float2 (-0.5, 0.5), _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3);
            float _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2;
            Unity_SimpleNoise_float((IN.TimeParameters.x.xx), 200, _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2);
            float _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2;
            Unity_Power_float(_SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2, 2, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2);
            float _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2;
            Unity_Multiply_float_float(_Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2, _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2);
            float _Add_bca220147d64497991700a1caba002e8_Out_2;
            Unity_Add_float(_Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_R_1, _Add_bca220147d64497991700a1caba002e8_Out_2);
            float4 _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0 = SAMPLE_TEXTURE2D(_Property_712f8becc96549708393364882838e40_Out_0.tex, _Property_712f8becc96549708393364882838e40_Out_0.samplerstate, _Property_712f8becc96549708393364882838e40_Out_0.GetTransformedUV((_Add_bca220147d64497991700a1caba002e8_Out_2.xx)));
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_R_4 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.r;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_G_5 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.g;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_B_6 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.b;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_A_7 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.a;
            UnityTexture2D _Property_5204891db70249b0a52300a027b0a232_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _RandomRange_836306569ce5434980c448ff62df855d_Out_3;
            Unity_RandomRange_float((IN.TimeParameters.x.xx), 0, 1, _RandomRange_836306569ce5434980c448ff62df855d_Out_3);
            float2 _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_RandomRange_836306569ce5434980c448ff62df855d_Out_3.xx), (_Power_e2a693f75dac463f9f418b87a67a3a52_Out_2.xx), _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3);
            float4 _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5204891db70249b0a52300a027b0a232_Out_0.tex, _Property_5204891db70249b0a52300a027b0a232_Out_0.samplerstate, _Property_5204891db70249b0a52300a027b0a232_Out_0.GetTransformedUV(_TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3));
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_R_4 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.r;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_G_5 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.g;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_B_6 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.b;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_A_7 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.a;
            float4 _Multiply_555c57ef879143edbde63cefe8d08931_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0, _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0, _Multiply_555c57ef879143edbde63cefe8d08931_Out_2);
            surface.Alpha = (_Multiply_555c57ef879143edbde63cefe8d08931_Out_2).x;
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
        float _SineScale;
        float _SineSpeed;
        float4 _MainTexture_TexelSize;
        float _NoiseScale;
        float _NoiseSpeed;
        float4 _Mask_TexelSize;
        float4 _Color;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
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
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        
        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            float angle = dot(uv, float2(12.9898, 78.233));
            #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
            #endif
            return frac(sin(angle)*43758.5453);
        }
        
        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }
        
        
        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);
        
            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);
        
            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;
        
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
        
            Out = t;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
        {
             float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
             Out = lerp(Min, Max, randomno);
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_712f8becc96549708393364882838e40_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Property_081a97c7a7a047c8972e88454611ab72_Out_0 = _NoiseSpeed;
            float _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_081a97c7a7a047c8972e88454611ab72_Out_0, _Multiply_75def10fb0e44c6f937b52556d44eede_Out_2);
            float4 _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0 = IN.uv0;
            float _Split_8752ca323fb546f59bb88575a8aa2451_R_1 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[0];
            float _Split_8752ca323fb546f59bb88575a8aa2451_G_2 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[1];
            float _Split_8752ca323fb546f59bb88575a8aa2451_B_3 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[2];
            float _Split_8752ca323fb546f59bb88575a8aa2451_A_4 = _UV_6e91e472e47b48e3aed7a7e5d0b0050e_Out_0[3];
            float _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2;
            Unity_Add_float(_Multiply_75def10fb0e44c6f937b52556d44eede_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_G_2, _Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2);
            float _Property_a21dafd03b564bc1821b192300c6a03d_Out_0 = _NoiseScale;
            float _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2;
            Unity_SimpleNoise_float((_Add_8a55dd7bcb194691b5f1fb00f4491e62_Out_2.xx), _Property_a21dafd03b564bc1821b192300c6a03d_Out_0, _SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2);
            float _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3;
            Unity_Remap_float(_SimpleNoise_e7e4671de1c84ca786a9d76196ab573c_Out_2, float2 (0, 1), float2 (-0.5, 0.5), _Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3);
            float _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2;
            Unity_SimpleNoise_float((IN.TimeParameters.x.xx), 200, _SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2);
            float _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2;
            Unity_Power_float(_SimpleNoise_f88ec08806ac4da6a3e9a2a6bc5679f7_Out_2, 2, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2);
            float _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2;
            Unity_Multiply_float_float(_Remap_a13f44e3a40545b9b12f58eca5d0ad7a_Out_3, _Power_e2a693f75dac463f9f418b87a67a3a52_Out_2, _Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2);
            float _Add_bca220147d64497991700a1caba002e8_Out_2;
            Unity_Add_float(_Multiply_d81fc51d6f5741eba3cf0fab9f4afb9a_Out_2, _Split_8752ca323fb546f59bb88575a8aa2451_R_1, _Add_bca220147d64497991700a1caba002e8_Out_2);
            float4 _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0 = SAMPLE_TEXTURE2D(_Property_712f8becc96549708393364882838e40_Out_0.tex, _Property_712f8becc96549708393364882838e40_Out_0.samplerstate, _Property_712f8becc96549708393364882838e40_Out_0.GetTransformedUV((_Add_bca220147d64497991700a1caba002e8_Out_2.xx)));
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_R_4 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.r;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_G_5 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.g;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_B_6 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.b;
            float _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_A_7 = _SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0.a;
            UnityTexture2D _Property_5204891db70249b0a52300a027b0a232_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float _RandomRange_836306569ce5434980c448ff62df855d_Out_3;
            Unity_RandomRange_float((IN.TimeParameters.x.xx), 0, 1, _RandomRange_836306569ce5434980c448ff62df855d_Out_3);
            float2 _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_RandomRange_836306569ce5434980c448ff62df855d_Out_3.xx), (_Power_e2a693f75dac463f9f418b87a67a3a52_Out_2.xx), _TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3);
            float4 _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5204891db70249b0a52300a027b0a232_Out_0.tex, _Property_5204891db70249b0a52300a027b0a232_Out_0.samplerstate, _Property_5204891db70249b0a52300a027b0a232_Out_0.GetTransformedUV(_TilingAndOffset_c33b0b84c1f74adebbaffd1b70f20199_Out_3));
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_R_4 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.r;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_G_5 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.g;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_B_6 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.b;
            float _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_A_7 = _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0.a;
            float4 _Multiply_555c57ef879143edbde63cefe8d08931_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_2f8a816ce3924aa68e9edffecc8ef297_RGBA_0, _SampleTexture2D_f6022ce327fd451184a5f0e691b93a77_RGBA_0, _Multiply_555c57ef879143edbde63cefe8d08931_Out_2);
            surface.Alpha = (_Multiply_555c57ef879143edbde63cefe8d08931_Out_2).x;
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