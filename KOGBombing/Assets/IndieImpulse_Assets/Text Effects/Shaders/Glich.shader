Shader "IndieImpulse/Unlit/Glich"
{
    Properties
    {
        [NoScaleOffset]_MainTexture("MainTexture", 2D) = "white" {}
        _Tilling("Tilling", Vector) = (1, 1, 0, 0)
        [HDR]_Color("Color", Color) = (0, 0, 0, 0)
        [NoScaleOffset]_Mask("Mask", 2D) = "white" {}
        _Step("Step", Float) = 0
        _Speed("Speed", Float) = 50
        [NoScaleOffset]_Mask2("Mask2", 2D) = "white" {}
        _NoiseScale("NoiseScale", Float) = 84.1
        _MaskTilling("MaskTilling", Vector) = (0.07, 1, 0, 0)
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
        float4 _MainTexture_TexelSize;
        float _Step;
        float4 _Color;
        float4 _Mask_TexelSize;
        float _Speed;
        float4 _Mask2_TexelSize;
        float _NoiseScale;
        float2 _MaskTilling;
        float2 _Tilling;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_Mask2);
        SAMPLER(sampler_Mask2);
        
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
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
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
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
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
            UnityTexture2D _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float2 _Property_80725aa1953045a6b2369da5bcbcd886_Out_0 = _Tilling;
            float2 _TilingAndOffset_d539835b5ea6470d9c39ee6e10af0260_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_80725aa1953045a6b2369da5bcbcd886_Out_0, float2 (0, 0), _TilingAndOffset_d539835b5ea6470d9c39ee6e10af0260_Out_3);
            float4 _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.tex, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.samplerstate, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.GetTransformedUV(_TilingAndOffset_d539835b5ea6470d9c39ee6e10af0260_Out_3));
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_R_4 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.r;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_G_5 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.g;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_B_6 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.b;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_A_7 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.a;
            float4 _Property_2a9bb8cc8dcb40b599ece5efed683d87_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
            float4 _Multiply_21bd5b991f9d42f0835b7c915df4f9e7_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Property_2a9bb8cc8dcb40b599ece5efed683d87_Out_0, _Multiply_21bd5b991f9d42f0835b7c915df4f9e7_Out_2);
            float _Property_bfe6090c872141128e400c9019d28c69_Out_0 = _Step;
            UnityTexture2D _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float2 _Property_9f8f503afe794ed0990327418e96c666_Out_0 = _MaskTilling;
            float _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2;
            Unity_Multiply_float_float(_Property_bfe6090c872141128e400c9019d28c69_Out_0, 2, _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2);
            float2 _Vector2_57667d357fb04430b39ae30005b309c2_Out_0 = float2(_Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2, 0);
            float2 _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_9f8f503afe794ed0990327418e96c666_Out_0, _Vector2_57667d357fb04430b39ae30005b309c2_Out_0, _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3);
            float4 _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.tex, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.samplerstate, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.GetTransformedUV(_TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3));
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_R_4 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.r;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_G_5 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.g;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_B_6 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.b;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_A_7 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.a;
            float _Property_2245caa11a69482db4d22a1af3fddf88_Out_0 = _Speed;
            float _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_2245caa11a69482db4d22a1af3fddf88_Out_0, _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2);
            float _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1;
            Unity_Sine_float(_Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2, _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1);
            float2 _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0 = float2(_Sine_bf527e5dbe274edbbe74a080315e46db_Out_1, 0);
            float2 _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0, _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3);
            float _Property_4224004e1caa4c3783267cf8114f48ea_Out_0 = _NoiseScale;
            float _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2;
            Unity_SimpleNoise_float(_TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3, _Property_4224004e1caa4c3783267cf8114f48ea_Out_0, _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2);
            float4 _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2;
            Unity_Add_float4(_SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0, (_SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2);
            float4 _Step_e8440f440837496ca37b32a7218982b4_Out_2;
            Unity_Step_float4((_Property_bfe6090c872141128e400c9019d28c69_Out_0.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2, _Step_e8440f440837496ca37b32a7218982b4_Out_2);
            UnityTexture2D _Property_54ab521b9a7745e6950b7712875b993c_Out_0 = UnityBuildTexture2DStructNoScale(_Mask2);
            float4 _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54ab521b9a7745e6950b7712875b993c_Out_0.tex, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.samplerstate, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_R_4 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.r;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_G_5 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.g;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_B_6 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.b;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_A_7 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.a;
            float4 _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2;
            Unity_Multiply_float4_float4(_Step_e8440f440837496ca37b32a7218982b4_Out_2, _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0, _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2);
            surface.BaseColor = (_Multiply_21bd5b991f9d42f0835b7c915df4f9e7_Out_2.xyz);
            surface.Alpha = (_Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2).x;
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
        float4 _MainTexture_TexelSize;
        float _Step;
        float4 _Color;
        float4 _Mask_TexelSize;
        float _Speed;
        float4 _Mask2_TexelSize;
        float _NoiseScale;
        float2 _MaskTilling;
        float2 _Tilling;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_Mask2);
        SAMPLER(sampler_Mask2);
        
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
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
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
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
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
            float _Property_bfe6090c872141128e400c9019d28c69_Out_0 = _Step;
            UnityTexture2D _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float2 _Property_9f8f503afe794ed0990327418e96c666_Out_0 = _MaskTilling;
            float _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2;
            Unity_Multiply_float_float(_Property_bfe6090c872141128e400c9019d28c69_Out_0, 2, _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2);
            float2 _Vector2_57667d357fb04430b39ae30005b309c2_Out_0 = float2(_Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2, 0);
            float2 _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_9f8f503afe794ed0990327418e96c666_Out_0, _Vector2_57667d357fb04430b39ae30005b309c2_Out_0, _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3);
            float4 _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.tex, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.samplerstate, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.GetTransformedUV(_TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3));
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_R_4 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.r;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_G_5 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.g;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_B_6 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.b;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_A_7 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.a;
            float _Property_2245caa11a69482db4d22a1af3fddf88_Out_0 = _Speed;
            float _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_2245caa11a69482db4d22a1af3fddf88_Out_0, _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2);
            float _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1;
            Unity_Sine_float(_Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2, _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1);
            float2 _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0 = float2(_Sine_bf527e5dbe274edbbe74a080315e46db_Out_1, 0);
            float2 _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0, _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3);
            float _Property_4224004e1caa4c3783267cf8114f48ea_Out_0 = _NoiseScale;
            float _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2;
            Unity_SimpleNoise_float(_TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3, _Property_4224004e1caa4c3783267cf8114f48ea_Out_0, _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2);
            float4 _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2;
            Unity_Add_float4(_SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0, (_SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2);
            float4 _Step_e8440f440837496ca37b32a7218982b4_Out_2;
            Unity_Step_float4((_Property_bfe6090c872141128e400c9019d28c69_Out_0.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2, _Step_e8440f440837496ca37b32a7218982b4_Out_2);
            UnityTexture2D _Property_54ab521b9a7745e6950b7712875b993c_Out_0 = UnityBuildTexture2DStructNoScale(_Mask2);
            float4 _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54ab521b9a7745e6950b7712875b993c_Out_0.tex, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.samplerstate, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_R_4 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.r;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_G_5 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.g;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_B_6 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.b;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_A_7 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.a;
            float4 _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2;
            Unity_Multiply_float4_float4(_Step_e8440f440837496ca37b32a7218982b4_Out_2, _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0, _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2);
            surface.Alpha = (_Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2).x;
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
        float4 _MainTexture_TexelSize;
        float _Step;
        float4 _Color;
        float4 _Mask_TexelSize;
        float _Speed;
        float4 _Mask2_TexelSize;
        float _NoiseScale;
        float2 _MaskTilling;
        float2 _Tilling;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_Mask2);
        SAMPLER(sampler_Mask2);
        
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
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
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
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
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
            float _Property_bfe6090c872141128e400c9019d28c69_Out_0 = _Step;
            UnityTexture2D _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float2 _Property_9f8f503afe794ed0990327418e96c666_Out_0 = _MaskTilling;
            float _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2;
            Unity_Multiply_float_float(_Property_bfe6090c872141128e400c9019d28c69_Out_0, 2, _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2);
            float2 _Vector2_57667d357fb04430b39ae30005b309c2_Out_0 = float2(_Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2, 0);
            float2 _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_9f8f503afe794ed0990327418e96c666_Out_0, _Vector2_57667d357fb04430b39ae30005b309c2_Out_0, _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3);
            float4 _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.tex, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.samplerstate, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.GetTransformedUV(_TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3));
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_R_4 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.r;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_G_5 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.g;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_B_6 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.b;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_A_7 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.a;
            float _Property_2245caa11a69482db4d22a1af3fddf88_Out_0 = _Speed;
            float _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_2245caa11a69482db4d22a1af3fddf88_Out_0, _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2);
            float _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1;
            Unity_Sine_float(_Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2, _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1);
            float2 _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0 = float2(_Sine_bf527e5dbe274edbbe74a080315e46db_Out_1, 0);
            float2 _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0, _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3);
            float _Property_4224004e1caa4c3783267cf8114f48ea_Out_0 = _NoiseScale;
            float _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2;
            Unity_SimpleNoise_float(_TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3, _Property_4224004e1caa4c3783267cf8114f48ea_Out_0, _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2);
            float4 _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2;
            Unity_Add_float4(_SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0, (_SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2);
            float4 _Step_e8440f440837496ca37b32a7218982b4_Out_2;
            Unity_Step_float4((_Property_bfe6090c872141128e400c9019d28c69_Out_0.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2, _Step_e8440f440837496ca37b32a7218982b4_Out_2);
            UnityTexture2D _Property_54ab521b9a7745e6950b7712875b993c_Out_0 = UnityBuildTexture2DStructNoScale(_Mask2);
            float4 _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54ab521b9a7745e6950b7712875b993c_Out_0.tex, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.samplerstate, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_R_4 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.r;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_G_5 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.g;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_B_6 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.b;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_A_7 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.a;
            float4 _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2;
            Unity_Multiply_float4_float4(_Step_e8440f440837496ca37b32a7218982b4_Out_2, _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0, _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2);
            surface.Alpha = (_Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2).x;
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
        float4 _MainTexture_TexelSize;
        float _Step;
        float4 _Color;
        float4 _Mask_TexelSize;
        float _Speed;
        float4 _Mask2_TexelSize;
        float _NoiseScale;
        float2 _MaskTilling;
        float2 _Tilling;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_Mask2);
        SAMPLER(sampler_Mask2);
        
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
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
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
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
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
            float _Property_bfe6090c872141128e400c9019d28c69_Out_0 = _Step;
            UnityTexture2D _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float2 _Property_9f8f503afe794ed0990327418e96c666_Out_0 = _MaskTilling;
            float _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2;
            Unity_Multiply_float_float(_Property_bfe6090c872141128e400c9019d28c69_Out_0, 2, _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2);
            float2 _Vector2_57667d357fb04430b39ae30005b309c2_Out_0 = float2(_Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2, 0);
            float2 _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_9f8f503afe794ed0990327418e96c666_Out_0, _Vector2_57667d357fb04430b39ae30005b309c2_Out_0, _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3);
            float4 _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.tex, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.samplerstate, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.GetTransformedUV(_TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3));
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_R_4 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.r;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_G_5 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.g;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_B_6 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.b;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_A_7 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.a;
            float _Property_2245caa11a69482db4d22a1af3fddf88_Out_0 = _Speed;
            float _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_2245caa11a69482db4d22a1af3fddf88_Out_0, _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2);
            float _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1;
            Unity_Sine_float(_Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2, _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1);
            float2 _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0 = float2(_Sine_bf527e5dbe274edbbe74a080315e46db_Out_1, 0);
            float2 _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0, _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3);
            float _Property_4224004e1caa4c3783267cf8114f48ea_Out_0 = _NoiseScale;
            float _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2;
            Unity_SimpleNoise_float(_TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3, _Property_4224004e1caa4c3783267cf8114f48ea_Out_0, _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2);
            float4 _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2;
            Unity_Add_float4(_SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0, (_SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2);
            float4 _Step_e8440f440837496ca37b32a7218982b4_Out_2;
            Unity_Step_float4((_Property_bfe6090c872141128e400c9019d28c69_Out_0.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2, _Step_e8440f440837496ca37b32a7218982b4_Out_2);
            UnityTexture2D _Property_54ab521b9a7745e6950b7712875b993c_Out_0 = UnityBuildTexture2DStructNoScale(_Mask2);
            float4 _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54ab521b9a7745e6950b7712875b993c_Out_0.tex, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.samplerstate, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_R_4 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.r;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_G_5 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.g;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_B_6 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.b;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_A_7 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.a;
            float4 _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2;
            Unity_Multiply_float4_float4(_Step_e8440f440837496ca37b32a7218982b4_Out_2, _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0, _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2);
            surface.Alpha = (_Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2).x;
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
        float4 _MainTexture_TexelSize;
        float _Step;
        float4 _Color;
        float4 _Mask_TexelSize;
        float _Speed;
        float4 _Mask2_TexelSize;
        float _NoiseScale;
        float2 _MaskTilling;
        float2 _Tilling;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_Mask2);
        SAMPLER(sampler_Mask2);
        
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
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
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
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
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
            float _Property_bfe6090c872141128e400c9019d28c69_Out_0 = _Step;
            UnityTexture2D _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float2 _Property_9f8f503afe794ed0990327418e96c666_Out_0 = _MaskTilling;
            float _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2;
            Unity_Multiply_float_float(_Property_bfe6090c872141128e400c9019d28c69_Out_0, 2, _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2);
            float2 _Vector2_57667d357fb04430b39ae30005b309c2_Out_0 = float2(_Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2, 0);
            float2 _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_9f8f503afe794ed0990327418e96c666_Out_0, _Vector2_57667d357fb04430b39ae30005b309c2_Out_0, _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3);
            float4 _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.tex, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.samplerstate, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.GetTransformedUV(_TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3));
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_R_4 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.r;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_G_5 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.g;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_B_6 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.b;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_A_7 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.a;
            float _Property_2245caa11a69482db4d22a1af3fddf88_Out_0 = _Speed;
            float _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_2245caa11a69482db4d22a1af3fddf88_Out_0, _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2);
            float _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1;
            Unity_Sine_float(_Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2, _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1);
            float2 _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0 = float2(_Sine_bf527e5dbe274edbbe74a080315e46db_Out_1, 0);
            float2 _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0, _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3);
            float _Property_4224004e1caa4c3783267cf8114f48ea_Out_0 = _NoiseScale;
            float _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2;
            Unity_SimpleNoise_float(_TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3, _Property_4224004e1caa4c3783267cf8114f48ea_Out_0, _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2);
            float4 _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2;
            Unity_Add_float4(_SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0, (_SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2);
            float4 _Step_e8440f440837496ca37b32a7218982b4_Out_2;
            Unity_Step_float4((_Property_bfe6090c872141128e400c9019d28c69_Out_0.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2, _Step_e8440f440837496ca37b32a7218982b4_Out_2);
            UnityTexture2D _Property_54ab521b9a7745e6950b7712875b993c_Out_0 = UnityBuildTexture2DStructNoScale(_Mask2);
            float4 _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54ab521b9a7745e6950b7712875b993c_Out_0.tex, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.samplerstate, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_R_4 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.r;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_G_5 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.g;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_B_6 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.b;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_A_7 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.a;
            float4 _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2;
            Unity_Multiply_float4_float4(_Step_e8440f440837496ca37b32a7218982b4_Out_2, _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0, _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2);
            surface.Alpha = (_Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2).x;
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
        float4 _MainTexture_TexelSize;
        float _Step;
        float4 _Color;
        float4 _Mask_TexelSize;
        float _Speed;
        float4 _Mask2_TexelSize;
        float _NoiseScale;
        float2 _MaskTilling;
        float2 _Tilling;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_Mask2);
        SAMPLER(sampler_Mask2);
        
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
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
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
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
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
            float _Property_bfe6090c872141128e400c9019d28c69_Out_0 = _Step;
            UnityTexture2D _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float2 _Property_9f8f503afe794ed0990327418e96c666_Out_0 = _MaskTilling;
            float _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2;
            Unity_Multiply_float_float(_Property_bfe6090c872141128e400c9019d28c69_Out_0, 2, _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2);
            float2 _Vector2_57667d357fb04430b39ae30005b309c2_Out_0 = float2(_Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2, 0);
            float2 _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_9f8f503afe794ed0990327418e96c666_Out_0, _Vector2_57667d357fb04430b39ae30005b309c2_Out_0, _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3);
            float4 _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.tex, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.samplerstate, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.GetTransformedUV(_TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3));
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_R_4 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.r;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_G_5 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.g;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_B_6 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.b;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_A_7 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.a;
            float _Property_2245caa11a69482db4d22a1af3fddf88_Out_0 = _Speed;
            float _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_2245caa11a69482db4d22a1af3fddf88_Out_0, _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2);
            float _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1;
            Unity_Sine_float(_Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2, _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1);
            float2 _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0 = float2(_Sine_bf527e5dbe274edbbe74a080315e46db_Out_1, 0);
            float2 _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0, _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3);
            float _Property_4224004e1caa4c3783267cf8114f48ea_Out_0 = _NoiseScale;
            float _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2;
            Unity_SimpleNoise_float(_TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3, _Property_4224004e1caa4c3783267cf8114f48ea_Out_0, _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2);
            float4 _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2;
            Unity_Add_float4(_SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0, (_SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2);
            float4 _Step_e8440f440837496ca37b32a7218982b4_Out_2;
            Unity_Step_float4((_Property_bfe6090c872141128e400c9019d28c69_Out_0.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2, _Step_e8440f440837496ca37b32a7218982b4_Out_2);
            UnityTexture2D _Property_54ab521b9a7745e6950b7712875b993c_Out_0 = UnityBuildTexture2DStructNoScale(_Mask2);
            float4 _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54ab521b9a7745e6950b7712875b993c_Out_0.tex, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.samplerstate, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_R_4 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.r;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_G_5 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.g;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_B_6 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.b;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_A_7 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.a;
            float4 _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2;
            Unity_Multiply_float4_float4(_Step_e8440f440837496ca37b32a7218982b4_Out_2, _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0, _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2);
            surface.Alpha = (_Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2).x;
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
        float4 _MainTexture_TexelSize;
        float _Step;
        float4 _Color;
        float4 _Mask_TexelSize;
        float _Speed;
        float4 _Mask2_TexelSize;
        float _NoiseScale;
        float2 _MaskTilling;
        float2 _Tilling;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_Mask2);
        SAMPLER(sampler_Mask2);
        
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
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
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
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
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
            UnityTexture2D _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float2 _Property_80725aa1953045a6b2369da5bcbcd886_Out_0 = _Tilling;
            float2 _TilingAndOffset_d539835b5ea6470d9c39ee6e10af0260_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_80725aa1953045a6b2369da5bcbcd886_Out_0, float2 (0, 0), _TilingAndOffset_d539835b5ea6470d9c39ee6e10af0260_Out_3);
            float4 _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.tex, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.samplerstate, _Property_4536b3cb5d2e48f58681412afbfadffe_Out_0.GetTransformedUV(_TilingAndOffset_d539835b5ea6470d9c39ee6e10af0260_Out_3));
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_R_4 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.r;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_G_5 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.g;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_B_6 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.b;
            float _SampleTexture2D_496e39b84e9e462986a50c732333062b_A_7 = _SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0.a;
            float4 _Property_2a9bb8cc8dcb40b599ece5efed683d87_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
            float4 _Multiply_21bd5b991f9d42f0835b7c915df4f9e7_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_496e39b84e9e462986a50c732333062b_RGBA_0, _Property_2a9bb8cc8dcb40b599ece5efed683d87_Out_0, _Multiply_21bd5b991f9d42f0835b7c915df4f9e7_Out_2);
            float _Property_bfe6090c872141128e400c9019d28c69_Out_0 = _Step;
            UnityTexture2D _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float2 _Property_9f8f503afe794ed0990327418e96c666_Out_0 = _MaskTilling;
            float _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2;
            Unity_Multiply_float_float(_Property_bfe6090c872141128e400c9019d28c69_Out_0, 2, _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2);
            float2 _Vector2_57667d357fb04430b39ae30005b309c2_Out_0 = float2(_Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2, 0);
            float2 _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_9f8f503afe794ed0990327418e96c666_Out_0, _Vector2_57667d357fb04430b39ae30005b309c2_Out_0, _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3);
            float4 _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.tex, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.samplerstate, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.GetTransformedUV(_TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3));
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_R_4 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.r;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_G_5 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.g;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_B_6 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.b;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_A_7 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.a;
            float _Property_2245caa11a69482db4d22a1af3fddf88_Out_0 = _Speed;
            float _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_2245caa11a69482db4d22a1af3fddf88_Out_0, _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2);
            float _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1;
            Unity_Sine_float(_Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2, _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1);
            float2 _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0 = float2(_Sine_bf527e5dbe274edbbe74a080315e46db_Out_1, 0);
            float2 _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0, _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3);
            float _Property_4224004e1caa4c3783267cf8114f48ea_Out_0 = _NoiseScale;
            float _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2;
            Unity_SimpleNoise_float(_TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3, _Property_4224004e1caa4c3783267cf8114f48ea_Out_0, _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2);
            float4 _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2;
            Unity_Add_float4(_SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0, (_SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2);
            float4 _Step_e8440f440837496ca37b32a7218982b4_Out_2;
            Unity_Step_float4((_Property_bfe6090c872141128e400c9019d28c69_Out_0.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2, _Step_e8440f440837496ca37b32a7218982b4_Out_2);
            UnityTexture2D _Property_54ab521b9a7745e6950b7712875b993c_Out_0 = UnityBuildTexture2DStructNoScale(_Mask2);
            float4 _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54ab521b9a7745e6950b7712875b993c_Out_0.tex, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.samplerstate, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_R_4 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.r;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_G_5 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.g;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_B_6 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.b;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_A_7 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.a;
            float4 _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2;
            Unity_Multiply_float4_float4(_Step_e8440f440837496ca37b32a7218982b4_Out_2, _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0, _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2);
            surface.BaseColor = (_Multiply_21bd5b991f9d42f0835b7c915df4f9e7_Out_2.xyz);
            surface.Alpha = (_Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2).x;
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
        float4 _MainTexture_TexelSize;
        float _Step;
        float4 _Color;
        float4 _Mask_TexelSize;
        float _Speed;
        float4 _Mask2_TexelSize;
        float _NoiseScale;
        float2 _MaskTilling;
        float2 _Tilling;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_Mask2);
        SAMPLER(sampler_Mask2);
        
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
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
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
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
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
            float _Property_bfe6090c872141128e400c9019d28c69_Out_0 = _Step;
            UnityTexture2D _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float2 _Property_9f8f503afe794ed0990327418e96c666_Out_0 = _MaskTilling;
            float _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2;
            Unity_Multiply_float_float(_Property_bfe6090c872141128e400c9019d28c69_Out_0, 2, _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2);
            float2 _Vector2_57667d357fb04430b39ae30005b309c2_Out_0 = float2(_Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2, 0);
            float2 _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_9f8f503afe794ed0990327418e96c666_Out_0, _Vector2_57667d357fb04430b39ae30005b309c2_Out_0, _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3);
            float4 _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.tex, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.samplerstate, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.GetTransformedUV(_TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3));
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_R_4 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.r;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_G_5 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.g;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_B_6 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.b;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_A_7 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.a;
            float _Property_2245caa11a69482db4d22a1af3fddf88_Out_0 = _Speed;
            float _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_2245caa11a69482db4d22a1af3fddf88_Out_0, _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2);
            float _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1;
            Unity_Sine_float(_Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2, _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1);
            float2 _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0 = float2(_Sine_bf527e5dbe274edbbe74a080315e46db_Out_1, 0);
            float2 _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0, _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3);
            float _Property_4224004e1caa4c3783267cf8114f48ea_Out_0 = _NoiseScale;
            float _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2;
            Unity_SimpleNoise_float(_TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3, _Property_4224004e1caa4c3783267cf8114f48ea_Out_0, _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2);
            float4 _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2;
            Unity_Add_float4(_SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0, (_SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2);
            float4 _Step_e8440f440837496ca37b32a7218982b4_Out_2;
            Unity_Step_float4((_Property_bfe6090c872141128e400c9019d28c69_Out_0.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2, _Step_e8440f440837496ca37b32a7218982b4_Out_2);
            UnityTexture2D _Property_54ab521b9a7745e6950b7712875b993c_Out_0 = UnityBuildTexture2DStructNoScale(_Mask2);
            float4 _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54ab521b9a7745e6950b7712875b993c_Out_0.tex, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.samplerstate, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_R_4 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.r;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_G_5 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.g;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_B_6 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.b;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_A_7 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.a;
            float4 _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2;
            Unity_Multiply_float4_float4(_Step_e8440f440837496ca37b32a7218982b4_Out_2, _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0, _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2);
            surface.Alpha = (_Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2).x;
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
        float4 _MainTexture_TexelSize;
        float _Step;
        float4 _Color;
        float4 _Mask_TexelSize;
        float _Speed;
        float4 _Mask2_TexelSize;
        float _NoiseScale;
        float2 _MaskTilling;
        float2 _Tilling;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_Mask2);
        SAMPLER(sampler_Mask2);
        
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
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
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
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
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
            float _Property_bfe6090c872141128e400c9019d28c69_Out_0 = _Step;
            UnityTexture2D _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float2 _Property_9f8f503afe794ed0990327418e96c666_Out_0 = _MaskTilling;
            float _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2;
            Unity_Multiply_float_float(_Property_bfe6090c872141128e400c9019d28c69_Out_0, 2, _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2);
            float2 _Vector2_57667d357fb04430b39ae30005b309c2_Out_0 = float2(_Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2, 0);
            float2 _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_9f8f503afe794ed0990327418e96c666_Out_0, _Vector2_57667d357fb04430b39ae30005b309c2_Out_0, _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3);
            float4 _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.tex, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.samplerstate, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.GetTransformedUV(_TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3));
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_R_4 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.r;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_G_5 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.g;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_B_6 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.b;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_A_7 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.a;
            float _Property_2245caa11a69482db4d22a1af3fddf88_Out_0 = _Speed;
            float _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_2245caa11a69482db4d22a1af3fddf88_Out_0, _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2);
            float _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1;
            Unity_Sine_float(_Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2, _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1);
            float2 _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0 = float2(_Sine_bf527e5dbe274edbbe74a080315e46db_Out_1, 0);
            float2 _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0, _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3);
            float _Property_4224004e1caa4c3783267cf8114f48ea_Out_0 = _NoiseScale;
            float _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2;
            Unity_SimpleNoise_float(_TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3, _Property_4224004e1caa4c3783267cf8114f48ea_Out_0, _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2);
            float4 _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2;
            Unity_Add_float4(_SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0, (_SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2);
            float4 _Step_e8440f440837496ca37b32a7218982b4_Out_2;
            Unity_Step_float4((_Property_bfe6090c872141128e400c9019d28c69_Out_0.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2, _Step_e8440f440837496ca37b32a7218982b4_Out_2);
            UnityTexture2D _Property_54ab521b9a7745e6950b7712875b993c_Out_0 = UnityBuildTexture2DStructNoScale(_Mask2);
            float4 _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54ab521b9a7745e6950b7712875b993c_Out_0.tex, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.samplerstate, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_R_4 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.r;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_G_5 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.g;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_B_6 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.b;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_A_7 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.a;
            float4 _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2;
            Unity_Multiply_float4_float4(_Step_e8440f440837496ca37b32a7218982b4_Out_2, _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0, _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2);
            surface.Alpha = (_Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2).x;
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
        float4 _MainTexture_TexelSize;
        float _Step;
        float4 _Color;
        float4 _Mask_TexelSize;
        float _Speed;
        float4 _Mask2_TexelSize;
        float _NoiseScale;
        float2 _MaskTilling;
        float2 _Tilling;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_Mask2);
        SAMPLER(sampler_Mask2);
        
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
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
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
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
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
            float _Property_bfe6090c872141128e400c9019d28c69_Out_0 = _Step;
            UnityTexture2D _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float2 _Property_9f8f503afe794ed0990327418e96c666_Out_0 = _MaskTilling;
            float _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2;
            Unity_Multiply_float_float(_Property_bfe6090c872141128e400c9019d28c69_Out_0, 2, _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2);
            float2 _Vector2_57667d357fb04430b39ae30005b309c2_Out_0 = float2(_Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2, 0);
            float2 _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_9f8f503afe794ed0990327418e96c666_Out_0, _Vector2_57667d357fb04430b39ae30005b309c2_Out_0, _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3);
            float4 _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.tex, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.samplerstate, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.GetTransformedUV(_TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3));
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_R_4 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.r;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_G_5 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.g;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_B_6 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.b;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_A_7 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.a;
            float _Property_2245caa11a69482db4d22a1af3fddf88_Out_0 = _Speed;
            float _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_2245caa11a69482db4d22a1af3fddf88_Out_0, _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2);
            float _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1;
            Unity_Sine_float(_Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2, _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1);
            float2 _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0 = float2(_Sine_bf527e5dbe274edbbe74a080315e46db_Out_1, 0);
            float2 _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0, _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3);
            float _Property_4224004e1caa4c3783267cf8114f48ea_Out_0 = _NoiseScale;
            float _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2;
            Unity_SimpleNoise_float(_TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3, _Property_4224004e1caa4c3783267cf8114f48ea_Out_0, _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2);
            float4 _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2;
            Unity_Add_float4(_SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0, (_SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2);
            float4 _Step_e8440f440837496ca37b32a7218982b4_Out_2;
            Unity_Step_float4((_Property_bfe6090c872141128e400c9019d28c69_Out_0.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2, _Step_e8440f440837496ca37b32a7218982b4_Out_2);
            UnityTexture2D _Property_54ab521b9a7745e6950b7712875b993c_Out_0 = UnityBuildTexture2DStructNoScale(_Mask2);
            float4 _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54ab521b9a7745e6950b7712875b993c_Out_0.tex, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.samplerstate, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_R_4 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.r;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_G_5 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.g;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_B_6 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.b;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_A_7 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.a;
            float4 _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2;
            Unity_Multiply_float4_float4(_Step_e8440f440837496ca37b32a7218982b4_Out_2, _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0, _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2);
            surface.Alpha = (_Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2).x;
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
        float4 _MainTexture_TexelSize;
        float _Step;
        float4 _Color;
        float4 _Mask_TexelSize;
        float _Speed;
        float4 _Mask2_TexelSize;
        float _NoiseScale;
        float2 _MaskTilling;
        float2 _Tilling;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_Mask2);
        SAMPLER(sampler_Mask2);
        
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
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
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
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
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
            float _Property_bfe6090c872141128e400c9019d28c69_Out_0 = _Step;
            UnityTexture2D _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float2 _Property_9f8f503afe794ed0990327418e96c666_Out_0 = _MaskTilling;
            float _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2;
            Unity_Multiply_float_float(_Property_bfe6090c872141128e400c9019d28c69_Out_0, 2, _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2);
            float2 _Vector2_57667d357fb04430b39ae30005b309c2_Out_0 = float2(_Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2, 0);
            float2 _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_9f8f503afe794ed0990327418e96c666_Out_0, _Vector2_57667d357fb04430b39ae30005b309c2_Out_0, _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3);
            float4 _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.tex, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.samplerstate, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.GetTransformedUV(_TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3));
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_R_4 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.r;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_G_5 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.g;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_B_6 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.b;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_A_7 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.a;
            float _Property_2245caa11a69482db4d22a1af3fddf88_Out_0 = _Speed;
            float _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_2245caa11a69482db4d22a1af3fddf88_Out_0, _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2);
            float _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1;
            Unity_Sine_float(_Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2, _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1);
            float2 _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0 = float2(_Sine_bf527e5dbe274edbbe74a080315e46db_Out_1, 0);
            float2 _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0, _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3);
            float _Property_4224004e1caa4c3783267cf8114f48ea_Out_0 = _NoiseScale;
            float _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2;
            Unity_SimpleNoise_float(_TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3, _Property_4224004e1caa4c3783267cf8114f48ea_Out_0, _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2);
            float4 _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2;
            Unity_Add_float4(_SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0, (_SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2);
            float4 _Step_e8440f440837496ca37b32a7218982b4_Out_2;
            Unity_Step_float4((_Property_bfe6090c872141128e400c9019d28c69_Out_0.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2, _Step_e8440f440837496ca37b32a7218982b4_Out_2);
            UnityTexture2D _Property_54ab521b9a7745e6950b7712875b993c_Out_0 = UnityBuildTexture2DStructNoScale(_Mask2);
            float4 _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54ab521b9a7745e6950b7712875b993c_Out_0.tex, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.samplerstate, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_R_4 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.r;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_G_5 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.g;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_B_6 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.b;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_A_7 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.a;
            float4 _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2;
            Unity_Multiply_float4_float4(_Step_e8440f440837496ca37b32a7218982b4_Out_2, _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0, _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2);
            surface.Alpha = (_Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2).x;
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
        float4 _MainTexture_TexelSize;
        float _Step;
        float4 _Color;
        float4 _Mask_TexelSize;
        float _Speed;
        float4 _Mask2_TexelSize;
        float _NoiseScale;
        float2 _MaskTilling;
        float2 _Tilling;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_Mask2);
        SAMPLER(sampler_Mask2);
        
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
        
        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
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
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
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
            float _Property_bfe6090c872141128e400c9019d28c69_Out_0 = _Step;
            UnityTexture2D _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float2 _Property_9f8f503afe794ed0990327418e96c666_Out_0 = _MaskTilling;
            float _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2;
            Unity_Multiply_float_float(_Property_bfe6090c872141128e400c9019d28c69_Out_0, 2, _Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2);
            float2 _Vector2_57667d357fb04430b39ae30005b309c2_Out_0 = float2(_Multiply_af60f63073fe42d4b0a2b5bea347503b_Out_2, 0);
            float2 _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_9f8f503afe794ed0990327418e96c666_Out_0, _Vector2_57667d357fb04430b39ae30005b309c2_Out_0, _TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3);
            float4 _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.tex, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.samplerstate, _Property_5a0df985675b4aa1b1f14597bab38aae_Out_0.GetTransformedUV(_TilingAndOffset_fae0761d9487444b8f03dd1f4f067749_Out_3));
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_R_4 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.r;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_G_5 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.g;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_B_6 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.b;
            float _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_A_7 = _SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0.a;
            float _Property_2245caa11a69482db4d22a1af3fddf88_Out_0 = _Speed;
            float _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_2245caa11a69482db4d22a1af3fddf88_Out_0, _Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2);
            float _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1;
            Unity_Sine_float(_Multiply_af4d26f834df4eba9d7b920ebd9f43ec_Out_2, _Sine_bf527e5dbe274edbbe74a080315e46db_Out_1);
            float2 _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0 = float2(_Sine_bf527e5dbe274edbbe74a080315e46db_Out_1, 0);
            float2 _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_a48ec123d5e94e0dae9740ad30b93a5b_Out_0, _TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3);
            float _Property_4224004e1caa4c3783267cf8114f48ea_Out_0 = _NoiseScale;
            float _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2;
            Unity_SimpleNoise_float(_TilingAndOffset_557d8aa0144a464e95686c753b27a30b_Out_3, _Property_4224004e1caa4c3783267cf8114f48ea_Out_0, _SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2);
            float4 _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2;
            Unity_Add_float4(_SampleTexture2D_e6894d251b4f4cc59ba8a9183c49d2d4_RGBA_0, (_SimpleNoise_99a02aa891e74ceb8cb1ffa92dd84b87_Out_2.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2);
            float4 _Step_e8440f440837496ca37b32a7218982b4_Out_2;
            Unity_Step_float4((_Property_bfe6090c872141128e400c9019d28c69_Out_0.xxxx), _Add_2e731edae8d84cf4a3d8802bc6c24b37_Out_2, _Step_e8440f440837496ca37b32a7218982b4_Out_2);
            UnityTexture2D _Property_54ab521b9a7745e6950b7712875b993c_Out_0 = UnityBuildTexture2DStructNoScale(_Mask2);
            float4 _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_54ab521b9a7745e6950b7712875b993c_Out_0.tex, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.samplerstate, _Property_54ab521b9a7745e6950b7712875b993c_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_R_4 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.r;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_G_5 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.g;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_B_6 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.b;
            float _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_A_7 = _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0.a;
            float4 _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2;
            Unity_Multiply_float4_float4(_Step_e8440f440837496ca37b32a7218982b4_Out_2, _SampleTexture2D_f72d7ec1d75c4afca155838b2867e45a_RGBA_0, _Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2);
            surface.Alpha = (_Multiply_931d2bb9b825404798219c1ad6cfd4d8_Out_2).x;
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