Shader "Custom/Distortion_Mask"
{
    Properties
    {
        [HDR]Color_8d5a5550e5e247dc8fee637c322ecc9a("Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]Texture2D_820708fcff4644f3b3da6bdd009d7eb9("Main Texture", 2D) = "white" {}
        [NoScaleOffset]Texture2D_a2e457d6a8724b7f908d707eef5a1ae9("Mask", 2D) = "white" {}
        Vector2_561adb05ccbe422385d36f62fe07de5a("Main Texture Speed", Vector) = (0, 0, 0, 0)
        Vector2_67044496c8bb4ceb927c5010101e399e("Distortion Speed", Vector) = (0, 0, 0, 0)
        Vector1_168473e68d2b441294f91d3bce874b84("Noise amount", Float) = 10
        Vector1_df3a63b233b3492c9587c46f23cab5e7("Distortion amount", Range(-0.2, 0.2)) = 0.1
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
        Cull Off
        Blend SrcAlpha One, One One
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
        float4 Color_8d5a5550e5e247dc8fee637c322ecc9a;
        float4 Texture2D_820708fcff4644f3b3da6bdd009d7eb9_TexelSize;
        float4 Texture2D_a2e457d6a8724b7f908d707eef5a1ae9_TexelSize;
        float2 Vector2_561adb05ccbe422385d36f62fe07de5a;
        float2 Vector2_67044496c8bb4ceb927c5010101e399e;
        float Vector1_168473e68d2b441294f91d3bce874b84;
        float Vector1_df3a63b233b3492c9587c46f23cab5e7;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_820708fcff4644f3b3da6bdd009d7eb9);
        SAMPLER(samplerTexture2D_820708fcff4644f3b3da6bdd009d7eb9);
        TEXTURE2D(Texture2D_a2e457d6a8724b7f908d707eef5a1ae9);
        SAMPLER(samplerTexture2D_a2e457d6a8724b7f908d707eef5a1ae9);
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
        {
            float x; Hash_LegacyMod_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
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
            float4 _Property_e1b7b98f7c334786a00ef2d2dd0c7210_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(Color_8d5a5550e5e247dc8fee637c322ecc9a) : Color_8d5a5550e5e247dc8fee637c322ecc9a;
            UnityTexture2D _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_a2e457d6a8724b7f908d707eef5a1ae9);
            float4 _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.tex, _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.samplerstate, _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_R_4_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.r;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_G_5_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.g;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_B_6_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.b;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_A_7_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.a;
            UnityTexture2D _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_820708fcff4644f3b3da6bdd009d7eb9);
            float2 _Property_ff45f9f2d26d4f28a04b67b7f21156af_Out_0_Vector2 = Vector2_561adb05ccbe422385d36f62fe07de5a;
            float2 _Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ff45f9f2d26d4f28a04b67b7f21156af_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2);
            float4 _UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4 = IN.uv0;
            float2 _Property_d7db6a2a1ca441cd920f74045d698b5e_Out_0_Vector2 = Vector2_67044496c8bb4ceb927c5010101e399e;
            float2 _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_d7db6a2a1ca441cd920f74045d698b5e_Out_0_Vector2, _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2);
            float2 _Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2;
            Unity_Add_float2((_UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4.xy), _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2, _Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2);
            float _Property_87139ddd2a244dfe921ca9eab37a9025_Out_0_Float = Vector1_168473e68d2b441294f91d3bce874b84;
            float _GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2, _Property_87139ddd2a244dfe921ca9eab37a9025_Out_0_Float, _GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float);
            float _Property_08e2ca1bf5b24fe58e91d45de93cbbf7_Out_0_Float = Vector1_df3a63b233b3492c9587c46f23cab5e7;
            float4 _Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4;
            Unity_Lerp_float4(_UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4, (_GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float.xxxx), (_Property_08e2ca1bf5b24fe58e91d45de93cbbf7_Out_0_Float.xxxx), _Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4);
            float2 _Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2;
            Unity_Add_float2(_Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2, (_Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4.xy), _Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2);
            float4 _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.tex, _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.samplerstate, _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.GetTransformedUV(_Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2) );
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_R_4_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.r;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_G_5_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.g;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_B_6_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.b;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_A_7_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.a;
            float4 _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4, _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4, _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4);
            float4 _Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_e1b7b98f7c334786a00ef2d2dd0c7210_Out_0_Vector4, _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4, _Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4);
            float4 _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4, IN.VertexColor, _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4);
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_R_1_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[0];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_G_2_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[1];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_B_3_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[2];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_A_4_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[3];
            surface.BaseColor = (_Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4.xyz);
            surface.Alpha = _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_A_4_Float;
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
        float4 Color_8d5a5550e5e247dc8fee637c322ecc9a;
        float4 Texture2D_820708fcff4644f3b3da6bdd009d7eb9_TexelSize;
        float4 Texture2D_a2e457d6a8724b7f908d707eef5a1ae9_TexelSize;
        float2 Vector2_561adb05ccbe422385d36f62fe07de5a;
        float2 Vector2_67044496c8bb4ceb927c5010101e399e;
        float Vector1_168473e68d2b441294f91d3bce874b84;
        float Vector1_df3a63b233b3492c9587c46f23cab5e7;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_820708fcff4644f3b3da6bdd009d7eb9);
        SAMPLER(samplerTexture2D_820708fcff4644f3b3da6bdd009d7eb9);
        TEXTURE2D(Texture2D_a2e457d6a8724b7f908d707eef5a1ae9);
        SAMPLER(samplerTexture2D_a2e457d6a8724b7f908d707eef5a1ae9);
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
        {
            float x; Hash_LegacyMod_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
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
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_e1b7b98f7c334786a00ef2d2dd0c7210_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(Color_8d5a5550e5e247dc8fee637c322ecc9a) : Color_8d5a5550e5e247dc8fee637c322ecc9a;
            UnityTexture2D _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_a2e457d6a8724b7f908d707eef5a1ae9);
            float4 _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.tex, _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.samplerstate, _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_R_4_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.r;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_G_5_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.g;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_B_6_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.b;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_A_7_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.a;
            UnityTexture2D _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_820708fcff4644f3b3da6bdd009d7eb9);
            float2 _Property_ff45f9f2d26d4f28a04b67b7f21156af_Out_0_Vector2 = Vector2_561adb05ccbe422385d36f62fe07de5a;
            float2 _Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ff45f9f2d26d4f28a04b67b7f21156af_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2);
            float4 _UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4 = IN.uv0;
            float2 _Property_d7db6a2a1ca441cd920f74045d698b5e_Out_0_Vector2 = Vector2_67044496c8bb4ceb927c5010101e399e;
            float2 _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_d7db6a2a1ca441cd920f74045d698b5e_Out_0_Vector2, _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2);
            float2 _Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2;
            Unity_Add_float2((_UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4.xy), _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2, _Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2);
            float _Property_87139ddd2a244dfe921ca9eab37a9025_Out_0_Float = Vector1_168473e68d2b441294f91d3bce874b84;
            float _GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2, _Property_87139ddd2a244dfe921ca9eab37a9025_Out_0_Float, _GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float);
            float _Property_08e2ca1bf5b24fe58e91d45de93cbbf7_Out_0_Float = Vector1_df3a63b233b3492c9587c46f23cab5e7;
            float4 _Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4;
            Unity_Lerp_float4(_UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4, (_GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float.xxxx), (_Property_08e2ca1bf5b24fe58e91d45de93cbbf7_Out_0_Float.xxxx), _Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4);
            float2 _Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2;
            Unity_Add_float2(_Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2, (_Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4.xy), _Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2);
            float4 _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.tex, _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.samplerstate, _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.GetTransformedUV(_Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2) );
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_R_4_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.r;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_G_5_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.g;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_B_6_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.b;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_A_7_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.a;
            float4 _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4, _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4, _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4);
            float4 _Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_e1b7b98f7c334786a00ef2d2dd0c7210_Out_0_Vector4, _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4, _Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4);
            float4 _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4, IN.VertexColor, _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4);
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_R_1_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[0];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_G_2_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[1];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_B_3_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[2];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_A_4_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[3];
            surface.Alpha = _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_A_4_Float;
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
        float4 Color_8d5a5550e5e247dc8fee637c322ecc9a;
        float4 Texture2D_820708fcff4644f3b3da6bdd009d7eb9_TexelSize;
        float4 Texture2D_a2e457d6a8724b7f908d707eef5a1ae9_TexelSize;
        float2 Vector2_561adb05ccbe422385d36f62fe07de5a;
        float2 Vector2_67044496c8bb4ceb927c5010101e399e;
        float Vector1_168473e68d2b441294f91d3bce874b84;
        float Vector1_df3a63b233b3492c9587c46f23cab5e7;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_820708fcff4644f3b3da6bdd009d7eb9);
        SAMPLER(samplerTexture2D_820708fcff4644f3b3da6bdd009d7eb9);
        TEXTURE2D(Texture2D_a2e457d6a8724b7f908d707eef5a1ae9);
        SAMPLER(samplerTexture2D_a2e457d6a8724b7f908d707eef5a1ae9);
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
        {
            float x; Hash_LegacyMod_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
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
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_e1b7b98f7c334786a00ef2d2dd0c7210_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(Color_8d5a5550e5e247dc8fee637c322ecc9a) : Color_8d5a5550e5e247dc8fee637c322ecc9a;
            UnityTexture2D _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_a2e457d6a8724b7f908d707eef5a1ae9);
            float4 _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.tex, _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.samplerstate, _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_R_4_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.r;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_G_5_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.g;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_B_6_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.b;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_A_7_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.a;
            UnityTexture2D _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_820708fcff4644f3b3da6bdd009d7eb9);
            float2 _Property_ff45f9f2d26d4f28a04b67b7f21156af_Out_0_Vector2 = Vector2_561adb05ccbe422385d36f62fe07de5a;
            float2 _Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ff45f9f2d26d4f28a04b67b7f21156af_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2);
            float4 _UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4 = IN.uv0;
            float2 _Property_d7db6a2a1ca441cd920f74045d698b5e_Out_0_Vector2 = Vector2_67044496c8bb4ceb927c5010101e399e;
            float2 _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_d7db6a2a1ca441cd920f74045d698b5e_Out_0_Vector2, _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2);
            float2 _Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2;
            Unity_Add_float2((_UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4.xy), _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2, _Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2);
            float _Property_87139ddd2a244dfe921ca9eab37a9025_Out_0_Float = Vector1_168473e68d2b441294f91d3bce874b84;
            float _GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2, _Property_87139ddd2a244dfe921ca9eab37a9025_Out_0_Float, _GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float);
            float _Property_08e2ca1bf5b24fe58e91d45de93cbbf7_Out_0_Float = Vector1_df3a63b233b3492c9587c46f23cab5e7;
            float4 _Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4;
            Unity_Lerp_float4(_UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4, (_GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float.xxxx), (_Property_08e2ca1bf5b24fe58e91d45de93cbbf7_Out_0_Float.xxxx), _Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4);
            float2 _Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2;
            Unity_Add_float2(_Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2, (_Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4.xy), _Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2);
            float4 _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.tex, _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.samplerstate, _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.GetTransformedUV(_Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2) );
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_R_4_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.r;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_G_5_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.g;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_B_6_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.b;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_A_7_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.a;
            float4 _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4, _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4, _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4);
            float4 _Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_e1b7b98f7c334786a00ef2d2dd0c7210_Out_0_Vector4, _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4, _Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4);
            float4 _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4, IN.VertexColor, _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4);
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_R_1_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[0];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_G_2_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[1];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_B_3_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[2];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_A_4_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[3];
            surface.Alpha = _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_A_4_Float;
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
        Cull Off
        Blend SrcAlpha One, One One
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
        float4 Color_8d5a5550e5e247dc8fee637c322ecc9a;
        float4 Texture2D_820708fcff4644f3b3da6bdd009d7eb9_TexelSize;
        float4 Texture2D_a2e457d6a8724b7f908d707eef5a1ae9_TexelSize;
        float2 Vector2_561adb05ccbe422385d36f62fe07de5a;
        float2 Vector2_67044496c8bb4ceb927c5010101e399e;
        float Vector1_168473e68d2b441294f91d3bce874b84;
        float Vector1_df3a63b233b3492c9587c46f23cab5e7;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_820708fcff4644f3b3da6bdd009d7eb9);
        SAMPLER(samplerTexture2D_820708fcff4644f3b3da6bdd009d7eb9);
        TEXTURE2D(Texture2D_a2e457d6a8724b7f908d707eef5a1ae9);
        SAMPLER(samplerTexture2D_a2e457d6a8724b7f908d707eef5a1ae9);
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
        {
            float x; Hash_LegacyMod_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
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
            float4 _Property_e1b7b98f7c334786a00ef2d2dd0c7210_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(Color_8d5a5550e5e247dc8fee637c322ecc9a) : Color_8d5a5550e5e247dc8fee637c322ecc9a;
            UnityTexture2D _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_a2e457d6a8724b7f908d707eef5a1ae9);
            float4 _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.tex, _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.samplerstate, _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_R_4_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.r;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_G_5_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.g;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_B_6_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.b;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_A_7_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.a;
            UnityTexture2D _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_820708fcff4644f3b3da6bdd009d7eb9);
            float2 _Property_ff45f9f2d26d4f28a04b67b7f21156af_Out_0_Vector2 = Vector2_561adb05ccbe422385d36f62fe07de5a;
            float2 _Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ff45f9f2d26d4f28a04b67b7f21156af_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2);
            float4 _UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4 = IN.uv0;
            float2 _Property_d7db6a2a1ca441cd920f74045d698b5e_Out_0_Vector2 = Vector2_67044496c8bb4ceb927c5010101e399e;
            float2 _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_d7db6a2a1ca441cd920f74045d698b5e_Out_0_Vector2, _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2);
            float2 _Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2;
            Unity_Add_float2((_UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4.xy), _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2, _Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2);
            float _Property_87139ddd2a244dfe921ca9eab37a9025_Out_0_Float = Vector1_168473e68d2b441294f91d3bce874b84;
            float _GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2, _Property_87139ddd2a244dfe921ca9eab37a9025_Out_0_Float, _GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float);
            float _Property_08e2ca1bf5b24fe58e91d45de93cbbf7_Out_0_Float = Vector1_df3a63b233b3492c9587c46f23cab5e7;
            float4 _Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4;
            Unity_Lerp_float4(_UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4, (_GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float.xxxx), (_Property_08e2ca1bf5b24fe58e91d45de93cbbf7_Out_0_Float.xxxx), _Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4);
            float2 _Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2;
            Unity_Add_float2(_Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2, (_Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4.xy), _Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2);
            float4 _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.tex, _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.samplerstate, _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.GetTransformedUV(_Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2) );
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_R_4_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.r;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_G_5_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.g;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_B_6_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.b;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_A_7_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.a;
            float4 _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4, _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4, _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4);
            float4 _Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_e1b7b98f7c334786a00ef2d2dd0c7210_Out_0_Vector4, _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4, _Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4);
            float4 _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4, IN.VertexColor, _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4);
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_R_1_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[0];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_G_2_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[1];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_B_3_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[2];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_A_4_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[3];
            surface.BaseColor = (_Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4.xyz);
            surface.Alpha = _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_A_4_Float;
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
        float4 Color_8d5a5550e5e247dc8fee637c322ecc9a;
        float4 Texture2D_820708fcff4644f3b3da6bdd009d7eb9_TexelSize;
        float4 Texture2D_a2e457d6a8724b7f908d707eef5a1ae9_TexelSize;
        float2 Vector2_561adb05ccbe422385d36f62fe07de5a;
        float2 Vector2_67044496c8bb4ceb927c5010101e399e;
        float Vector1_168473e68d2b441294f91d3bce874b84;
        float Vector1_df3a63b233b3492c9587c46f23cab5e7;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_820708fcff4644f3b3da6bdd009d7eb9);
        SAMPLER(samplerTexture2D_820708fcff4644f3b3da6bdd009d7eb9);
        TEXTURE2D(Texture2D_a2e457d6a8724b7f908d707eef5a1ae9);
        SAMPLER(samplerTexture2D_a2e457d6a8724b7f908d707eef5a1ae9);
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
        {
            float x; Hash_LegacyMod_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
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
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_e1b7b98f7c334786a00ef2d2dd0c7210_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(Color_8d5a5550e5e247dc8fee637c322ecc9a) : Color_8d5a5550e5e247dc8fee637c322ecc9a;
            UnityTexture2D _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_a2e457d6a8724b7f908d707eef5a1ae9);
            float4 _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.tex, _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.samplerstate, _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_R_4_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.r;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_G_5_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.g;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_B_6_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.b;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_A_7_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.a;
            UnityTexture2D _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_820708fcff4644f3b3da6bdd009d7eb9);
            float2 _Property_ff45f9f2d26d4f28a04b67b7f21156af_Out_0_Vector2 = Vector2_561adb05ccbe422385d36f62fe07de5a;
            float2 _Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ff45f9f2d26d4f28a04b67b7f21156af_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2);
            float4 _UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4 = IN.uv0;
            float2 _Property_d7db6a2a1ca441cd920f74045d698b5e_Out_0_Vector2 = Vector2_67044496c8bb4ceb927c5010101e399e;
            float2 _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_d7db6a2a1ca441cd920f74045d698b5e_Out_0_Vector2, _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2);
            float2 _Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2;
            Unity_Add_float2((_UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4.xy), _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2, _Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2);
            float _Property_87139ddd2a244dfe921ca9eab37a9025_Out_0_Float = Vector1_168473e68d2b441294f91d3bce874b84;
            float _GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2, _Property_87139ddd2a244dfe921ca9eab37a9025_Out_0_Float, _GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float);
            float _Property_08e2ca1bf5b24fe58e91d45de93cbbf7_Out_0_Float = Vector1_df3a63b233b3492c9587c46f23cab5e7;
            float4 _Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4;
            Unity_Lerp_float4(_UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4, (_GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float.xxxx), (_Property_08e2ca1bf5b24fe58e91d45de93cbbf7_Out_0_Float.xxxx), _Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4);
            float2 _Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2;
            Unity_Add_float2(_Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2, (_Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4.xy), _Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2);
            float4 _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.tex, _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.samplerstate, _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.GetTransformedUV(_Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2) );
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_R_4_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.r;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_G_5_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.g;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_B_6_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.b;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_A_7_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.a;
            float4 _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4, _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4, _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4);
            float4 _Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_e1b7b98f7c334786a00ef2d2dd0c7210_Out_0_Vector4, _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4, _Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4);
            float4 _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4, IN.VertexColor, _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4);
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_R_1_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[0];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_G_2_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[1];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_B_3_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[2];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_A_4_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[3];
            surface.Alpha = _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_A_4_Float;
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
        float4 Color_8d5a5550e5e247dc8fee637c322ecc9a;
        float4 Texture2D_820708fcff4644f3b3da6bdd009d7eb9_TexelSize;
        float4 Texture2D_a2e457d6a8724b7f908d707eef5a1ae9_TexelSize;
        float2 Vector2_561adb05ccbe422385d36f62fe07de5a;
        float2 Vector2_67044496c8bb4ceb927c5010101e399e;
        float Vector1_168473e68d2b441294f91d3bce874b84;
        float Vector1_df3a63b233b3492c9587c46f23cab5e7;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_820708fcff4644f3b3da6bdd009d7eb9);
        SAMPLER(samplerTexture2D_820708fcff4644f3b3da6bdd009d7eb9);
        TEXTURE2D(Texture2D_a2e457d6a8724b7f908d707eef5a1ae9);
        SAMPLER(samplerTexture2D_a2e457d6a8724b7f908d707eef5a1ae9);
        
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
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
        {
            float x; Hash_LegacyMod_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_LegacyMod_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
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
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_e1b7b98f7c334786a00ef2d2dd0c7210_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(Color_8d5a5550e5e247dc8fee637c322ecc9a) : Color_8d5a5550e5e247dc8fee637c322ecc9a;
            UnityTexture2D _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_a2e457d6a8724b7f908d707eef5a1ae9);
            float4 _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.tex, _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.samplerstate, _Property_bc77950b18d849e6839e55828f9ade2a_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_R_4_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.r;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_G_5_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.g;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_B_6_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.b;
            float _SampleTexture2D_54209ce7385940afafb583adbaef6197_A_7_Float = _SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4.a;
            UnityTexture2D _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(Texture2D_820708fcff4644f3b3da6bdd009d7eb9);
            float2 _Property_ff45f9f2d26d4f28a04b67b7f21156af_Out_0_Vector2 = Vector2_561adb05ccbe422385d36f62fe07de5a;
            float2 _Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2;
            Unity_Multiply_float2_float2(_Property_ff45f9f2d26d4f28a04b67b7f21156af_Out_0_Vector2, (IN.TimeParameters.x.xx), _Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2);
            float4 _UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4 = IN.uv0;
            float2 _Property_d7db6a2a1ca441cd920f74045d698b5e_Out_0_Vector2 = Vector2_67044496c8bb4ceb927c5010101e399e;
            float2 _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Property_d7db6a2a1ca441cd920f74045d698b5e_Out_0_Vector2, _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2);
            float2 _Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2;
            Unity_Add_float2((_UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4.xy), _Multiply_5e53bb1040a3417ca59b953e39c31962_Out_2_Vector2, _Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2);
            float _Property_87139ddd2a244dfe921ca9eab37a9025_Out_0_Float = Vector1_168473e68d2b441294f91d3bce874b84;
            float _GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float;
            Unity_GradientNoise_LegacyMod_float(_Add_79d0876c375b4e6d98bfb3b67082db74_Out_2_Vector2, _Property_87139ddd2a244dfe921ca9eab37a9025_Out_0_Float, _GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float);
            float _Property_08e2ca1bf5b24fe58e91d45de93cbbf7_Out_0_Float = Vector1_df3a63b233b3492c9587c46f23cab5e7;
            float4 _Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4;
            Unity_Lerp_float4(_UV_fc290ffe195f4be7ad50089fcc68f575_Out_0_Vector4, (_GradientNoise_d9ce6aede0754f968be1a6b508a20733_Out_2_Float.xxxx), (_Property_08e2ca1bf5b24fe58e91d45de93cbbf7_Out_0_Float.xxxx), _Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4);
            float2 _Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2;
            Unity_Add_float2(_Multiply_246c51fbd4c94abbaba4c8dfd08dda5c_Out_2_Vector2, (_Lerp_2d303822dbf44d72a5c879afa820be7f_Out_3_Vector4.xy), _Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2);
            float4 _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.tex, _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.samplerstate, _Property_17a7b28eaabf40c284c92c6bac08f109_Out_0_Texture2D.GetTransformedUV(_Add_ddb61e871acd4d09b0a5e0016028c3c2_Out_2_Vector2) );
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_R_4_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.r;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_G_5_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.g;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_B_6_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.b;
            float _SampleTexture2D_e19e989350f845d396019dca02e83926_A_7_Float = _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4.a;
            float4 _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_54209ce7385940afafb583adbaef6197_RGBA_0_Vector4, _SampleTexture2D_e19e989350f845d396019dca02e83926_RGBA_0_Vector4, _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4);
            float4 _Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_e1b7b98f7c334786a00ef2d2dd0c7210_Out_0_Vector4, _Multiply_fc64c3ec019c4da59e729faad05d79e6_Out_2_Vector4, _Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4);
            float4 _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_56eac9b18f7e4200a08d94431cd23639_Out_2_Vector4, IN.VertexColor, _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4);
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_R_1_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[0];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_G_2_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[1];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_B_3_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[2];
            float _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_A_4_Float = _Multiply_4491570c8bf04d238a232a60035a860a_Out_2_Vector4[3];
            surface.Alpha = _Split_9dd0fa2f265042fdb2c7bb92c895d2c9_A_4_Float;
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