Shader "Custom/SRP ArcShader"
{
    Properties
    {
        [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _FillColor("FillColor", Color) = (1, 1, 1, 0.5019608)
        _FillProgress("FillProgress", Range(0, 1)) = 0.5
        _Arc("Arc", Range(0, 1)) = 0
        _Angle("Angle", Range(0, 1)) = 0
        [HideInInspector]_DrawOrder("Draw Order", Range(-50, 50)) = 0
        [HideInInspector][Enum(Depth Bias, 0, View Bias, 1)]_DecalMeshBiasType("DecalMesh BiasType", Float) = 0
        [HideInInspector]_DecalMeshDepthBias("DecalMesh DepthBias", Float) = 0
        [HideInInspector]_DecalMeshViewBias("DecalMesh ViewBias", Float) = 0
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            // RenderType: <None>
            "PreviewType"="Plane"
            // Queue: <None>
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalDecalSubTarget"
        }
        
        ZWrite On
        Stencil
        {
            Ref 1
            Comp always
        }

        Pass
        { 
            Name "DBufferProjector"
            Tags 
            { 
                "LightMode" = "DBufferProjector"
            }
        
            // Render State
            Cull Front
        Blend 0 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
        Blend 1 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
        Blend 2 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
        ZTest Greater
        ZWrite Off
        ColorMask RGBA
        ColorMask RGBA 1
        ColorMask 0 2
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 4.5
        #pragma vertex Vert
        #pragma fragment Frag
        #pragma multi_compile_instancing
        #pragma editor_sync_compilation
        
            // Keywords
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile _ _DECAL_LAYERS
            // GraphKeywords: <None>
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        
            // Defines
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            
            #define HAVE_MESH_MODIFICATION
        
        
            #define SHADERPASS SHADERPASS_DBUFFER_PROJECTOR
        #define _MATERIAL_AFFECTS_ALBEDO 1
        #define _MATERIAL_AFFECTS_NORMAL 1
        #define _MATERIAL_AFFECTS_NORMAL_BLEND 1
        
            // -- Properties used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            #if _RENDER_PASS_ENABLED
            #define GBUFFER3 0
            #define GBUFFER4 1
            FRAMEBUFFER_INPUT_HALF(GBUFFER3);
            FRAMEBUFFER_INPUT_HALF(GBUFFER4);
            #endif
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
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
            struct Attributes
        {
             float3 positionOS : POSITION;
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
             float3 TangentSpaceNormal;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
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
        float4 _MainTex_TexelSize;
        float4 _Color;
        float4 _FillColor;
        float _FillProgress;
        float _Arc;
        float _Angle;
        float _DrawOrder;
        float _DecalMeshBiasType;
        float _DecalMeshDepthBias;
        float _DecalMeshViewBias;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
            // Graph Includes
            // GraphIncludes: <None>
        
            // Graph Functions
            
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void CalculateArcAlpha_float(float2 offset, out float arcAlpha){
            arcAlpha = offset.x == 0 || offset.y == 0 ? 0 : atan2(offset.y, offset.x);
        }
        
        void CalculateNormalizedAngle_float(float arcAlpha, float _Angle, float _Arc, float UNITY_PI, out float normalizedAngle){
            normalizedAngle = fmod((arcAlpha / UNITY_PI + 1) / 2 + _Angle + _Arc / 2, 1);
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_ColorspaceConversion_Linear_RGB_float(float3 In, out float3 Out)
        {
            float3 sRGBLo = In * 12.92;
            float3 sRGBHi = (pow(max(abs(In), 1.192092896e-07), float3(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - 0.055;
            Out = float3(In <= 0.0031308) ? sRGBLo : sRGBHi;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void testpp_float(float normalizedAngle, float Arc, float cutoff, float4 _col, float4 tex_FillColor, out float4 _out){
            float4 t = cutoff == 0 ?  tex_FillColor : _col;
            _out = normalizedAngle > Arc? t : 0;
        }
        
            // Graph Vertex
            struct VertexDescription
        {
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            return description;
        }
            
            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float3 NormalTS;
            float NormalAlpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4 = IN.uv0;
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_R_1_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[0];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_G_2_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[1];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_B_3_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[2];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_A_4_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[3];
            float4 _Combine_2a9559326b8d4a75ac5767989927a856_RGBA_4_Vector4;
            float3 _Combine_2a9559326b8d4a75ac5767989927a856_RGB_5_Vector3;
            float2 _Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2;
            Unity_Combine_float(_Split_9fe8ed71d3074caaad444b9acd6c5f84_R_1_Float, _Split_9fe8ed71d3074caaad444b9acd6c5f84_G_2_Float, float(0), float(0), _Combine_2a9559326b8d4a75ac5767989927a856_RGBA_4_Vector4, _Combine_2a9559326b8d4a75ac5767989927a856_RGB_5_Vector3, _Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2);
            float2 _Vector2_c96385dca6924112a67da2b24d93803d_Out_0_Vector2 = float2(float(0.5), float(0.5));
            float2 _Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2;
            Unity_Subtract_float2(_Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2, _Vector2_c96385dca6924112a67da2b24d93803d_Out_0_Vector2, _Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2);
            float _CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float;
            CalculateArcAlpha_float(_Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2, _CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float);
            float _Property_4ae0ef262d1e4698b37d8aeccf3b315f_Out_0_Float = _Angle;
            float _Property_ebe2d528d315404ea7aa137abeb760e2_Out_0_Float = _Arc;
            float Constant_2c293f9f5c22420092d050d9f942143c = 3.141593;
            float _CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float;
            CalculateNormalizedAngle_float(_CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float, _Property_4ae0ef262d1e4698b37d8aeccf3b315f_Out_0_Float, _Property_ebe2d528d315404ea7aa137abeb760e2_Out_0_Float, Constant_2c293f9f5c22420092d050d9f942143c, _CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float);
            float _Property_6dbc7a50788b4ef583c91a7ea905ca17_Out_0_Float = _Arc;
            float2 _Vector2_9f19db7e33784b5f80d62fab6fa51f01_Out_0_Vector2 = float2(float(0.5), float(0.5));
            float2 _Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2;
            Unity_Subtract_float2((_UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4.xy), _Vector2_9f19db7e33784b5f80d62fab6fa51f01_Out_0_Vector2, _Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2);
            float _Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float;
            Unity_Length_float2(_Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2, _Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float);
            float _Property_5b63f33b34c6422890078b226f715310_Out_0_Float = _FillProgress;
            float _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float;
            Unity_Divide_float(_Property_5b63f33b34c6422890078b226f715310_Out_0_Float, float(2), _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float);
            float _Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float, _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float, _Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean);
            float _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float;
            Unity_Branch_float(_Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean, float(1), float(0), _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float);
            float4 _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4 = _Color;
            float3 _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3;
            Unity_ColorspaceConversion_Linear_RGB_float((_Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4.xyz), _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3);
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_R_1_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[0];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_G_2_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[1];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_B_3_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[2];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_A_4_Float = 0;
            float _Split_56f1bf897d644b998118593cdc2539b5_R_1_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[0];
            float _Split_56f1bf897d644b998118593cdc2539b5_G_2_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[1];
            float _Split_56f1bf897d644b998118593cdc2539b5_B_3_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[2];
            float _Split_56f1bf897d644b998118593cdc2539b5_A_4_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[3];
            float4 _Vector4_463dad429f4a4a69843e69e8e1292aa7_Out_0_Vector4 = float4(_Split_b3757f81924a4eb985ebd6e1d241ab57_R_1_Float, _Split_b3757f81924a4eb985ebd6e1d241ab57_G_2_Float, _Split_b3757f81924a4eb985ebd6e1d241ab57_B_3_Float, _Split_56f1bf897d644b998118593cdc2539b5_A_4_Float);
            UnityTexture2D _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.tex, _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.samplerstate, _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_R_4_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.r;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_G_5_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.g;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_B_6_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.b;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_A_7_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.a;
            float4 _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Vector4_463dad429f4a4a69843e69e8e1292aa7_Out_0_Vector4, _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4, _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4);
            float4 _Property_03768353dd7743c2888242b70458081d_Out_0_Vector4 = _FillColor;
            float4 _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4, _Property_03768353dd7743c2888242b70458081d_Out_0_Vector4, _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4);
            float4 _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4;
            testpp_float(_CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float, _Property_6dbc7a50788b4ef583c91a7ea905ca17_Out_0_Float, _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float, _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4, _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4, _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4);
            float _Split_398445de4efc474ca65995a62366e687_R_1_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[0];
            float _Split_398445de4efc474ca65995a62366e687_G_2_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[1];
            float _Split_398445de4efc474ca65995a62366e687_B_3_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[2];
            float _Split_398445de4efc474ca65995a62366e687_A_4_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[3];
            surface.BaseColor = (_testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4.xyz);
            surface.Alpha = _Split_398445de4efc474ca65995a62366e687_A_4_Float;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.NormalAlpha = float(1);
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            
        //     $features.graphVertex:  $include("VertexAnimation.template.hlsl")
        //                                       ^ ERROR: $include cannot find file : VertexAnimation.template.hlsl. Looked into:
        // Packages/com.unity.shadergraph/Editor/Generation/Templates
        
            
        //     $features.graphPixel:   $include("SharedCode.template.hlsl")
        //                                       ^ ERROR: $include cannot find file : SharedCode.template.hlsl. Looked into:
        // Packages/com.unity.shadergraph/Editor/Generation/Templates
        
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorCopyToSDI' */
        
        
        
            output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 =                                        input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
            return output;
        }
        
            // --------------------------------------------------
            // Build Surface Data
        
            void GetSurfaceData(Varyings input, float4 positionCS, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                    half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                    float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                    float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                    input.texCoord0.xy = input.texCoord0.xy * scale + offset;
                    half3 normalWS = TransformObjectToWorldDir(half3(0, 1, 0));
                    half3 tangentWS = TransformObjectToWorldDir(half3(1, 0, 0));
                    half3 bitangentWS = TransformObjectToWorldDir(half3(0, 0, 1));
                    half sign = dot(cross(normalWS, tangentWS), bitangentWS) > 0 ? 1 : -1;
                #else
                    #if defined(LOD_FADE_CROSSFADE) && USE_UNITY_CROSSFADE
                        LODFadeCrossFade(positionCS);
                    #endif
        
                    half fadeFactor = half(1.0);
                #endif
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(input);
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
        
                // setup defaults -- these are used if the graph doesn't output a value
                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);
        
                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif
        
        
                // copy across graph values, if defined
                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);
        
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        surfaceData.normalWS.xyz = normalize(mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz));
                    #else
                        surfaceData.normalWS.xyz = normalize(normalToWorld[2].xyz);
                    #endif
                #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        float sgn = input.tangentWS.w;      // should be either +1 or -1
                        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
        
                        // We need to normalize as we use mikkt tangent space and this is expected (tangent space is not normalize)
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                    #else
                        surfaceData.normalWS.xyz = normalize(half3(input.normalWS)); // Default to vertex normal
                    #endif
                #endif
        
                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
        
                // In case of Smoothness / AO / Metal, all the three are always computed but color mask can change
            }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPassDecal.hlsl"
        
            ENDHLSL
        }
        Pass
        { 
            Name "DecalScreenSpaceProjector"
            Tags 
            { 
                "LightMode" = "DecalScreenSpaceProjector"
            }
        
            // Render State
            Cull Front
        Blend SrcAlpha OneMinusSrcAlpha
        ZTest Greater
        ZWrite Off
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 2.5
        #pragma vertex Vert
        #pragma fragment Frag
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma editor_sync_compilation
        
            // Keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
        #pragma multi_compile _ _DECAL_LAYERS
            // GraphKeywords: <None>
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        
            // Defines
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SH
            #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
            #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV
            
            #define HAVE_MESH_MODIFICATION
        
        
            #define SHADERPASS SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR
        #define _MATERIAL_AFFECTS_ALBEDO 1
        #define _MATERIAL_AFFECTS_NORMAL 1
        #define _MATERIAL_AFFECTS_NORMAL_BLEND 1
        
            // -- Properties used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            #if _RENDER_PASS_ENABLED
            #define GBUFFER3 0
            #define GBUFFER4 1
            FRAMEBUFFER_INPUT_HALF(GBUFFER3);
            FRAMEBUFFER_INPUT_HALF(GBUFFER4);
            #endif
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
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
            struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
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
        };
        struct VertexDescriptionInputs
        {
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
             float4 texCoord0 : INTERP3;
             float4 fogFactorAndVertexLight : INTERP4;
             float3 normalWS : INTERP5;
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
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
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
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
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
        float4 _MainTex_TexelSize;
        float4 _Color;
        float4 _FillColor;
        float _FillProgress;
        float _Arc;
        float _Angle;
        float _DrawOrder;
        float _DecalMeshBiasType;
        float _DecalMeshDepthBias;
        float _DecalMeshViewBias;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
            // Graph Includes
            // GraphIncludes: <None>
        
            // Graph Functions
            
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void CalculateArcAlpha_float(float2 offset, out float arcAlpha){
            arcAlpha = offset.x == 0 || offset.y == 0 ? 0 : atan2(offset.y, offset.x);
        }
        
        void CalculateNormalizedAngle_float(float arcAlpha, float _Angle, float _Arc, float UNITY_PI, out float normalizedAngle){
            normalizedAngle = fmod((arcAlpha / UNITY_PI + 1) / 2 + _Angle + _Arc / 2, 1);
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_ColorspaceConversion_Linear_RGB_float(float3 In, out float3 Out)
        {
            float3 sRGBLo = In * 12.92;
            float3 sRGBHi = (pow(max(abs(In), 1.192092896e-07), float3(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - 0.055;
            Out = float3(In <= 0.0031308) ? sRGBLo : sRGBHi;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void testpp_float(float normalizedAngle, float Arc, float cutoff, float4 _col, float4 tex_FillColor, out float4 _out){
            float4 t = cutoff == 0 ?  tex_FillColor : _col;
            _out = normalizedAngle > Arc? t : 0;
        }
        
            // Graph Vertex
            struct VertexDescription
        {
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            return description;
        }
            
            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float3 NormalTS;
            float NormalAlpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4 = IN.uv0;
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_R_1_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[0];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_G_2_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[1];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_B_3_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[2];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_A_4_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[3];
            float4 _Combine_2a9559326b8d4a75ac5767989927a856_RGBA_4_Vector4;
            float3 _Combine_2a9559326b8d4a75ac5767989927a856_RGB_5_Vector3;
            float2 _Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2;
            Unity_Combine_float(_Split_9fe8ed71d3074caaad444b9acd6c5f84_R_1_Float, _Split_9fe8ed71d3074caaad444b9acd6c5f84_G_2_Float, float(0), float(0), _Combine_2a9559326b8d4a75ac5767989927a856_RGBA_4_Vector4, _Combine_2a9559326b8d4a75ac5767989927a856_RGB_5_Vector3, _Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2);
            float2 _Vector2_c96385dca6924112a67da2b24d93803d_Out_0_Vector2 = float2(float(0.5), float(0.5));
            float2 _Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2;
            Unity_Subtract_float2(_Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2, _Vector2_c96385dca6924112a67da2b24d93803d_Out_0_Vector2, _Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2);
            float _CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float;
            CalculateArcAlpha_float(_Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2, _CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float);
            float _Property_4ae0ef262d1e4698b37d8aeccf3b315f_Out_0_Float = _Angle;
            float _Property_ebe2d528d315404ea7aa137abeb760e2_Out_0_Float = _Arc;
            float Constant_2c293f9f5c22420092d050d9f942143c = 3.141593;
            float _CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float;
            CalculateNormalizedAngle_float(_CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float, _Property_4ae0ef262d1e4698b37d8aeccf3b315f_Out_0_Float, _Property_ebe2d528d315404ea7aa137abeb760e2_Out_0_Float, Constant_2c293f9f5c22420092d050d9f942143c, _CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float);
            float _Property_6dbc7a50788b4ef583c91a7ea905ca17_Out_0_Float = _Arc;
            float2 _Vector2_9f19db7e33784b5f80d62fab6fa51f01_Out_0_Vector2 = float2(float(0.5), float(0.5));
            float2 _Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2;
            Unity_Subtract_float2((_UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4.xy), _Vector2_9f19db7e33784b5f80d62fab6fa51f01_Out_0_Vector2, _Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2);
            float _Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float;
            Unity_Length_float2(_Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2, _Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float);
            float _Property_5b63f33b34c6422890078b226f715310_Out_0_Float = _FillProgress;
            float _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float;
            Unity_Divide_float(_Property_5b63f33b34c6422890078b226f715310_Out_0_Float, float(2), _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float);
            float _Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float, _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float, _Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean);
            float _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float;
            Unity_Branch_float(_Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean, float(1), float(0), _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float);
            float4 _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4 = _Color;
            float3 _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3;
            Unity_ColorspaceConversion_Linear_RGB_float((_Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4.xyz), _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3);
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_R_1_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[0];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_G_2_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[1];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_B_3_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[2];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_A_4_Float = 0;
            float _Split_56f1bf897d644b998118593cdc2539b5_R_1_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[0];
            float _Split_56f1bf897d644b998118593cdc2539b5_G_2_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[1];
            float _Split_56f1bf897d644b998118593cdc2539b5_B_3_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[2];
            float _Split_56f1bf897d644b998118593cdc2539b5_A_4_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[3];
            float4 _Vector4_463dad429f4a4a69843e69e8e1292aa7_Out_0_Vector4 = float4(_Split_b3757f81924a4eb985ebd6e1d241ab57_R_1_Float, _Split_b3757f81924a4eb985ebd6e1d241ab57_G_2_Float, _Split_b3757f81924a4eb985ebd6e1d241ab57_B_3_Float, _Split_56f1bf897d644b998118593cdc2539b5_A_4_Float);
            UnityTexture2D _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.tex, _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.samplerstate, _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_R_4_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.r;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_G_5_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.g;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_B_6_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.b;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_A_7_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.a;
            float4 _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Vector4_463dad429f4a4a69843e69e8e1292aa7_Out_0_Vector4, _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4, _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4);
            float4 _Property_03768353dd7743c2888242b70458081d_Out_0_Vector4 = _FillColor;
            float4 _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4, _Property_03768353dd7743c2888242b70458081d_Out_0_Vector4, _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4);
            float4 _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4;
            testpp_float(_CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float, _Property_6dbc7a50788b4ef583c91a7ea905ca17_Out_0_Float, _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float, _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4, _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4, _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4);
            float _Split_398445de4efc474ca65995a62366e687_R_1_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[0];
            float _Split_398445de4efc474ca65995a62366e687_G_2_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[1];
            float _Split_398445de4efc474ca65995a62366e687_B_3_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[2];
            float _Split_398445de4efc474ca65995a62366e687_A_4_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[3];
            surface.BaseColor = (_testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4.xyz);
            surface.Alpha = _Split_398445de4efc474ca65995a62366e687_A_4_Float;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.NormalAlpha = float(1);
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            
        //     $features.graphVertex:  $include("VertexAnimation.template.hlsl")
        //                                       ^ ERROR: $include cannot find file : VertexAnimation.template.hlsl. Looked into:
        // Packages/com.unity.shadergraph/Editor/Generation/Templates
        
            
        //     $features.graphPixel:   $include("SharedCode.template.hlsl")
        //                                       ^ ERROR: $include cannot find file : SharedCode.template.hlsl. Looked into:
        // Packages/com.unity.shadergraph/Editor/Generation/Templates
        
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorCopyToSDI' */
        
        
        
            output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 =                                        input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
            return output;
        }
        
            // --------------------------------------------------
            // Build Surface Data
        
            void GetSurfaceData(Varyings input, float4 positionCS, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                    half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                    float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                    float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                    input.texCoord0.xy = input.texCoord0.xy * scale + offset;
                    half3 normalWS = TransformObjectToWorldDir(half3(0, 1, 0));
                    half3 tangentWS = TransformObjectToWorldDir(half3(1, 0, 0));
                    half3 bitangentWS = TransformObjectToWorldDir(half3(0, 0, 1));
                    half sign = dot(cross(normalWS, tangentWS), bitangentWS) > 0 ? 1 : -1;
                    input.normalWS.xyz = normalWS;
                #else
                    #if defined(LOD_FADE_CROSSFADE) && USE_UNITY_CROSSFADE
                        LODFadeCrossFade(positionCS);
                    #endif
        
                    half fadeFactor = half(1.0);
                #endif
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(input);
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
        
                // setup defaults -- these are used if the graph doesn't output a value
                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);
        
                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif
        
        
                // copy across graph values, if defined
                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);
        
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        surfaceData.normalWS.xyz = normalize(mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz));
                    #else
                        surfaceData.normalWS.xyz = normalize(normalToWorld[2].xyz);
                    #endif
                #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        float sgn = input.tangentWS.w;      // should be either +1 or -1
                        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
        
                        // We need to normalize as we use mikkt tangent space and this is expected (tangent space is not normalize)
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                    #else
                        surfaceData.normalWS.xyz = normalize(half3(input.normalWS)); // Default to vertex normal
                    #endif
                #endif
        
                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
        
                // In case of Smoothness / AO / Metal, all the three are always computed but color mask can change
            }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPassDecal.hlsl"
        
            ENDHLSL
        }
        Pass
        { 
            Name "DecalGBufferProjector"
            Tags 
            { 
                "LightMode" = "DecalGBufferProjector"
            }
        
            // Render State
            Cull Front
        Blend 0 SrcAlpha OneMinusSrcAlpha
        Blend 1 SrcAlpha OneMinusSrcAlpha
        Blend 2 SrcAlpha OneMinusSrcAlpha
        Blend 3 SrcAlpha OneMinusSrcAlpha
        ZTest Greater
        ZWrite Off
        ColorMask RGB
        ColorMask 0 1
        ColorMask RGB 2
        ColorMask RGB 3
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex Vert
        #pragma fragment Frag
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma editor_sync_compilation
        
            // Keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
        #pragma multi_compile _ _DECAL_LAYERS
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
            // GraphKeywords: <None>
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        
            // Defines
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_SH
            #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
            #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV
            
            #define HAVE_MESH_MODIFICATION
        
        
            #define SHADERPASS SHADERPASS_DECAL_GBUFFER_PROJECTOR
        #define _MATERIAL_AFFECTS_ALBEDO 1
        #define _MATERIAL_AFFECTS_NORMAL 1
        #define _MATERIAL_AFFECTS_NORMAL_BLEND 1
        
            // -- Properties used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            #if _RENDER_PASS_ENABLED
            #define GBUFFER3 0
            #define GBUFFER4 1
            FRAMEBUFFER_INPUT_HALF(GBUFFER3);
            FRAMEBUFFER_INPUT_HALF(GBUFFER4);
            #endif
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
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
            struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
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
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
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
             float3 TangentSpaceNormal;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
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
             float4 texCoord0 : INTERP3;
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
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
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
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
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
        float4 _MainTex_TexelSize;
        float4 _Color;
        float4 _FillColor;
        float _FillProgress;
        float _Arc;
        float _Angle;
        float _DrawOrder;
        float _DecalMeshBiasType;
        float _DecalMeshDepthBias;
        float _DecalMeshViewBias;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
            // Graph Includes
            // GraphIncludes: <None>
        
            // Graph Functions
            
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void CalculateArcAlpha_float(float2 offset, out float arcAlpha){
            arcAlpha = offset.x == 0 || offset.y == 0 ? 0 : atan2(offset.y, offset.x);
        }
        
        void CalculateNormalizedAngle_float(float arcAlpha, float _Angle, float _Arc, float UNITY_PI, out float normalizedAngle){
            normalizedAngle = fmod((arcAlpha / UNITY_PI + 1) / 2 + _Angle + _Arc / 2, 1);
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_ColorspaceConversion_Linear_RGB_float(float3 In, out float3 Out)
        {
            float3 sRGBLo = In * 12.92;
            float3 sRGBHi = (pow(max(abs(In), 1.192092896e-07), float3(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - 0.055;
            Out = float3(In <= 0.0031308) ? sRGBLo : sRGBHi;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void testpp_float(float normalizedAngle, float Arc, float cutoff, float4 _col, float4 tex_FillColor, out float4 _out){
            float4 t = cutoff == 0 ?  tex_FillColor : _col;
            _out = normalizedAngle > Arc? t : 0;
        }
        
            // Graph Vertex
            struct VertexDescription
        {
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            return description;
        }
            
            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float3 NormalTS;
            float NormalAlpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4 = IN.uv0;
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_R_1_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[0];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_G_2_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[1];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_B_3_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[2];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_A_4_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[3];
            float4 _Combine_2a9559326b8d4a75ac5767989927a856_RGBA_4_Vector4;
            float3 _Combine_2a9559326b8d4a75ac5767989927a856_RGB_5_Vector3;
            float2 _Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2;
            Unity_Combine_float(_Split_9fe8ed71d3074caaad444b9acd6c5f84_R_1_Float, _Split_9fe8ed71d3074caaad444b9acd6c5f84_G_2_Float, float(0), float(0), _Combine_2a9559326b8d4a75ac5767989927a856_RGBA_4_Vector4, _Combine_2a9559326b8d4a75ac5767989927a856_RGB_5_Vector3, _Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2);
            float2 _Vector2_c96385dca6924112a67da2b24d93803d_Out_0_Vector2 = float2(float(0.5), float(0.5));
            float2 _Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2;
            Unity_Subtract_float2(_Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2, _Vector2_c96385dca6924112a67da2b24d93803d_Out_0_Vector2, _Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2);
            float _CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float;
            CalculateArcAlpha_float(_Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2, _CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float);
            float _Property_4ae0ef262d1e4698b37d8aeccf3b315f_Out_0_Float = _Angle;
            float _Property_ebe2d528d315404ea7aa137abeb760e2_Out_0_Float = _Arc;
            float Constant_2c293f9f5c22420092d050d9f942143c = 3.141593;
            float _CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float;
            CalculateNormalizedAngle_float(_CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float, _Property_4ae0ef262d1e4698b37d8aeccf3b315f_Out_0_Float, _Property_ebe2d528d315404ea7aa137abeb760e2_Out_0_Float, Constant_2c293f9f5c22420092d050d9f942143c, _CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float);
            float _Property_6dbc7a50788b4ef583c91a7ea905ca17_Out_0_Float = _Arc;
            float2 _Vector2_9f19db7e33784b5f80d62fab6fa51f01_Out_0_Vector2 = float2(float(0.5), float(0.5));
            float2 _Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2;
            Unity_Subtract_float2((_UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4.xy), _Vector2_9f19db7e33784b5f80d62fab6fa51f01_Out_0_Vector2, _Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2);
            float _Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float;
            Unity_Length_float2(_Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2, _Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float);
            float _Property_5b63f33b34c6422890078b226f715310_Out_0_Float = _FillProgress;
            float _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float;
            Unity_Divide_float(_Property_5b63f33b34c6422890078b226f715310_Out_0_Float, float(2), _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float);
            float _Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float, _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float, _Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean);
            float _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float;
            Unity_Branch_float(_Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean, float(1), float(0), _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float);
            float4 _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4 = _Color;
            float3 _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3;
            Unity_ColorspaceConversion_Linear_RGB_float((_Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4.xyz), _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3);
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_R_1_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[0];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_G_2_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[1];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_B_3_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[2];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_A_4_Float = 0;
            float _Split_56f1bf897d644b998118593cdc2539b5_R_1_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[0];
            float _Split_56f1bf897d644b998118593cdc2539b5_G_2_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[1];
            float _Split_56f1bf897d644b998118593cdc2539b5_B_3_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[2];
            float _Split_56f1bf897d644b998118593cdc2539b5_A_4_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[3];
            float4 _Vector4_463dad429f4a4a69843e69e8e1292aa7_Out_0_Vector4 = float4(_Split_b3757f81924a4eb985ebd6e1d241ab57_R_1_Float, _Split_b3757f81924a4eb985ebd6e1d241ab57_G_2_Float, _Split_b3757f81924a4eb985ebd6e1d241ab57_B_3_Float, _Split_56f1bf897d644b998118593cdc2539b5_A_4_Float);
            UnityTexture2D _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.tex, _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.samplerstate, _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_R_4_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.r;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_G_5_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.g;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_B_6_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.b;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_A_7_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.a;
            float4 _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Vector4_463dad429f4a4a69843e69e8e1292aa7_Out_0_Vector4, _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4, _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4);
            float4 _Property_03768353dd7743c2888242b70458081d_Out_0_Vector4 = _FillColor;
            float4 _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4, _Property_03768353dd7743c2888242b70458081d_Out_0_Vector4, _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4);
            float4 _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4;
            testpp_float(_CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float, _Property_6dbc7a50788b4ef583c91a7ea905ca17_Out_0_Float, _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float, _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4, _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4, _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4);
            float _Split_398445de4efc474ca65995a62366e687_R_1_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[0];
            float _Split_398445de4efc474ca65995a62366e687_G_2_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[1];
            float _Split_398445de4efc474ca65995a62366e687_B_3_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[2];
            float _Split_398445de4efc474ca65995a62366e687_A_4_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[3];
            surface.BaseColor = (_testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4.xyz);
            surface.Alpha = _Split_398445de4efc474ca65995a62366e687_A_4_Float;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.NormalAlpha = float(1);
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            
        //     $features.graphVertex:  $include("VertexAnimation.template.hlsl")
        //                                       ^ ERROR: $include cannot find file : VertexAnimation.template.hlsl. Looked into:
        // Packages/com.unity.shadergraph/Editor/Generation/Templates
        
            
        //     $features.graphPixel:   $include("SharedCode.template.hlsl")
        //                                       ^ ERROR: $include cannot find file : SharedCode.template.hlsl. Looked into:
        // Packages/com.unity.shadergraph/Editor/Generation/Templates
        
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorCopyToSDI' */
        
        
        
            output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 =                                        input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
            return output;
        }
        
            // --------------------------------------------------
            // Build Surface Data
        
            void GetSurfaceData(Varyings input, float4 positionCS, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                    half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                    float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                    float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                    input.texCoord0.xy = input.texCoord0.xy * scale + offset;
                    half3 normalWS = TransformObjectToWorldDir(half3(0, 1, 0));
                    half3 tangentWS = TransformObjectToWorldDir(half3(1, 0, 0));
                    half3 bitangentWS = TransformObjectToWorldDir(half3(0, 0, 1));
                    half sign = dot(cross(normalWS, tangentWS), bitangentWS) > 0 ? 1 : -1;
                    input.normalWS.xyz = normalWS;
                #else
                    #if defined(LOD_FADE_CROSSFADE) && USE_UNITY_CROSSFADE
                        LODFadeCrossFade(positionCS);
                    #endif
        
                    half fadeFactor = half(1.0);
                #endif
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(input);
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
        
                // setup defaults -- these are used if the graph doesn't output a value
                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);
        
                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif
        
        
                // copy across graph values, if defined
                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);
        
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        surfaceData.normalWS.xyz = normalize(mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz));
                    #else
                        surfaceData.normalWS.xyz = normalize(normalToWorld[2].xyz);
                    #endif
                #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        float sgn = input.tangentWS.w;      // should be either +1 or -1
                        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
        
                        // We need to normalize as we use mikkt tangent space and this is expected (tangent space is not normalize)
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                    #else
                        surfaceData.normalWS.xyz = normalize(half3(input.normalWS)); // Default to vertex normal
                    #endif
                #endif
        
                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
        
                // In case of Smoothness / AO / Metal, all the three are always computed but color mask can change
            }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPassDecal.hlsl"
        
            ENDHLSL
        }
        Pass
        { 
            Name "DBufferMesh"
            Tags 
            { 
                "LightMode" = "DBufferMesh"
            }
        
            // Render State
            Blend 0 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
        Blend 1 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
        Blend 2 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        ColorMask RGBA
        ColorMask RGBA 1
        ColorMask 0 2
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 4.5
        #pragma vertex Vert
        #pragma fragment Frag
        #pragma multi_compile_instancing
        #pragma editor_sync_compilation
        
            // Keywords
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile _ _DECAL_LAYERS
            // GraphKeywords: <None>
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        
            // Defines
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            
            #define HAVE_MESH_MODIFICATION
        
        
            #define SHADERPASS SHADERPASS_DBUFFER_MESH
        #define _MATERIAL_AFFECTS_ALBEDO 1
        #define _MATERIAL_AFFECTS_NORMAL 1
        #define _MATERIAL_AFFECTS_NORMAL_BLEND 1
        
            // -- Properties used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            #if _RENDER_PASS_ENABLED
            #define GBUFFER3 0
            #define GBUFFER4 1
            FRAMEBUFFER_INPUT_HALF(GBUFFER3);
            FRAMEBUFFER_INPUT_HALF(GBUFFER4);
            #endif
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
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
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
        };
        struct VertexDescriptionInputs
        {
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
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
            output.tangentWS.xyzw = input.tangentWS;
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
            output.tangentWS = input.tangentWS.xyzw;
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
        float4 _MainTex_TexelSize;
        float4 _Color;
        float4 _FillColor;
        float _FillProgress;
        float _Arc;
        float _Angle;
        float _DrawOrder;
        float _DecalMeshBiasType;
        float _DecalMeshDepthBias;
        float _DecalMeshViewBias;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
            // Graph Includes
            // GraphIncludes: <None>
        
            // Graph Functions
            
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void CalculateArcAlpha_float(float2 offset, out float arcAlpha){
            arcAlpha = offset.x == 0 || offset.y == 0 ? 0 : atan2(offset.y, offset.x);
        }
        
        void CalculateNormalizedAngle_float(float arcAlpha, float _Angle, float _Arc, float UNITY_PI, out float normalizedAngle){
            normalizedAngle = fmod((arcAlpha / UNITY_PI + 1) / 2 + _Angle + _Arc / 2, 1);
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_ColorspaceConversion_Linear_RGB_float(float3 In, out float3 Out)
        {
            float3 sRGBLo = In * 12.92;
            float3 sRGBHi = (pow(max(abs(In), 1.192092896e-07), float3(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - 0.055;
            Out = float3(In <= 0.0031308) ? sRGBLo : sRGBHi;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void testpp_float(float normalizedAngle, float Arc, float cutoff, float4 _col, float4 tex_FillColor, out float4 _out){
            float4 t = cutoff == 0 ?  tex_FillColor : _col;
            _out = normalizedAngle > Arc? t : 0;
        }
        
            // Graph Vertex
            struct VertexDescription
        {
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            return description;
        }
            
            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float3 NormalTS;
            float NormalAlpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4 = IN.uv0;
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_R_1_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[0];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_G_2_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[1];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_B_3_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[2];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_A_4_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[3];
            float4 _Combine_2a9559326b8d4a75ac5767989927a856_RGBA_4_Vector4;
            float3 _Combine_2a9559326b8d4a75ac5767989927a856_RGB_5_Vector3;
            float2 _Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2;
            Unity_Combine_float(_Split_9fe8ed71d3074caaad444b9acd6c5f84_R_1_Float, _Split_9fe8ed71d3074caaad444b9acd6c5f84_G_2_Float, float(0), float(0), _Combine_2a9559326b8d4a75ac5767989927a856_RGBA_4_Vector4, _Combine_2a9559326b8d4a75ac5767989927a856_RGB_5_Vector3, _Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2);
            float2 _Vector2_c96385dca6924112a67da2b24d93803d_Out_0_Vector2 = float2(float(0.5), float(0.5));
            float2 _Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2;
            Unity_Subtract_float2(_Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2, _Vector2_c96385dca6924112a67da2b24d93803d_Out_0_Vector2, _Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2);
            float _CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float;
            CalculateArcAlpha_float(_Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2, _CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float);
            float _Property_4ae0ef262d1e4698b37d8aeccf3b315f_Out_0_Float = _Angle;
            float _Property_ebe2d528d315404ea7aa137abeb760e2_Out_0_Float = _Arc;
            float Constant_2c293f9f5c22420092d050d9f942143c = 3.141593;
            float _CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float;
            CalculateNormalizedAngle_float(_CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float, _Property_4ae0ef262d1e4698b37d8aeccf3b315f_Out_0_Float, _Property_ebe2d528d315404ea7aa137abeb760e2_Out_0_Float, Constant_2c293f9f5c22420092d050d9f942143c, _CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float);
            float _Property_6dbc7a50788b4ef583c91a7ea905ca17_Out_0_Float = _Arc;
            float2 _Vector2_9f19db7e33784b5f80d62fab6fa51f01_Out_0_Vector2 = float2(float(0.5), float(0.5));
            float2 _Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2;
            Unity_Subtract_float2((_UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4.xy), _Vector2_9f19db7e33784b5f80d62fab6fa51f01_Out_0_Vector2, _Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2);
            float _Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float;
            Unity_Length_float2(_Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2, _Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float);
            float _Property_5b63f33b34c6422890078b226f715310_Out_0_Float = _FillProgress;
            float _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float;
            Unity_Divide_float(_Property_5b63f33b34c6422890078b226f715310_Out_0_Float, float(2), _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float);
            float _Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float, _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float, _Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean);
            float _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float;
            Unity_Branch_float(_Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean, float(1), float(0), _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float);
            float4 _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4 = _Color;
            float3 _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3;
            Unity_ColorspaceConversion_Linear_RGB_float((_Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4.xyz), _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3);
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_R_1_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[0];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_G_2_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[1];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_B_3_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[2];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_A_4_Float = 0;
            float _Split_56f1bf897d644b998118593cdc2539b5_R_1_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[0];
            float _Split_56f1bf897d644b998118593cdc2539b5_G_2_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[1];
            float _Split_56f1bf897d644b998118593cdc2539b5_B_3_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[2];
            float _Split_56f1bf897d644b998118593cdc2539b5_A_4_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[3];
            float4 _Vector4_463dad429f4a4a69843e69e8e1292aa7_Out_0_Vector4 = float4(_Split_b3757f81924a4eb985ebd6e1d241ab57_R_1_Float, _Split_b3757f81924a4eb985ebd6e1d241ab57_G_2_Float, _Split_b3757f81924a4eb985ebd6e1d241ab57_B_3_Float, _Split_56f1bf897d644b998118593cdc2539b5_A_4_Float);
            UnityTexture2D _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.tex, _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.samplerstate, _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_R_4_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.r;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_G_5_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.g;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_B_6_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.b;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_A_7_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.a;
            float4 _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Vector4_463dad429f4a4a69843e69e8e1292aa7_Out_0_Vector4, _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4, _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4);
            float4 _Property_03768353dd7743c2888242b70458081d_Out_0_Vector4 = _FillColor;
            float4 _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4, _Property_03768353dd7743c2888242b70458081d_Out_0_Vector4, _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4);
            float4 _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4;
            testpp_float(_CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float, _Property_6dbc7a50788b4ef583c91a7ea905ca17_Out_0_Float, _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float, _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4, _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4, _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4);
            float _Split_398445de4efc474ca65995a62366e687_R_1_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[0];
            float _Split_398445de4efc474ca65995a62366e687_G_2_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[1];
            float _Split_398445de4efc474ca65995a62366e687_B_3_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[2];
            float _Split_398445de4efc474ca65995a62366e687_A_4_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[3];
            surface.BaseColor = (_testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4.xyz);
            surface.Alpha = _Split_398445de4efc474ca65995a62366e687_A_4_Float;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.NormalAlpha = float(1);
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            
        //     $features.graphVertex:  $include("VertexAnimation.template.hlsl")
        //                                       ^ ERROR: $include cannot find file : VertexAnimation.template.hlsl. Looked into:
        // Packages/com.unity.shadergraph/Editor/Generation/Templates
        
            
        //     $features.graphPixel:   $include("SharedCode.template.hlsl")
        //                                       ^ ERROR: $include cannot find file : SharedCode.template.hlsl. Looked into:
        // Packages/com.unity.shadergraph/Editor/Generation/Templates
        
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorCopyToSDI' */
        
        
        
            output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 =                                        input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
            return output;
        }
        
            // --------------------------------------------------
            // Build Surface Data
        
            void GetSurfaceData(Varyings input, float4 positionCS, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                    half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                    float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                    float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                    input.texCoord0.xy = input.texCoord0.xy * scale + offset;
                    half3 normalWS = TransformObjectToWorldDir(half3(0, 1, 0));
                    half3 tangentWS = TransformObjectToWorldDir(half3(1, 0, 0));
                    half3 bitangentWS = TransformObjectToWorldDir(half3(0, 0, 1));
                    half sign = dot(cross(normalWS, tangentWS), bitangentWS) > 0 ? 1 : -1;
                    input.normalWS.xyz = normalWS;
                    input.tangentWS.xyzw = half4(tangentWS, sign);
                #else
                    #if defined(LOD_FADE_CROSSFADE) && USE_UNITY_CROSSFADE
                        LODFadeCrossFade(positionCS);
                    #endif
        
                    half fadeFactor = half(1.0);
                #endif
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(input);
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
        
                // setup defaults -- these are used if the graph doesn't output a value
                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);
        
                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif
        
        
                // copy across graph values, if defined
                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);
        
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        surfaceData.normalWS.xyz = normalize(mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz));
                    #else
                        surfaceData.normalWS.xyz = normalize(normalToWorld[2].xyz);
                    #endif
                #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        float sgn = input.tangentWS.w;      // should be either +1 or -1
                        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
        
                        // We need to normalize as we use mikkt tangent space and this is expected (tangent space is not normalize)
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                    #else
                        surfaceData.normalWS.xyz = normalize(half3(input.normalWS)); // Default to vertex normal
                    #endif
                #endif
        
                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
        
                // In case of Smoothness / AO / Metal, all the three are always computed but color mask can change
            }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPassDecal.hlsl"
        
            ENDHLSL
        }
        Pass
        { 
            Name "DecalScreenSpaceMesh"
            Tags 
            { 
                "LightMode" = "DecalScreenSpaceMesh"
            }
        
            // Render State
            Blend SrcAlpha OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 2.5
        #pragma vertex Vert
        #pragma fragment Frag
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma editor_sync_compilation
        
            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
        #pragma multi_compile _ _DECAL_LAYERS
            // GraphKeywords: <None>
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        
            // Defines
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
            #define VARYINGS_NEED_SH
            #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
            #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV
            
            #define HAVE_MESH_MODIFICATION
        
        
            #define SHADERPASS SHADERPASS_DECAL_SCREEN_SPACE_MESH
        #define _MATERIAL_AFFECTS_ALBEDO 1
        #define _MATERIAL_AFFECTS_NORMAL 1
        #define _MATERIAL_AFFECTS_NORMAL_BLEND 1
        
            // -- Properties used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            #if _RENDER_PASS_ENABLED
            #define GBUFFER3 0
            #define GBUFFER4 1
            FRAMEBUFFER_INPUT_HALF(GBUFFER3);
            FRAMEBUFFER_INPUT_HALF(GBUFFER4);
            #endif
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
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
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
        };
        struct VertexDescriptionInputs
        {
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
             float4 tangentWS : INTERP3;
             float4 texCoord0 : INTERP4;
             float4 fogFactorAndVertexLight : INTERP5;
             float3 positionWS : INTERP6;
             float3 normalWS : INTERP7;
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
        float4 _MainTex_TexelSize;
        float4 _Color;
        float4 _FillColor;
        float _FillProgress;
        float _Arc;
        float _Angle;
        float _DrawOrder;
        float _DecalMeshBiasType;
        float _DecalMeshDepthBias;
        float _DecalMeshViewBias;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
            // Graph Includes
            // GraphIncludes: <None>
        
            // Graph Functions
            
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void CalculateArcAlpha_float(float2 offset, out float arcAlpha){
            arcAlpha = offset.x == 0 || offset.y == 0 ? 0 : atan2(offset.y, offset.x);
        }
        
        void CalculateNormalizedAngle_float(float arcAlpha, float _Angle, float _Arc, float UNITY_PI, out float normalizedAngle){
            normalizedAngle = fmod((arcAlpha / UNITY_PI + 1) / 2 + _Angle + _Arc / 2, 1);
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_ColorspaceConversion_Linear_RGB_float(float3 In, out float3 Out)
        {
            float3 sRGBLo = In * 12.92;
            float3 sRGBHi = (pow(max(abs(In), 1.192092896e-07), float3(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - 0.055;
            Out = float3(In <= 0.0031308) ? sRGBLo : sRGBHi;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void testpp_float(float normalizedAngle, float Arc, float cutoff, float4 _col, float4 tex_FillColor, out float4 _out){
            float4 t = cutoff == 0 ?  tex_FillColor : _col;
            _out = normalizedAngle > Arc? t : 0;
        }
        
            // Graph Vertex
            struct VertexDescription
        {
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            return description;
        }
            
            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float3 NormalTS;
            float NormalAlpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4 = IN.uv0;
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_R_1_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[0];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_G_2_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[1];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_B_3_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[2];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_A_4_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[3];
            float4 _Combine_2a9559326b8d4a75ac5767989927a856_RGBA_4_Vector4;
            float3 _Combine_2a9559326b8d4a75ac5767989927a856_RGB_5_Vector3;
            float2 _Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2;
            Unity_Combine_float(_Split_9fe8ed71d3074caaad444b9acd6c5f84_R_1_Float, _Split_9fe8ed71d3074caaad444b9acd6c5f84_G_2_Float, float(0), float(0), _Combine_2a9559326b8d4a75ac5767989927a856_RGBA_4_Vector4, _Combine_2a9559326b8d4a75ac5767989927a856_RGB_5_Vector3, _Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2);
            float2 _Vector2_c96385dca6924112a67da2b24d93803d_Out_0_Vector2 = float2(float(0.5), float(0.5));
            float2 _Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2;
            Unity_Subtract_float2(_Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2, _Vector2_c96385dca6924112a67da2b24d93803d_Out_0_Vector2, _Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2);
            float _CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float;
            CalculateArcAlpha_float(_Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2, _CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float);
            float _Property_4ae0ef262d1e4698b37d8aeccf3b315f_Out_0_Float = _Angle;
            float _Property_ebe2d528d315404ea7aa137abeb760e2_Out_0_Float = _Arc;
            float Constant_2c293f9f5c22420092d050d9f942143c = 3.141593;
            float _CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float;
            CalculateNormalizedAngle_float(_CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float, _Property_4ae0ef262d1e4698b37d8aeccf3b315f_Out_0_Float, _Property_ebe2d528d315404ea7aa137abeb760e2_Out_0_Float, Constant_2c293f9f5c22420092d050d9f942143c, _CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float);
            float _Property_6dbc7a50788b4ef583c91a7ea905ca17_Out_0_Float = _Arc;
            float2 _Vector2_9f19db7e33784b5f80d62fab6fa51f01_Out_0_Vector2 = float2(float(0.5), float(0.5));
            float2 _Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2;
            Unity_Subtract_float2((_UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4.xy), _Vector2_9f19db7e33784b5f80d62fab6fa51f01_Out_0_Vector2, _Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2);
            float _Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float;
            Unity_Length_float2(_Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2, _Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float);
            float _Property_5b63f33b34c6422890078b226f715310_Out_0_Float = _FillProgress;
            float _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float;
            Unity_Divide_float(_Property_5b63f33b34c6422890078b226f715310_Out_0_Float, float(2), _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float);
            float _Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float, _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float, _Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean);
            float _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float;
            Unity_Branch_float(_Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean, float(1), float(0), _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float);
            float4 _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4 = _Color;
            float3 _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3;
            Unity_ColorspaceConversion_Linear_RGB_float((_Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4.xyz), _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3);
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_R_1_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[0];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_G_2_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[1];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_B_3_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[2];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_A_4_Float = 0;
            float _Split_56f1bf897d644b998118593cdc2539b5_R_1_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[0];
            float _Split_56f1bf897d644b998118593cdc2539b5_G_2_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[1];
            float _Split_56f1bf897d644b998118593cdc2539b5_B_3_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[2];
            float _Split_56f1bf897d644b998118593cdc2539b5_A_4_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[3];
            float4 _Vector4_463dad429f4a4a69843e69e8e1292aa7_Out_0_Vector4 = float4(_Split_b3757f81924a4eb985ebd6e1d241ab57_R_1_Float, _Split_b3757f81924a4eb985ebd6e1d241ab57_G_2_Float, _Split_b3757f81924a4eb985ebd6e1d241ab57_B_3_Float, _Split_56f1bf897d644b998118593cdc2539b5_A_4_Float);
            UnityTexture2D _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.tex, _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.samplerstate, _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_R_4_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.r;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_G_5_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.g;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_B_6_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.b;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_A_7_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.a;
            float4 _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Vector4_463dad429f4a4a69843e69e8e1292aa7_Out_0_Vector4, _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4, _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4);
            float4 _Property_03768353dd7743c2888242b70458081d_Out_0_Vector4 = _FillColor;
            float4 _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4, _Property_03768353dd7743c2888242b70458081d_Out_0_Vector4, _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4);
            float4 _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4;
            testpp_float(_CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float, _Property_6dbc7a50788b4ef583c91a7ea905ca17_Out_0_Float, _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float, _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4, _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4, _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4);
            float _Split_398445de4efc474ca65995a62366e687_R_1_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[0];
            float _Split_398445de4efc474ca65995a62366e687_G_2_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[1];
            float _Split_398445de4efc474ca65995a62366e687_B_3_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[2];
            float _Split_398445de4efc474ca65995a62366e687_A_4_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[3];
            surface.BaseColor = (_testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4.xyz);
            surface.Alpha = _Split_398445de4efc474ca65995a62366e687_A_4_Float;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.NormalAlpha = float(1);
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            
        //     $features.graphVertex:  $include("VertexAnimation.template.hlsl")
        //                                       ^ ERROR: $include cannot find file : VertexAnimation.template.hlsl. Looked into:
        // Packages/com.unity.shadergraph/Editor/Generation/Templates
        
            
        //     $features.graphPixel:   $include("SharedCode.template.hlsl")
        //                                       ^ ERROR: $include cannot find file : SharedCode.template.hlsl. Looked into:
        // Packages/com.unity.shadergraph/Editor/Generation/Templates
        
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorCopyToSDI' */
        
        
        
            output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 =                                        input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
            return output;
        }
        
            // --------------------------------------------------
            // Build Surface Data
        
            void GetSurfaceData(Varyings input, float4 positionCS, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                    half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                    float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                    float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                    input.texCoord0.xy = input.texCoord0.xy * scale + offset;
                    half3 normalWS = TransformObjectToWorldDir(half3(0, 1, 0));
                    half3 tangentWS = TransformObjectToWorldDir(half3(1, 0, 0));
                    half3 bitangentWS = TransformObjectToWorldDir(half3(0, 0, 1));
                    half sign = dot(cross(normalWS, tangentWS), bitangentWS) > 0 ? 1 : -1;
                    input.normalWS.xyz = normalWS;
                    input.tangentWS.xyzw = half4(tangentWS, sign);
                #else
                    #if defined(LOD_FADE_CROSSFADE) && USE_UNITY_CROSSFADE
                        LODFadeCrossFade(positionCS);
                    #endif
        
                    half fadeFactor = half(1.0);
                #endif
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(input);
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
        
                // setup defaults -- these are used if the graph doesn't output a value
                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);
        
                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif
        
        
                // copy across graph values, if defined
                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);
        
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        surfaceData.normalWS.xyz = normalize(mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz));
                    #else
                        surfaceData.normalWS.xyz = normalize(normalToWorld[2].xyz);
                    #endif
                #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        float sgn = input.tangentWS.w;      // should be either +1 or -1
                        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
        
                        // We need to normalize as we use mikkt tangent space and this is expected (tangent space is not normalize)
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                    #else
                        surfaceData.normalWS.xyz = normalize(half3(input.normalWS)); // Default to vertex normal
                    #endif
                #endif
        
                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
        
                // In case of Smoothness / AO / Metal, all the three are always computed but color mask can change
            }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPassDecal.hlsl"
        
            ENDHLSL
        }
        Pass
        { 
            Name "DecalGBufferMesh"
            Tags 
            { 
                "LightMode" = "DecalGBufferMesh"
            }
        
            // Render State
            Blend 0 SrcAlpha OneMinusSrcAlpha
        Blend 1 SrcAlpha OneMinusSrcAlpha
        Blend 2 SrcAlpha OneMinusSrcAlpha
        Blend 3 SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        ColorMask RGB
        ColorMask 0 1
        ColorMask RGB 2
        ColorMask RGB 3
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex Vert
        #pragma fragment Frag
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma editor_sync_compilation
        
            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
        #pragma multi_compile _ _DECAL_LAYERS
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
            // GraphKeywords: <None>
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        
            // Defines
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
            #define VARYINGS_NEED_SH
            #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
            #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV
            
            #define HAVE_MESH_MODIFICATION
        
        
            #define SHADERPASS SHADERPASS_DECAL_GBUFFER_MESH
        #define _MATERIAL_AFFECTS_ALBEDO 1
        #define _MATERIAL_AFFECTS_NORMAL 1
        #define _MATERIAL_AFFECTS_NORMAL_BLEND 1
        
            // -- Properties used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            #if _RENDER_PASS_ENABLED
            #define GBUFFER3 0
            #define GBUFFER4 1
            FRAMEBUFFER_INPUT_HALF(GBUFFER3);
            FRAMEBUFFER_INPUT_HALF(GBUFFER4);
            #endif
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
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
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
        };
        struct VertexDescriptionInputs
        {
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
             float4 tangentWS : INTERP3;
             float4 texCoord0 : INTERP4;
             float4 fogFactorAndVertexLight : INTERP5;
             float3 positionWS : INTERP6;
             float3 normalWS : INTERP7;
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
        float4 _MainTex_TexelSize;
        float4 _Color;
        float4 _FillColor;
        float _FillProgress;
        float _Arc;
        float _Angle;
        float _DrawOrder;
        float _DecalMeshBiasType;
        float _DecalMeshDepthBias;
        float _DecalMeshViewBias;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
            // Graph Includes
            // GraphIncludes: <None>
        
            // Graph Functions
            
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void CalculateArcAlpha_float(float2 offset, out float arcAlpha){
            arcAlpha = offset.x == 0 || offset.y == 0 ? 0 : atan2(offset.y, offset.x);
        }
        
        void CalculateNormalizedAngle_float(float arcAlpha, float _Angle, float _Arc, float UNITY_PI, out float normalizedAngle){
            normalizedAngle = fmod((arcAlpha / UNITY_PI + 1) / 2 + _Angle + _Arc / 2, 1);
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_ColorspaceConversion_Linear_RGB_float(float3 In, out float3 Out)
        {
            float3 sRGBLo = In * 12.92;
            float3 sRGBHi = (pow(max(abs(In), 1.192092896e-07), float3(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - 0.055;
            Out = float3(In <= 0.0031308) ? sRGBLo : sRGBHi;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void testpp_float(float normalizedAngle, float Arc, float cutoff, float4 _col, float4 tex_FillColor, out float4 _out){
            float4 t = cutoff == 0 ?  tex_FillColor : _col;
            _out = normalizedAngle > Arc? t : 0;
        }
        
            // Graph Vertex
            struct VertexDescription
        {
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            return description;
        }
            
            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float3 NormalTS;
            float NormalAlpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4 = IN.uv0;
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_R_1_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[0];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_G_2_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[1];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_B_3_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[2];
            float _Split_9fe8ed71d3074caaad444b9acd6c5f84_A_4_Float = _UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4[3];
            float4 _Combine_2a9559326b8d4a75ac5767989927a856_RGBA_4_Vector4;
            float3 _Combine_2a9559326b8d4a75ac5767989927a856_RGB_5_Vector3;
            float2 _Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2;
            Unity_Combine_float(_Split_9fe8ed71d3074caaad444b9acd6c5f84_R_1_Float, _Split_9fe8ed71d3074caaad444b9acd6c5f84_G_2_Float, float(0), float(0), _Combine_2a9559326b8d4a75ac5767989927a856_RGBA_4_Vector4, _Combine_2a9559326b8d4a75ac5767989927a856_RGB_5_Vector3, _Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2);
            float2 _Vector2_c96385dca6924112a67da2b24d93803d_Out_0_Vector2 = float2(float(0.5), float(0.5));
            float2 _Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2;
            Unity_Subtract_float2(_Combine_2a9559326b8d4a75ac5767989927a856_RG_6_Vector2, _Vector2_c96385dca6924112a67da2b24d93803d_Out_0_Vector2, _Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2);
            float _CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float;
            CalculateArcAlpha_float(_Subtract_8372e621f7334d4c8294be84d1bb5758_Out_2_Vector2, _CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float);
            float _Property_4ae0ef262d1e4698b37d8aeccf3b315f_Out_0_Float = _Angle;
            float _Property_ebe2d528d315404ea7aa137abeb760e2_Out_0_Float = _Arc;
            float Constant_2c293f9f5c22420092d050d9f942143c = 3.141593;
            float _CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float;
            CalculateNormalizedAngle_float(_CalculateArcAlphaCustomFunction_e4ca7bfbf0714f5585d0583929833d0f_arcAlpha_1_Float, _Property_4ae0ef262d1e4698b37d8aeccf3b315f_Out_0_Float, _Property_ebe2d528d315404ea7aa137abeb760e2_Out_0_Float, Constant_2c293f9f5c22420092d050d9f942143c, _CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float);
            float _Property_6dbc7a50788b4ef583c91a7ea905ca17_Out_0_Float = _Arc;
            float2 _Vector2_9f19db7e33784b5f80d62fab6fa51f01_Out_0_Vector2 = float2(float(0.5), float(0.5));
            float2 _Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2;
            Unity_Subtract_float2((_UV_f52c5fd79de24079b23faf0c14133320_Out_0_Vector4.xy), _Vector2_9f19db7e33784b5f80d62fab6fa51f01_Out_0_Vector2, _Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2);
            float _Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float;
            Unity_Length_float2(_Subtract_44ef17d5ff4c40898910a03bde351e99_Out_2_Vector2, _Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float);
            float _Property_5b63f33b34c6422890078b226f715310_Out_0_Float = _FillProgress;
            float _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float;
            Unity_Divide_float(_Property_5b63f33b34c6422890078b226f715310_Out_0_Float, float(2), _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float);
            float _Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean;
            Unity_Comparison_Greater_float(_Length_4a8ef602ccf14594974895b0ec0aae1b_Out_1_Float, _Divide_432380f8f9504494b515497479c60ea7_Out_2_Float, _Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean);
            float _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float;
            Unity_Branch_float(_Comparison_23ef442789b74cd0b7325a75be9930aa_Out_2_Boolean, float(1), float(0), _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float);
            float4 _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4 = _Color;
            float3 _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3;
            Unity_ColorspaceConversion_Linear_RGB_float((_Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4.xyz), _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3);
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_R_1_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[0];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_G_2_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[1];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_B_3_Float = _ColorspaceConversion_a80a2805dfa84268a9da16fcdf39f3ad_Out_1_Vector3[2];
            float _Split_b3757f81924a4eb985ebd6e1d241ab57_A_4_Float = 0;
            float _Split_56f1bf897d644b998118593cdc2539b5_R_1_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[0];
            float _Split_56f1bf897d644b998118593cdc2539b5_G_2_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[1];
            float _Split_56f1bf897d644b998118593cdc2539b5_B_3_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[2];
            float _Split_56f1bf897d644b998118593cdc2539b5_A_4_Float = _Property_bcaf005a4e22492ba3ba80a7a69d3fb8_Out_0_Vector4[3];
            float4 _Vector4_463dad429f4a4a69843e69e8e1292aa7_Out_0_Vector4 = float4(_Split_b3757f81924a4eb985ebd6e1d241ab57_R_1_Float, _Split_b3757f81924a4eb985ebd6e1d241ab57_G_2_Float, _Split_b3757f81924a4eb985ebd6e1d241ab57_B_3_Float, _Split_56f1bf897d644b998118593cdc2539b5_A_4_Float);
            UnityTexture2D _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.tex, _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.samplerstate, _Property_8e597dc03a1143b08aa0d1a628e32a9e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_R_4_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.r;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_G_5_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.g;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_B_6_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.b;
            float _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_A_7_Float = _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4.a;
            float4 _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Vector4_463dad429f4a4a69843e69e8e1292aa7_Out_0_Vector4, _SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4, _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4);
            float4 _Property_03768353dd7743c2888242b70458081d_Out_0_Vector4 = _FillColor;
            float4 _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_06b14dacdf964acfa4255edcb5672dca_RGBA_0_Vector4, _Property_03768353dd7743c2888242b70458081d_Out_0_Vector4, _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4);
            float4 _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4;
            testpp_float(_CalculateNormalizedAngleCustomFunction_36231de36a1843aca25d8bd442d2f56c_normalizedAngle_0_Float, _Property_6dbc7a50788b4ef583c91a7ea905ca17_Out_0_Float, _Branch_d3344e014c6c4d05a06e7ebc7c38c9de_Out_3_Float, _Multiply_5c034f18ccc94d6d8e3d052873910e65_Out_2_Vector4, _Multiply_37f04bf94ac9472187bdffe63f83d213_Out_2_Vector4, _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4);
            float _Split_398445de4efc474ca65995a62366e687_R_1_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[0];
            float _Split_398445de4efc474ca65995a62366e687_G_2_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[1];
            float _Split_398445de4efc474ca65995a62366e687_B_3_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[2];
            float _Split_398445de4efc474ca65995a62366e687_A_4_Float = _testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4[3];
            surface.BaseColor = (_testppCustomFunction_0ce5b48faad6477fbc61870d7b0d37c3_out_2_Vector4.xyz);
            surface.Alpha = _Split_398445de4efc474ca65995a62366e687_A_4_Float;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.NormalAlpha = float(1);
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            
        //     $features.graphVertex:  $include("VertexAnimation.template.hlsl")
        //                                       ^ ERROR: $include cannot find file : VertexAnimation.template.hlsl. Looked into:
        // Packages/com.unity.shadergraph/Editor/Generation/Templates
        
            
        //     $features.graphPixel:   $include("SharedCode.template.hlsl")
        //                                       ^ ERROR: $include cannot find file : SharedCode.template.hlsl. Looked into:
        // Packages/com.unity.shadergraph/Editor/Generation/Templates
        
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorCopyToSDI' */
        
        
        
            output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 =                                        input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
            return output;
        }
        
            // --------------------------------------------------
            // Build Surface Data
        
            void GetSurfaceData(Varyings input, float4 positionCS, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                    half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                    float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                    float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                    input.texCoord0.xy = input.texCoord0.xy * scale + offset;
                    half3 normalWS = TransformObjectToWorldDir(half3(0, 1, 0));
                    half3 tangentWS = TransformObjectToWorldDir(half3(1, 0, 0));
                    half3 bitangentWS = TransformObjectToWorldDir(half3(0, 0, 1));
                    half sign = dot(cross(normalWS, tangentWS), bitangentWS) > 0 ? 1 : -1;
                    input.normalWS.xyz = normalWS;
                    input.tangentWS.xyzw = half4(tangentWS, sign);
                #else
                    #if defined(LOD_FADE_CROSSFADE) && USE_UNITY_CROSSFADE
                        LODFadeCrossFade(positionCS);
                    #endif
        
                    half fadeFactor = half(1.0);
                #endif
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(input);
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
        
                // setup defaults -- these are used if the graph doesn't output a value
                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);
        
                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif
        
        
                // copy across graph values, if defined
                surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);
        
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        surfaceData.normalWS.xyz = normalize(mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz));
                    #else
                        surfaceData.normalWS.xyz = normalize(normalToWorld[2].xyz);
                    #endif
                #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        float sgn = input.tangentWS.w;      // should be either +1 or -1
                        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
        
                        // We need to normalize as we use mikkt tangent space and this is expected (tangent space is not normalize)
                        surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                    #else
                        surfaceData.normalWS.xyz = normalize(half3(input.normalWS)); // Default to vertex normal
                    #endif
                #endif
        
                surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
        
                // In case of Smoothness / AO / Metal, all the three are always computed but color mask can change
            }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPassDecal.hlsl"
        
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
        #pragma multi_compile_instancing
        #pragma editor_sync_compilation
        #pragma vertex Vert
        #pragma fragment Frag
        
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        
            // Defines
            
            #define HAVE_MESH_MODIFICATION
        
        
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        
            // -- Properties used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            #if _RENDER_PASS_ENABLED
            #define GBUFFER3 0
            #define GBUFFER4 1
            FRAMEBUFFER_INPUT_HALF(GBUFFER3);
            FRAMEBUFFER_INPUT_HALF(GBUFFER4);
            #endif
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
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
            struct Attributes
        {
             float3 positionOS : POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
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
        };
        struct VertexDescriptionInputs
        {
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
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
        float4 _MainTex_TexelSize;
        float4 _Color;
        float4 _FillColor;
        float _FillProgress;
        float _Arc;
        float _Angle;
        float _DrawOrder;
        float _DecalMeshBiasType;
        float _DecalMeshDepthBias;
        float _DecalMeshViewBias;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
            // Graph Includes
            // GraphIncludes: <None>
        
            // Graph Functions
            // GraphFunctions: <None>
        
            // Graph Vertex
            struct VertexDescription
        {
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            return description;
        }
            
            // Graph Pixel
            struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            
        //     $features.graphVertex:  $include("VertexAnimation.template.hlsl")
        //                                       ^ ERROR: $include cannot find file : VertexAnimation.template.hlsl. Looked into:
        // Packages/com.unity.shadergraph/Editor/Generation/Templates
        
            
        //     $features.graphPixel:   $include("SharedCode.template.hlsl")
        //                                       ^ ERROR: $include cannot find file : SharedCode.template.hlsl. Looked into:
        // Packages/com.unity.shadergraph/Editor/Generation/Templates
        
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorCopyToSDI' */
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
            return output;
        }
        
            // --------------------------------------------------
            // Build Surface Data
        
            void GetSurfaceData(Varyings input, float4 positionCS, float angleFadeFactor, out DecalSurfaceData surfaceData)
            {
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                    half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                    float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                    float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                    half3 normalWS = TransformObjectToWorldDir(half3(0, 1, 0));
                    half3 tangentWS = TransformObjectToWorldDir(half3(1, 0, 0));
                    half3 bitangentWS = TransformObjectToWorldDir(half3(0, 0, 1));
                    half sign = dot(cross(normalWS, tangentWS), bitangentWS) > 0 ? 1 : -1;
                #else
                    #if defined(LOD_FADE_CROSSFADE) && USE_UNITY_CROSSFADE
                        LODFadeCrossFade(positionCS);
                    #endif
        
                    half fadeFactor = half(1.0);
                #endif
        
                SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(input);
                SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
        
                // setup defaults -- these are used if the graph doesn't output a value
                ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                surfaceData.occlusion = half(1.0);
                surfaceData.smoothness = half(0);
        
                #ifdef _MATERIAL_AFFECTS_NORMAL
                    surfaceData.normalWS.w = half(1.0);
                #else
                    surfaceData.normalWS.w = half(0.0);
                #endif
        
        
                // copy across graph values, if defined
        
                #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                    #else
                        surfaceData.normalWS.xyz = normalize(normalToWorld[2].xyz);
                    #endif
                #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                    #if defined(_MATERIAL_AFFECTS_NORMAL)
                        float sgn = input.tangentWS.w;      // should be either +1 or -1
                        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                        half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
        
                        // We need to normalize as we use mikkt tangent space and this is expected (tangent space is not normalize)
                    #else
                        surfaceData.normalWS.xyz = normalize(half3(input.normalWS)); // Default to vertex normal
                    #endif
                #endif
        
        
                // In case of Smoothness / AO / Metal, all the three are always computed but color mask can change
            }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPassDecal.hlsl"
        
            ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.Rendering.Universal.DecalShaderGraphGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}