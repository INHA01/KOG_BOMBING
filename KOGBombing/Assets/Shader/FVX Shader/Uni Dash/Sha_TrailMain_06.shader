Shader "Custom/Sha_TrailMain_06"
{
    Properties
    {
        _Speed_01("Speed_01", Vector) = (-1.5, 0, 0, 0)
        _Speed_02("Speed_02", Vector) = (-2.5, 0, 0, 0)
        [HDR]_Color("Color", Color) = (1, 1, 1, 0)
        [NonModifiableTextureData][NoScaleOffset]_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D("Texture2D", 2D) = "white" {}
        [NonModifiableTextureData][NoScaleOffset]_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D("Texture2D", 2D) = "white" {}
        [NonModifiableTextureData][NoScaleOffset]_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D("Texture2D", 2D) = "white" {}
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
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
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
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
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
        float4 _SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D_TexelSize;
        float2 _Speed_02;
        float2 _Speed_01;
        float4 _Color;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D);
        
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
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
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
            float4 _Property_02774685fc824323a01c5e9b2275c93b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
            float2 _Property_1b3b8e656dd1425b80fcc06a5f2fd040_Out_0_Vector2 = _Speed_01;
            float2 _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_1b3b8e656dd1425b80fcc06a5f2fd040_Out_0_Vector2, _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2);
            float2 _TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2, _TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2);
            float4 _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2) );
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_R_4_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.r;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_G_5_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.g;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_B_6_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.b;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_A_7_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.a;
            float _Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float;
            Unity_Power_float(_SampleTexture2D_5f58c4d43681425f90252312ae848063_R_4_Float, float(0.96), _Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float);
            float2 _Property_313f93585ce34821b6e05f2c12386f41_Out_0_Vector2 = _Speed_02;
            float2 _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_313f93585ce34821b6e05f2c12386f41_Out_0_Vector2, _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2);
            float2 _TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2, _TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2);
            float4 _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2) );
            float _SampleTexture2D_239fcea241424805bf883350adea5623_R_4_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.r;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_G_5_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.g;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_B_6_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.b;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_A_7_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.a;
            float _Power_305ce99f5383442cab842d3fba009929_Out_2_Float;
            Unity_Power_float(_SampleTexture2D_239fcea241424805bf883350adea5623_R_4_Float, float(0.83), _Power_305ce99f5383442cab842d3fba009929_Out_2_Float);
            float _Add_daa936fe525346569496b580f6a6a380_Out_2_Float;
            Unity_Add_float(_Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float, _Power_305ce99f5383442cab842d3fba009929_Out_2_Float, _Add_daa936fe525346569496b580f6a6a380_Out_2_Float);
            float4 _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_R_4_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.r;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_G_5_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.g;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_B_6_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.b;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_A_7_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.a;
            float4 _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4 = IN.uv0;
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[0];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_G_2_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[1];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_B_3_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[2];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_A_4_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[3];
            float _Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float;
            Unity_Smoothstep_float(float(0), float(0.1), _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float, _Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float);
            float _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float;
            Unity_Smoothstep_float(float(1), float(0), _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float, _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float);
            float _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float, _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float, _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float);
            float _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_R_4_Float, _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float, _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float);
            float _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float;
            Unity_Lerp_float(float(0), _Add_daa936fe525346569496b580f6a6a380_Out_2_Float, _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float, _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float);
            float4 _Multiply_b3d1ffc4f8594b17b680e22679e4dde1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_02774685fc824323a01c5e9b2275c93b_Out_0_Vector4, (_Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float.xxxx), _Multiply_b3d1ffc4f8594b17b680e22679e4dde1_Out_2_Vector4);
            surface.BaseColor = (_Multiply_b3d1ffc4f8594b17b680e22679e4dde1_Out_2_Vector4.xyz);
            surface.Alpha = _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float;
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
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
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
        float4 _SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D_TexelSize;
        float2 _Speed_02;
        float2 _Speed_01;
        float4 _Color;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D);
        
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
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
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
            float2 _Property_1b3b8e656dd1425b80fcc06a5f2fd040_Out_0_Vector2 = _Speed_01;
            float2 _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_1b3b8e656dd1425b80fcc06a5f2fd040_Out_0_Vector2, _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2);
            float2 _TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2, _TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2);
            float4 _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2) );
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_R_4_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.r;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_G_5_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.g;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_B_6_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.b;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_A_7_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.a;
            float _Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float;
            Unity_Power_float(_SampleTexture2D_5f58c4d43681425f90252312ae848063_R_4_Float, float(0.96), _Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float);
            float2 _Property_313f93585ce34821b6e05f2c12386f41_Out_0_Vector2 = _Speed_02;
            float2 _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_313f93585ce34821b6e05f2c12386f41_Out_0_Vector2, _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2);
            float2 _TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2, _TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2);
            float4 _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2) );
            float _SampleTexture2D_239fcea241424805bf883350adea5623_R_4_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.r;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_G_5_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.g;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_B_6_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.b;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_A_7_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.a;
            float _Power_305ce99f5383442cab842d3fba009929_Out_2_Float;
            Unity_Power_float(_SampleTexture2D_239fcea241424805bf883350adea5623_R_4_Float, float(0.83), _Power_305ce99f5383442cab842d3fba009929_Out_2_Float);
            float _Add_daa936fe525346569496b580f6a6a380_Out_2_Float;
            Unity_Add_float(_Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float, _Power_305ce99f5383442cab842d3fba009929_Out_2_Float, _Add_daa936fe525346569496b580f6a6a380_Out_2_Float);
            float4 _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_R_4_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.r;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_G_5_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.g;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_B_6_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.b;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_A_7_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.a;
            float4 _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4 = IN.uv0;
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[0];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_G_2_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[1];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_B_3_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[2];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_A_4_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[3];
            float _Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float;
            Unity_Smoothstep_float(float(0), float(0.1), _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float, _Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float);
            float _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float;
            Unity_Smoothstep_float(float(1), float(0), _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float, _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float);
            float _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float, _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float, _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float);
            float _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_R_4_Float, _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float, _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float);
            float _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float;
            Unity_Lerp_float(float(0), _Add_daa936fe525346569496b580f6a6a380_Out_2_Float, _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float, _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float);
            surface.Alpha = _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float;
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
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
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
        float4 _SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D_TexelSize;
        float2 _Speed_02;
        float2 _Speed_01;
        float4 _Color;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D);
        
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
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
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
            float2 _Property_1b3b8e656dd1425b80fcc06a5f2fd040_Out_0_Vector2 = _Speed_01;
            float2 _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_1b3b8e656dd1425b80fcc06a5f2fd040_Out_0_Vector2, _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2);
            float2 _TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2, _TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2);
            float4 _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2) );
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_R_4_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.r;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_G_5_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.g;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_B_6_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.b;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_A_7_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.a;
            float _Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float;
            Unity_Power_float(_SampleTexture2D_5f58c4d43681425f90252312ae848063_R_4_Float, float(0.96), _Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float);
            float2 _Property_313f93585ce34821b6e05f2c12386f41_Out_0_Vector2 = _Speed_02;
            float2 _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_313f93585ce34821b6e05f2c12386f41_Out_0_Vector2, _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2);
            float2 _TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2, _TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2);
            float4 _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2) );
            float _SampleTexture2D_239fcea241424805bf883350adea5623_R_4_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.r;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_G_5_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.g;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_B_6_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.b;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_A_7_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.a;
            float _Power_305ce99f5383442cab842d3fba009929_Out_2_Float;
            Unity_Power_float(_SampleTexture2D_239fcea241424805bf883350adea5623_R_4_Float, float(0.83), _Power_305ce99f5383442cab842d3fba009929_Out_2_Float);
            float _Add_daa936fe525346569496b580f6a6a380_Out_2_Float;
            Unity_Add_float(_Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float, _Power_305ce99f5383442cab842d3fba009929_Out_2_Float, _Add_daa936fe525346569496b580f6a6a380_Out_2_Float);
            float4 _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_R_4_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.r;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_G_5_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.g;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_B_6_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.b;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_A_7_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.a;
            float4 _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4 = IN.uv0;
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[0];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_G_2_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[1];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_B_3_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[2];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_A_4_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[3];
            float _Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float;
            Unity_Smoothstep_float(float(0), float(0.1), _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float, _Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float);
            float _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float;
            Unity_Smoothstep_float(float(1), float(0), _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float, _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float);
            float _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float, _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float, _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float);
            float _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_R_4_Float, _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float, _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float);
            float _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float;
            Unity_Lerp_float(float(0), _Add_daa936fe525346569496b580f6a6a380_Out_2_Float, _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float, _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float);
            surface.Alpha = _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float;
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
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
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
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            output.texCoord0.xyzw = input.texCoord0;
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
        float4 _SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D_TexelSize;
        float2 _Speed_02;
        float2 _Speed_01;
        float4 _Color;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D);
        
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
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
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
            float4 _Property_02774685fc824323a01c5e9b2275c93b_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
            float2 _Property_1b3b8e656dd1425b80fcc06a5f2fd040_Out_0_Vector2 = _Speed_01;
            float2 _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_1b3b8e656dd1425b80fcc06a5f2fd040_Out_0_Vector2, _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2);
            float2 _TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2, _TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2);
            float4 _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2) );
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_R_4_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.r;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_G_5_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.g;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_B_6_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.b;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_A_7_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.a;
            float _Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float;
            Unity_Power_float(_SampleTexture2D_5f58c4d43681425f90252312ae848063_R_4_Float, float(0.96), _Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float);
            float2 _Property_313f93585ce34821b6e05f2c12386f41_Out_0_Vector2 = _Speed_02;
            float2 _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_313f93585ce34821b6e05f2c12386f41_Out_0_Vector2, _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2);
            float2 _TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2, _TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2);
            float4 _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2) );
            float _SampleTexture2D_239fcea241424805bf883350adea5623_R_4_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.r;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_G_5_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.g;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_B_6_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.b;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_A_7_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.a;
            float _Power_305ce99f5383442cab842d3fba009929_Out_2_Float;
            Unity_Power_float(_SampleTexture2D_239fcea241424805bf883350adea5623_R_4_Float, float(0.83), _Power_305ce99f5383442cab842d3fba009929_Out_2_Float);
            float _Add_daa936fe525346569496b580f6a6a380_Out_2_Float;
            Unity_Add_float(_Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float, _Power_305ce99f5383442cab842d3fba009929_Out_2_Float, _Add_daa936fe525346569496b580f6a6a380_Out_2_Float);
            float4 _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_R_4_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.r;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_G_5_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.g;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_B_6_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.b;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_A_7_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.a;
            float4 _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4 = IN.uv0;
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[0];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_G_2_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[1];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_B_3_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[2];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_A_4_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[3];
            float _Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float;
            Unity_Smoothstep_float(float(0), float(0.1), _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float, _Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float);
            float _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float;
            Unity_Smoothstep_float(float(1), float(0), _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float, _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float);
            float _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float, _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float, _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float);
            float _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_R_4_Float, _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float, _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float);
            float _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float;
            Unity_Lerp_float(float(0), _Add_daa936fe525346569496b580f6a6a380_Out_2_Float, _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float, _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float);
            float4 _Multiply_b3d1ffc4f8594b17b680e22679e4dde1_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_02774685fc824323a01c5e9b2275c93b_Out_0_Vector4, (_Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float.xxxx), _Multiply_b3d1ffc4f8594b17b680e22679e4dde1_Out_2_Vector4);
            surface.BaseColor = (_Multiply_b3d1ffc4f8594b17b680e22679e4dde1_Out_2_Vector4.xyz);
            surface.Alpha = _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float;
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
        #define VARYINGS_NEED_TEXCOORD0
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
        float4 _SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D_TexelSize;
        float2 _Speed_02;
        float2 _Speed_01;
        float4 _Color;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D);
        
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
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
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
            float2 _Property_1b3b8e656dd1425b80fcc06a5f2fd040_Out_0_Vector2 = _Speed_01;
            float2 _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_1b3b8e656dd1425b80fcc06a5f2fd040_Out_0_Vector2, _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2);
            float2 _TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2, _TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2);
            float4 _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2) );
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_R_4_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.r;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_G_5_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.g;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_B_6_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.b;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_A_7_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.a;
            float _Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float;
            Unity_Power_float(_SampleTexture2D_5f58c4d43681425f90252312ae848063_R_4_Float, float(0.96), _Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float);
            float2 _Property_313f93585ce34821b6e05f2c12386f41_Out_0_Vector2 = _Speed_02;
            float2 _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_313f93585ce34821b6e05f2c12386f41_Out_0_Vector2, _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2);
            float2 _TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2, _TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2);
            float4 _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2) );
            float _SampleTexture2D_239fcea241424805bf883350adea5623_R_4_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.r;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_G_5_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.g;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_B_6_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.b;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_A_7_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.a;
            float _Power_305ce99f5383442cab842d3fba009929_Out_2_Float;
            Unity_Power_float(_SampleTexture2D_239fcea241424805bf883350adea5623_R_4_Float, float(0.83), _Power_305ce99f5383442cab842d3fba009929_Out_2_Float);
            float _Add_daa936fe525346569496b580f6a6a380_Out_2_Float;
            Unity_Add_float(_Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float, _Power_305ce99f5383442cab842d3fba009929_Out_2_Float, _Add_daa936fe525346569496b580f6a6a380_Out_2_Float);
            float4 _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_R_4_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.r;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_G_5_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.g;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_B_6_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.b;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_A_7_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.a;
            float4 _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4 = IN.uv0;
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[0];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_G_2_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[1];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_B_3_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[2];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_A_4_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[3];
            float _Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float;
            Unity_Smoothstep_float(float(0), float(0.1), _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float, _Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float);
            float _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float;
            Unity_Smoothstep_float(float(1), float(0), _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float, _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float);
            float _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float, _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float, _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float);
            float _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_R_4_Float, _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float, _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float);
            float _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float;
            Unity_Lerp_float(float(0), _Add_daa936fe525346569496b580f6a6a380_Out_2_Float, _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float, _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float);
            surface.Alpha = _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float;
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
        #define VARYINGS_NEED_TEXCOORD0
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
        float4 _SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D_TexelSize;
        float4 _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D_TexelSize;
        float2 _Speed_02;
        float2 _Speed_01;
        float4 _Color;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D);
        TEXTURE2D(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D);
        SAMPLER(sampler_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D);
        
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
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
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
            float2 _Property_1b3b8e656dd1425b80fcc06a5f2fd040_Out_0_Vector2 = _Speed_01;
            float2 _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_1b3b8e656dd1425b80fcc06a5f2fd040_Out_0_Vector2, _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2);
            float2 _TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Multiply_01907a45f1c14acfad0cb8cdddc1e356_Out_2_Vector2, _TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2);
            float4 _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_5f58c4d43681425f90252312ae848063_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_d8601a81b9414f50a2da2f8cfc132ee3_Out_3_Vector2) );
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_R_4_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.r;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_G_5_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.g;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_B_6_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.b;
            float _SampleTexture2D_5f58c4d43681425f90252312ae848063_A_7_Float = _SampleTexture2D_5f58c4d43681425f90252312ae848063_RGBA_0_Vector4.a;
            float _Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float;
            Unity_Power_float(_SampleTexture2D_5f58c4d43681425f90252312ae848063_R_4_Float, float(0.96), _Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float);
            float2 _Property_313f93585ce34821b6e05f2c12386f41_Out_0_Vector2 = _Speed_02;
            float2 _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_313f93585ce34821b6e05f2c12386f41_Out_0_Vector2, _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2);
            float2 _TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Multiply_df4169be26774339846948b7da2e4c97_Out_2_Vector2, _TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2);
            float4 _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_239fcea241424805bf883350adea5623_Texture_1_Texture2D).GetTransformedUV(_TilingAndOffset_c5ec7cf96cf946fdb25c547fd62c28fa_Out_3_Vector2) );
            float _SampleTexture2D_239fcea241424805bf883350adea5623_R_4_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.r;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_G_5_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.g;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_B_6_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.b;
            float _SampleTexture2D_239fcea241424805bf883350adea5623_A_7_Float = _SampleTexture2D_239fcea241424805bf883350adea5623_RGBA_0_Vector4.a;
            float _Power_305ce99f5383442cab842d3fba009929_Out_2_Float;
            Unity_Power_float(_SampleTexture2D_239fcea241424805bf883350adea5623_R_4_Float, float(0.83), _Power_305ce99f5383442cab842d3fba009929_Out_2_Float);
            float _Add_daa936fe525346569496b580f6a6a380_Out_2_Float;
            Unity_Add_float(_Power_47faee043cdd442cadf007a49b16c29d_Out_2_Float, _Power_305ce99f5383442cab842d3fba009929_Out_2_Float, _Add_daa936fe525346569496b580f6a6a380_Out_2_Float);
            float4 _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).tex, UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).samplerstate, UnityBuildTexture2DStructNoScale(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_Texture_1_Texture2D).GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_R_4_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.r;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_G_5_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.g;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_B_6_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.b;
            float _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_A_7_Float = _SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_RGBA_0_Vector4.a;
            float4 _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4 = IN.uv0;
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[0];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_G_2_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[1];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_B_3_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[2];
            float _Split_fadca67f284940f8b9dcfe1b8bf05d68_A_4_Float = _UV_d5e50b77f82b433396e85862c5bdee9d_Out_0_Vector4[3];
            float _Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float;
            Unity_Smoothstep_float(float(0), float(0.1), _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float, _Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float);
            float _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float;
            Unity_Smoothstep_float(float(1), float(0), _Split_fadca67f284940f8b9dcfe1b8bf05d68_R_1_Float, _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float);
            float _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_f8e1c341ea2249cbb0ade8598797cb88_Out_3_Float, _Smoothstep_6f35cf82932c488d90402d60b542fa7c_Out_3_Float, _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float);
            float _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2D_69f2ac76f4754607a6052c6b1b8eb849_R_4_Float, _Multiply_c9041664a2574e75b832440cc4590e61_Out_2_Float, _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float);
            float _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float;
            Unity_Lerp_float(float(0), _Add_daa936fe525346569496b580f6a6a380_Out_2_Float, _Multiply_53752a29e567412d9c3678565740bd11_Out_2_Float, _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float);
            surface.Alpha = _Lerp_78c7b57e7c7543cbb6c442e49ed7e550_Out_3_Float;
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