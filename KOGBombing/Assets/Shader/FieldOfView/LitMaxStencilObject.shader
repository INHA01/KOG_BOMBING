Shader "Custom/Lit Max Stencil Object"
{
    Properties
    {
        _BASE_COLOR_WEIGHT("BaseColorWeight", Range(0, 1)) = 1
        _BASE_COLOR("BaseColor", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_BASE_COLOR_MAP("BaseColorMap", 2D) = "white" {}
        _REFLECTIONS_WEIGHT("ReflectionsWeight", Float) = 1
        _REFLECTIONS_COLOR("ReflectionsColor", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_REFLECTIONS_COLOR_MAP("ReflectionsColorMap", 2D) = "white" {}
        _REFLECTIONS_ROUGHNESS("ReflectionsRoughness", Range(0, 1)) = 1
        [NoScaleOffset]_REFLECTIONS_ROUGHNESS_MAP("ReflectionsRoughnessMap", 2D) = "white" {}
        _METALNESS("Metalness", Range(0, 1)) = 0
        [NoScaleOffset]_METALNESS_MAP("MetalnessMap", 2D) = "white" {}
        _REFLECTIONS_IOR("ReflectionsIOR", Range(0, 50)) = 1.52
        [NoScaleOffset]_REFLECTIONS_IOR_MAP("ReflectionsIORMap", 2D) = "white" {}
        _TRANSPARENCY("Transparency", Range(0, 1)) = 0
        [NoScaleOffset]_TRANSPARENCY_MAP("TransparencyMap", 2D) = "white" {}
        _EMISSION_WEIGHT("EmissionWeight", Range(0, 1)) = 1
        _EMISSION_COLOR("Emission", Color) = (0, 0, 0, 0)
        [NoScaleOffset]_EMISSION_COLOR_MAP("EmissionMap", 2D) = "white" {}
        _BUMP_MAP_STRENGTH("BumpMapStrength", Range(0, 10)) = 0.3
        [NoScaleOffset]_BUMP_MAP("BumpMap", 2D) = "white" {}
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
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="Geometry"
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
                "RenderType"="Opacue" 
            }
            Stencil
            {
                Ref 1
                Comp NotEqual
                Pass Keep
            }

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
        #define _SPECULAR_SETUP 1
        
        
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
        float _BASE_COLOR_WEIGHT;
        float4 _BASE_COLOR;
        float4 _BASE_COLOR_MAP_TexelSize;
        float _REFLECTIONS_WEIGHT;
        float4 _REFLECTIONS_COLOR;
        float4 _REFLECTIONS_COLOR_MAP_TexelSize;
        float _REFLECTIONS_ROUGHNESS;
        float4 _REFLECTIONS_ROUGHNESS_MAP_TexelSize;
        float _METALNESS;
        float4 _METALNESS_MAP_TexelSize;
        float _REFLECTIONS_IOR;
        float4 _REFLECTIONS_IOR_MAP_TexelSize;
        float _TRANSPARENCY;
        float4 _TRANSPARENCY_MAP_TexelSize;
        float _EMISSION_WEIGHT;
        float4 _EMISSION_COLOR;
        float4 _EMISSION_COLOR_MAP_TexelSize;
        float _BUMP_MAP_STRENGTH;
        float4 _BUMP_MAP_TexelSize;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BASE_COLOR_MAP);
        SAMPLER(sampler_BASE_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_COLOR_MAP);
        SAMPLER(sampler_REFLECTIONS_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_ROUGHNESS_MAP);
        SAMPLER(sampler_REFLECTIONS_ROUGHNESS_MAP);
        TEXTURE2D(_METALNESS_MAP);
        SAMPLER(sampler_METALNESS_MAP);
        TEXTURE2D(_REFLECTIONS_IOR_MAP);
        SAMPLER(sampler_REFLECTIONS_IOR_MAP);
        TEXTURE2D(_TRANSPARENCY_MAP);
        SAMPLER(sampler_TRANSPARENCY_MAP);
        TEXTURE2D(_EMISSION_COLOR_MAP);
        SAMPLER(sampler_EMISSION_COLOR_MAP);
        TEXTURE2D(_BUMP_MAP);
        SAMPLER(sampler_BUMP_MAP);
        
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
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalFromTexture_float(TEXTURE2D_PARAM(Texture, Sampler), float2 UV, float Offset, float Strength, out float3 Out)
        {
            Offset = pow(Offset, 3) * 0.1;
            float2 offsetU = float2(UV.x + Offset, UV.y);
            float2 offsetV = float2(UV.x, UV.y + Offset);
            float normalSample = SAMPLE_TEXTURE2D(Texture, Sampler, UV);
            float uSample = SAMPLE_TEXTURE2D(Texture, Sampler, offsetU);
            float vSample = SAMPLE_TEXTURE2D(Texture, Sampler, offsetV);
            float3 va = float3(1, 0, (uSample - normalSample) * Strength);
            float3 vb = float3(0, 1, (vSample - normalSample) * Strength);
            Out = normalize(cross(va, vb));
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Power_float4(float4 A, float4 B, out float4 Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
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
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BASE_COLOR_MAP);
            float4 _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.tex, _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.samplerstate, _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_R_4_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.r;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_G_5_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.g;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_B_6_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.b;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_A_7_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.a;
            float4 _Property_15861e58e3f6bb879519e3649781db96_Out_0_Vector4 = _BASE_COLOR;
            float4 _Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4, _Property_15861e58e3f6bb879519e3649781db96_Out_0_Vector4, _Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4);
            float _Property_e0552345c111ee80a0adc278159e6477_Out_0_Float = _BASE_COLOR_WEIGHT;
            float4 _Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4, (_Property_e0552345c111ee80a0adc278159e6477_Out_0_Float.xxxx), _Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4);
            UnityTexture2D _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_METALNESS_MAP);
            float4 _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.tex, _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.samplerstate, _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_R_4_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.r;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_G_5_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.g;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_B_6_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.b;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_A_7_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.a;
            float _Property_3c20033bbb7f108d9458f3b347a29334_Out_0_Float = _METALNESS;
            float4 _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4, (_Property_3c20033bbb7f108d9458f3b347a29334_Out_0_Float.xxxx), _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4);
            float4 _Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4, float4(0, 0, 0, 0), _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4, _Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4);
            UnityTexture2D _Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BUMP_MAP);
            float _Property_aa45efe06391478e8306b28a7606d7c8_Out_0_Float = _BUMP_MAP_STRENGTH;
            float3 _NormalFromTexture_d803cd8f749bd48389f0f8240bdd58d5_Out_5_Vector3;
            Unity_NormalFromTexture_float(TEXTURE2D_ARGS(_Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D.tex, _Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D.samplerstate), _Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy), float(0.5), _Property_aa45efe06391478e8306b28a7606d7c8_Out_0_Float, _NormalFromTexture_d803cd8f749bd48389f0f8240bdd58d5_Out_5_Vector3);
            UnityTexture2D _Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_EMISSION_COLOR_MAP);
            float4 _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D.tex, _Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D.samplerstate, _Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_R_4_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.r;
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_G_5_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.g;
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_B_6_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.b;
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_A_7_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.a;
            float4 _Property_cc32b24f4c84c78c8aeeaedd3118be61_Out_0_Vector4 = _EMISSION_COLOR;
            float4 _Multiply_d9ba77df91f297869e9c43f48c3cd415_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4, _Property_cc32b24f4c84c78c8aeeaedd3118be61_Out_0_Vector4, _Multiply_d9ba77df91f297869e9c43f48c3cd415_Out_2_Vector4);
            float _Property_3bbca4a4925b0389a1b42d2ee135b234_Out_0_Float = _EMISSION_WEIGHT;
            float4 _Multiply_58182c51fe3ca8888fe37c35df7f9d5f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_d9ba77df91f297869e9c43f48c3cd415_Out_2_Vector4, (_Property_3bbca4a4925b0389a1b42d2ee135b234_Out_0_Float.xxxx), _Multiply_58182c51fe3ca8888fe37c35df7f9d5f_Out_2_Vector4);
            UnityTexture2D _Property_511c3ebae7d74881aeb8767a828e7b47_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_REFLECTIONS_COLOR_MAP);
            float4 _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_511c3ebae7d74881aeb8767a828e7b47_Out_0_Texture2D.tex, _Property_511c3ebae7d74881aeb8767a828e7b47_Out_0_Texture2D.samplerstate, _Property_511c3ebae7d74881aeb8767a828e7b47_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_R_4_Float = _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4.r;
            float _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_G_5_Float = _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4.g;
            float _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_B_6_Float = _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4.b;
            float _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_A_7_Float = _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4.a;
            float4 _Property_ad5963ae6745a88889f7a164129ef1c1_Out_0_Vector4 = _REFLECTIONS_COLOR;
            float4 _Multiply_ed6075d62c535b899daa5df710601a96_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4, _Property_ad5963ae6745a88889f7a164129ef1c1_Out_0_Vector4, _Multiply_ed6075d62c535b899daa5df710601a96_Out_2_Vector4);
            float _Property_95bc169b83f8d78e81c6b641622590ef_Out_0_Float = _REFLECTIONS_WEIGHT;
            float4 _Multiply_ad9a3acc49910c80aad1a2286d95f7d4_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_ed6075d62c535b899daa5df710601a96_Out_2_Vector4, (_Property_95bc169b83f8d78e81c6b641622590ef_Out_0_Float.xxxx), _Multiply_ad9a3acc49910c80aad1a2286d95f7d4_Out_2_Vector4);
            UnityTexture2D _Property_349d08971003e68c8bc59a39385abc86_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_REFLECTIONS_IOR_MAP);
            float4 _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_349d08971003e68c8bc59a39385abc86_Out_0_Texture2D.tex, _Property_349d08971003e68c8bc59a39385abc86_Out_0_Texture2D.samplerstate, _Property_349d08971003e68c8bc59a39385abc86_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_R_4_Float = _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4.r;
            float _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_G_5_Float = _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4.g;
            float _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_B_6_Float = _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4.b;
            float _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_A_7_Float = _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4.a;
            float _Property_463f9db41a5c2784899e3156c83a7691_Out_0_Float = _REFLECTIONS_IOR;
            float4 _Multiply_0752bfb2233a3e80a9fb67539f40f443_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4, (_Property_463f9db41a5c2784899e3156c83a7691_Out_0_Float.xxxx), _Multiply_0752bfb2233a3e80a9fb67539f40f443_Out_2_Vector4);
            float4 _Subtract_5efcd24f379a7586818aedc6dafa349a_Out_2_Vector4;
            Unity_Subtract_float4(_Multiply_0752bfb2233a3e80a9fb67539f40f443_Out_2_Vector4, float4(1, 1, 1, 1), _Subtract_5efcd24f379a7586818aedc6dafa349a_Out_2_Vector4);
            float4 _Power_782bc6c8bdc5bf83baebfd71c5eddb91_Out_2_Vector4;
            Unity_Power_float4(_Subtract_5efcd24f379a7586818aedc6dafa349a_Out_2_Vector4, float4(2, 2, 2, 2), _Power_782bc6c8bdc5bf83baebfd71c5eddb91_Out_2_Vector4);
            float4 _Add_fd53c1b50a75d7889ab6ba6db3836384_Out_2_Vector4;
            Unity_Add_float4(_Multiply_0752bfb2233a3e80a9fb67539f40f443_Out_2_Vector4, float4(1, 1, 1, 1), _Add_fd53c1b50a75d7889ab6ba6db3836384_Out_2_Vector4);
            float4 _Power_1faf18b28832f88e8a27f84d5f73f0a1_Out_2_Vector4;
            Unity_Power_float4(_Add_fd53c1b50a75d7889ab6ba6db3836384_Out_2_Vector4, float4(2, 2, 2, 2), _Power_1faf18b28832f88e8a27f84d5f73f0a1_Out_2_Vector4);
            float4 _Divide_19d12880e30e418b80c6323c6e7717ee_Out_2_Vector4;
            Unity_Divide_float4(_Power_782bc6c8bdc5bf83baebfd71c5eddb91_Out_2_Vector4, _Power_1faf18b28832f88e8a27f84d5f73f0a1_Out_2_Vector4, _Divide_19d12880e30e418b80c6323c6e7717ee_Out_2_Vector4);
            float4 _Multiply_af45d4614a18cb8cb72c40d7247c2b93_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_ad9a3acc49910c80aad1a2286d95f7d4_Out_2_Vector4, _Divide_19d12880e30e418b80c6323c6e7717ee_Out_2_Vector4, _Multiply_af45d4614a18cb8cb72c40d7247c2b93_Out_2_Vector4);
            float4 _Lerp_46ff80efe7b75188aea459b332b9d54b_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_af45d4614a18cb8cb72c40d7247c2b93_Out_2_Vector4, _Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4, _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4, _Lerp_46ff80efe7b75188aea459b332b9d54b_Out_3_Vector4);
            UnityTexture2D _Property_5248cb3f54f14c82ac5e6121c03328da_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_REFLECTIONS_ROUGHNESS_MAP);
            float4 _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_5248cb3f54f14c82ac5e6121c03328da_Out_0_Texture2D.tex, _Property_5248cb3f54f14c82ac5e6121c03328da_Out_0_Texture2D.samplerstate, _Property_5248cb3f54f14c82ac5e6121c03328da_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_R_4_Float = _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4.r;
            float _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_G_5_Float = _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4.g;
            float _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_B_6_Float = _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4.b;
            float _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_A_7_Float = _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4.a;
            float _Property_6387cbaf2e744d8e849559a0b884be8f_Out_0_Float = _REFLECTIONS_ROUGHNESS;
            float4 _Multiply_e6a1bb59861184898aa35820c219092b_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4, (_Property_6387cbaf2e744d8e849559a0b884be8f_Out_0_Float.xxxx), _Multiply_e6a1bb59861184898aa35820c219092b_Out_2_Vector4);
            float4 _OneMinus_d4e451220a7714809338b389038e3245_Out_1_Vector4;
            Unity_OneMinus_float4(_Multiply_e6a1bb59861184898aa35820c219092b_Out_2_Vector4, _OneMinus_d4e451220a7714809338b389038e3245_Out_1_Vector4);
            // TODO : BASE COLOR
            surface.BaseColor = (_Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4.xyz) * (1.0 - 0.6f);
            surface.NormalTS = _NormalFromTexture_d803cd8f749bd48389f0f8240bdd58d5_Out_5_Vector3;
            surface.Emission = (_Multiply_58182c51fe3ca8888fe37c35df7f9d5f_Out_2_Vector4.xyz);
            surface.Specular = (_Lerp_46ff80efe7b75188aea459b332b9d54b_Out_3_Vector4.xyz);
            surface.Smoothness = (_OneMinus_d4e451220a7714809338b389038e3245_Out_1_Vector4).x;
            surface.Occlusion = float(1);
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
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
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
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One Zero
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
        #define _SPECULAR_SETUP 1
        
        
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
        float _BASE_COLOR_WEIGHT;
        float4 _BASE_COLOR;
        float4 _BASE_COLOR_MAP_TexelSize;
        float _REFLECTIONS_WEIGHT;
        float4 _REFLECTIONS_COLOR;
        float4 _REFLECTIONS_COLOR_MAP_TexelSize;
        float _REFLECTIONS_ROUGHNESS;
        float4 _REFLECTIONS_ROUGHNESS_MAP_TexelSize;
        float _METALNESS;
        float4 _METALNESS_MAP_TexelSize;
        float _REFLECTIONS_IOR;
        float4 _REFLECTIONS_IOR_MAP_TexelSize;
        float _TRANSPARENCY;
        float4 _TRANSPARENCY_MAP_TexelSize;
        float _EMISSION_WEIGHT;
        float4 _EMISSION_COLOR;
        float4 _EMISSION_COLOR_MAP_TexelSize;
        float _BUMP_MAP_STRENGTH;
        float4 _BUMP_MAP_TexelSize;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BASE_COLOR_MAP);
        SAMPLER(sampler_BASE_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_COLOR_MAP);
        SAMPLER(sampler_REFLECTIONS_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_ROUGHNESS_MAP);
        SAMPLER(sampler_REFLECTIONS_ROUGHNESS_MAP);
        TEXTURE2D(_METALNESS_MAP);
        SAMPLER(sampler_METALNESS_MAP);
        TEXTURE2D(_REFLECTIONS_IOR_MAP);
        SAMPLER(sampler_REFLECTIONS_IOR_MAP);
        TEXTURE2D(_TRANSPARENCY_MAP);
        SAMPLER(sampler_TRANSPARENCY_MAP);
        TEXTURE2D(_EMISSION_COLOR_MAP);
        SAMPLER(sampler_EMISSION_COLOR_MAP);
        TEXTURE2D(_BUMP_MAP);
        SAMPLER(sampler_BUMP_MAP);
        
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
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalFromTexture_float(TEXTURE2D_PARAM(Texture, Sampler), float2 UV, float Offset, float Strength, out float3 Out)
        {
            Offset = pow(Offset, 3) * 0.1;
            float2 offsetU = float2(UV.x + Offset, UV.y);
            float2 offsetV = float2(UV.x, UV.y + Offset);
            float normalSample = SAMPLE_TEXTURE2D(Texture, Sampler, UV);
            float uSample = SAMPLE_TEXTURE2D(Texture, Sampler, offsetU);
            float vSample = SAMPLE_TEXTURE2D(Texture, Sampler, offsetV);
            float3 va = float3(1, 0, (uSample - normalSample) * Strength);
            float3 vb = float3(0, 1, (vSample - normalSample) * Strength);
            Out = normalize(cross(va, vb));
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Power_float4(float4 A, float4 B, out float4 Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
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
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BASE_COLOR_MAP);
            float4 _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.tex, _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.samplerstate, _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_R_4_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.r;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_G_5_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.g;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_B_6_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.b;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_A_7_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.a;
            float4 _Property_15861e58e3f6bb879519e3649781db96_Out_0_Vector4 = _BASE_COLOR;
            float4 _Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4, _Property_15861e58e3f6bb879519e3649781db96_Out_0_Vector4, _Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4);
            float _Property_e0552345c111ee80a0adc278159e6477_Out_0_Float = _BASE_COLOR_WEIGHT;
            float4 _Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4, (_Property_e0552345c111ee80a0adc278159e6477_Out_0_Float.xxxx), _Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4);
            UnityTexture2D _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_METALNESS_MAP);
            float4 _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.tex, _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.samplerstate, _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_R_4_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.r;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_G_5_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.g;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_B_6_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.b;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_A_7_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.a;
            float _Property_3c20033bbb7f108d9458f3b347a29334_Out_0_Float = _METALNESS;
            float4 _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4, (_Property_3c20033bbb7f108d9458f3b347a29334_Out_0_Float.xxxx), _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4);
            float4 _Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4, float4(0, 0, 0, 0), _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4, _Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4);
            UnityTexture2D _Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BUMP_MAP);
            float _Property_aa45efe06391478e8306b28a7606d7c8_Out_0_Float = _BUMP_MAP_STRENGTH;
            float3 _NormalFromTexture_d803cd8f749bd48389f0f8240bdd58d5_Out_5_Vector3;
            Unity_NormalFromTexture_float(TEXTURE2D_ARGS(_Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D.tex, _Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D.samplerstate), _Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy), float(0.5), _Property_aa45efe06391478e8306b28a7606d7c8_Out_0_Float, _NormalFromTexture_d803cd8f749bd48389f0f8240bdd58d5_Out_5_Vector3);
            UnityTexture2D _Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_EMISSION_COLOR_MAP);
            float4 _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D.tex, _Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D.samplerstate, _Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_R_4_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.r;
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_G_5_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.g;
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_B_6_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.b;
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_A_7_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.a;
            float4 _Property_cc32b24f4c84c78c8aeeaedd3118be61_Out_0_Vector4 = _EMISSION_COLOR;
            float4 _Multiply_d9ba77df91f297869e9c43f48c3cd415_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4, _Property_cc32b24f4c84c78c8aeeaedd3118be61_Out_0_Vector4, _Multiply_d9ba77df91f297869e9c43f48c3cd415_Out_2_Vector4);
            float _Property_3bbca4a4925b0389a1b42d2ee135b234_Out_0_Float = _EMISSION_WEIGHT;
            float4 _Multiply_58182c51fe3ca8888fe37c35df7f9d5f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_d9ba77df91f297869e9c43f48c3cd415_Out_2_Vector4, (_Property_3bbca4a4925b0389a1b42d2ee135b234_Out_0_Float.xxxx), _Multiply_58182c51fe3ca8888fe37c35df7f9d5f_Out_2_Vector4);
            UnityTexture2D _Property_511c3ebae7d74881aeb8767a828e7b47_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_REFLECTIONS_COLOR_MAP);
            float4 _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_511c3ebae7d74881aeb8767a828e7b47_Out_0_Texture2D.tex, _Property_511c3ebae7d74881aeb8767a828e7b47_Out_0_Texture2D.samplerstate, _Property_511c3ebae7d74881aeb8767a828e7b47_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_R_4_Float = _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4.r;
            float _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_G_5_Float = _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4.g;
            float _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_B_6_Float = _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4.b;
            float _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_A_7_Float = _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4.a;
            float4 _Property_ad5963ae6745a88889f7a164129ef1c1_Out_0_Vector4 = _REFLECTIONS_COLOR;
            float4 _Multiply_ed6075d62c535b899daa5df710601a96_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4, _Property_ad5963ae6745a88889f7a164129ef1c1_Out_0_Vector4, _Multiply_ed6075d62c535b899daa5df710601a96_Out_2_Vector4);
            float _Property_95bc169b83f8d78e81c6b641622590ef_Out_0_Float = _REFLECTIONS_WEIGHT;
            float4 _Multiply_ad9a3acc49910c80aad1a2286d95f7d4_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_ed6075d62c535b899daa5df710601a96_Out_2_Vector4, (_Property_95bc169b83f8d78e81c6b641622590ef_Out_0_Float.xxxx), _Multiply_ad9a3acc49910c80aad1a2286d95f7d4_Out_2_Vector4);
            UnityTexture2D _Property_349d08971003e68c8bc59a39385abc86_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_REFLECTIONS_IOR_MAP);
            float4 _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_349d08971003e68c8bc59a39385abc86_Out_0_Texture2D.tex, _Property_349d08971003e68c8bc59a39385abc86_Out_0_Texture2D.samplerstate, _Property_349d08971003e68c8bc59a39385abc86_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_R_4_Float = _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4.r;
            float _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_G_5_Float = _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4.g;
            float _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_B_6_Float = _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4.b;
            float _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_A_7_Float = _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4.a;
            float _Property_463f9db41a5c2784899e3156c83a7691_Out_0_Float = _REFLECTIONS_IOR;
            float4 _Multiply_0752bfb2233a3e80a9fb67539f40f443_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4, (_Property_463f9db41a5c2784899e3156c83a7691_Out_0_Float.xxxx), _Multiply_0752bfb2233a3e80a9fb67539f40f443_Out_2_Vector4);
            float4 _Subtract_5efcd24f379a7586818aedc6dafa349a_Out_2_Vector4;
            Unity_Subtract_float4(_Multiply_0752bfb2233a3e80a9fb67539f40f443_Out_2_Vector4, float4(1, 1, 1, 1), _Subtract_5efcd24f379a7586818aedc6dafa349a_Out_2_Vector4);
            float4 _Power_782bc6c8bdc5bf83baebfd71c5eddb91_Out_2_Vector4;
            Unity_Power_float4(_Subtract_5efcd24f379a7586818aedc6dafa349a_Out_2_Vector4, float4(2, 2, 2, 2), _Power_782bc6c8bdc5bf83baebfd71c5eddb91_Out_2_Vector4);
            float4 _Add_fd53c1b50a75d7889ab6ba6db3836384_Out_2_Vector4;
            Unity_Add_float4(_Multiply_0752bfb2233a3e80a9fb67539f40f443_Out_2_Vector4, float4(1, 1, 1, 1), _Add_fd53c1b50a75d7889ab6ba6db3836384_Out_2_Vector4);
            float4 _Power_1faf18b28832f88e8a27f84d5f73f0a1_Out_2_Vector4;
            Unity_Power_float4(_Add_fd53c1b50a75d7889ab6ba6db3836384_Out_2_Vector4, float4(2, 2, 2, 2), _Power_1faf18b28832f88e8a27f84d5f73f0a1_Out_2_Vector4);
            float4 _Divide_19d12880e30e418b80c6323c6e7717ee_Out_2_Vector4;
            Unity_Divide_float4(_Power_782bc6c8bdc5bf83baebfd71c5eddb91_Out_2_Vector4, _Power_1faf18b28832f88e8a27f84d5f73f0a1_Out_2_Vector4, _Divide_19d12880e30e418b80c6323c6e7717ee_Out_2_Vector4);
            float4 _Multiply_af45d4614a18cb8cb72c40d7247c2b93_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_ad9a3acc49910c80aad1a2286d95f7d4_Out_2_Vector4, _Divide_19d12880e30e418b80c6323c6e7717ee_Out_2_Vector4, _Multiply_af45d4614a18cb8cb72c40d7247c2b93_Out_2_Vector4);
            float4 _Lerp_46ff80efe7b75188aea459b332b9d54b_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_af45d4614a18cb8cb72c40d7247c2b93_Out_2_Vector4, _Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4, _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4, _Lerp_46ff80efe7b75188aea459b332b9d54b_Out_3_Vector4);
            UnityTexture2D _Property_5248cb3f54f14c82ac5e6121c03328da_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_REFLECTIONS_ROUGHNESS_MAP);
            float4 _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_5248cb3f54f14c82ac5e6121c03328da_Out_0_Texture2D.tex, _Property_5248cb3f54f14c82ac5e6121c03328da_Out_0_Texture2D.samplerstate, _Property_5248cb3f54f14c82ac5e6121c03328da_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_R_4_Float = _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4.r;
            float _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_G_5_Float = _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4.g;
            float _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_B_6_Float = _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4.b;
            float _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_A_7_Float = _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4.a;
            float _Property_6387cbaf2e744d8e849559a0b884be8f_Out_0_Float = _REFLECTIONS_ROUGHNESS;
            float4 _Multiply_e6a1bb59861184898aa35820c219092b_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4, (_Property_6387cbaf2e744d8e849559a0b884be8f_Out_0_Float.xxxx), _Multiply_e6a1bb59861184898aa35820c219092b_Out_2_Vector4);
            float4 _OneMinus_d4e451220a7714809338b389038e3245_Out_1_Vector4;
            Unity_OneMinus_float4(_Multiply_e6a1bb59861184898aa35820c219092b_Out_2_Vector4, _OneMinus_d4e451220a7714809338b389038e3245_Out_1_Vector4);
            surface.BaseColor = (_Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4.xyz);
            surface.NormalTS = _NormalFromTexture_d803cd8f749bd48389f0f8240bdd58d5_Out_5_Vector3;
            surface.Emission = (_Multiply_58182c51fe3ca8888fe37c35df7f9d5f_Out_2_Vector4.xyz);
            surface.Specular = (_Lerp_46ff80efe7b75188aea459b332b9d54b_Out_3_Vector4.xyz);
            surface.Smoothness = (_OneMinus_d4e451220a7714809338b389038e3245_Out_1_Vector4).x;
            surface.Occlusion = float(1);
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
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
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
        Blend One Zero
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
        #define _SPECULAR_SETUP 1
        
        
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
        float _BASE_COLOR_WEIGHT;
        float4 _BASE_COLOR;
        float4 _BASE_COLOR_MAP_TexelSize;
        float _REFLECTIONS_WEIGHT;
        float4 _REFLECTIONS_COLOR;
        float4 _REFLECTIONS_COLOR_MAP_TexelSize;
        float _REFLECTIONS_ROUGHNESS;
        float4 _REFLECTIONS_ROUGHNESS_MAP_TexelSize;
        float _METALNESS;
        float4 _METALNESS_MAP_TexelSize;
        float _REFLECTIONS_IOR;
        float4 _REFLECTIONS_IOR_MAP_TexelSize;
        float _TRANSPARENCY;
        float4 _TRANSPARENCY_MAP_TexelSize;
        float _EMISSION_WEIGHT;
        float4 _EMISSION_COLOR;
        float4 _EMISSION_COLOR_MAP_TexelSize;
        float _BUMP_MAP_STRENGTH;
        float4 _BUMP_MAP_TexelSize;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BASE_COLOR_MAP);
        SAMPLER(sampler_BASE_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_COLOR_MAP);
        SAMPLER(sampler_REFLECTIONS_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_ROUGHNESS_MAP);
        SAMPLER(sampler_REFLECTIONS_ROUGHNESS_MAP);
        TEXTURE2D(_METALNESS_MAP);
        SAMPLER(sampler_METALNESS_MAP);
        TEXTURE2D(_REFLECTIONS_IOR_MAP);
        SAMPLER(sampler_REFLECTIONS_IOR_MAP);
        TEXTURE2D(_TRANSPARENCY_MAP);
        SAMPLER(sampler_TRANSPARENCY_MAP);
        TEXTURE2D(_EMISSION_COLOR_MAP);
        SAMPLER(sampler_EMISSION_COLOR_MAP);
        TEXTURE2D(_BUMP_MAP);
        SAMPLER(sampler_BUMP_MAP);
        
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
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_NormalFromTexture_float(TEXTURE2D_PARAM(Texture, Sampler), float2 UV, float Offset, float Strength, out float3 Out)
        {
            Offset = pow(Offset, 3) * 0.1;
            float2 offsetU = float2(UV.x + Offset, UV.y);
            float2 offsetV = float2(UV.x, UV.y + Offset);
            float normalSample = SAMPLE_TEXTURE2D(Texture, Sampler, UV);
            float uSample = SAMPLE_TEXTURE2D(Texture, Sampler, offsetU);
            float vSample = SAMPLE_TEXTURE2D(Texture, Sampler, offsetV);
            float3 va = float3(1, 0, (uSample - normalSample) * Strength);
            float3 vb = float3(0, 1, (vSample - normalSample) * Strength);
            Out = normalize(cross(va, vb));
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Power_float4(float4 A, float4 B, out float4 Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A / B;
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
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
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BASE_COLOR_MAP);
            float4 _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.tex, _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.samplerstate, _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_R_4_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.r;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_G_5_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.g;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_B_6_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.b;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_A_7_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.a;
            float4 _Property_15861e58e3f6bb879519e3649781db96_Out_0_Vector4 = _BASE_COLOR;
            float4 _Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4, _Property_15861e58e3f6bb879519e3649781db96_Out_0_Vector4, _Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4);
            float _Property_e0552345c111ee80a0adc278159e6477_Out_0_Float = _BASE_COLOR_WEIGHT;
            float4 _Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4, (_Property_e0552345c111ee80a0adc278159e6477_Out_0_Float.xxxx), _Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4);
            UnityTexture2D _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_METALNESS_MAP);
            float4 _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.tex, _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.samplerstate, _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_R_4_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.r;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_G_5_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.g;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_B_6_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.b;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_A_7_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.a;
            float _Property_3c20033bbb7f108d9458f3b347a29334_Out_0_Float = _METALNESS;
            float4 _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4, (_Property_3c20033bbb7f108d9458f3b347a29334_Out_0_Float.xxxx), _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4);
            float4 _Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4, float4(0, 0, 0, 0), _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4, _Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4);
            UnityTexture2D _Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BUMP_MAP);
            float _Property_aa45efe06391478e8306b28a7606d7c8_Out_0_Float = _BUMP_MAP_STRENGTH;
            float3 _NormalFromTexture_d803cd8f749bd48389f0f8240bdd58d5_Out_5_Vector3;
            Unity_NormalFromTexture_float(TEXTURE2D_ARGS(_Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D.tex, _Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D.samplerstate), _Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy), float(0.5), _Property_aa45efe06391478e8306b28a7606d7c8_Out_0_Float, _NormalFromTexture_d803cd8f749bd48389f0f8240bdd58d5_Out_5_Vector3);
            UnityTexture2D _Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_EMISSION_COLOR_MAP);
            float4 _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D.tex, _Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D.samplerstate, _Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_R_4_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.r;
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_G_5_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.g;
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_B_6_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.b;
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_A_7_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.a;
            float4 _Property_cc32b24f4c84c78c8aeeaedd3118be61_Out_0_Vector4 = _EMISSION_COLOR;
            float4 _Multiply_d9ba77df91f297869e9c43f48c3cd415_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4, _Property_cc32b24f4c84c78c8aeeaedd3118be61_Out_0_Vector4, _Multiply_d9ba77df91f297869e9c43f48c3cd415_Out_2_Vector4);
            float _Property_3bbca4a4925b0389a1b42d2ee135b234_Out_0_Float = _EMISSION_WEIGHT;
            float4 _Multiply_58182c51fe3ca8888fe37c35df7f9d5f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_d9ba77df91f297869e9c43f48c3cd415_Out_2_Vector4, (_Property_3bbca4a4925b0389a1b42d2ee135b234_Out_0_Float.xxxx), _Multiply_58182c51fe3ca8888fe37c35df7f9d5f_Out_2_Vector4);
            UnityTexture2D _Property_511c3ebae7d74881aeb8767a828e7b47_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_REFLECTIONS_COLOR_MAP);
            float4 _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_511c3ebae7d74881aeb8767a828e7b47_Out_0_Texture2D.tex, _Property_511c3ebae7d74881aeb8767a828e7b47_Out_0_Texture2D.samplerstate, _Property_511c3ebae7d74881aeb8767a828e7b47_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_R_4_Float = _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4.r;
            float _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_G_5_Float = _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4.g;
            float _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_B_6_Float = _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4.b;
            float _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_A_7_Float = _SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4.a;
            float4 _Property_ad5963ae6745a88889f7a164129ef1c1_Out_0_Vector4 = _REFLECTIONS_COLOR;
            float4 _Multiply_ed6075d62c535b899daa5df710601a96_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_812099ed52e7108a99d7237369c4d6b9_RGBA_0_Vector4, _Property_ad5963ae6745a88889f7a164129ef1c1_Out_0_Vector4, _Multiply_ed6075d62c535b899daa5df710601a96_Out_2_Vector4);
            float _Property_95bc169b83f8d78e81c6b641622590ef_Out_0_Float = _REFLECTIONS_WEIGHT;
            float4 _Multiply_ad9a3acc49910c80aad1a2286d95f7d4_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_ed6075d62c535b899daa5df710601a96_Out_2_Vector4, (_Property_95bc169b83f8d78e81c6b641622590ef_Out_0_Float.xxxx), _Multiply_ad9a3acc49910c80aad1a2286d95f7d4_Out_2_Vector4);
            UnityTexture2D _Property_349d08971003e68c8bc59a39385abc86_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_REFLECTIONS_IOR_MAP);
            float4 _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_349d08971003e68c8bc59a39385abc86_Out_0_Texture2D.tex, _Property_349d08971003e68c8bc59a39385abc86_Out_0_Texture2D.samplerstate, _Property_349d08971003e68c8bc59a39385abc86_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_R_4_Float = _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4.r;
            float _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_G_5_Float = _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4.g;
            float _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_B_6_Float = _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4.b;
            float _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_A_7_Float = _SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4.a;
            float _Property_463f9db41a5c2784899e3156c83a7691_Out_0_Float = _REFLECTIONS_IOR;
            float4 _Multiply_0752bfb2233a3e80a9fb67539f40f443_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ce470eaf3492818f87da80040b1a9079_RGBA_0_Vector4, (_Property_463f9db41a5c2784899e3156c83a7691_Out_0_Float.xxxx), _Multiply_0752bfb2233a3e80a9fb67539f40f443_Out_2_Vector4);
            float4 _Subtract_5efcd24f379a7586818aedc6dafa349a_Out_2_Vector4;
            Unity_Subtract_float4(_Multiply_0752bfb2233a3e80a9fb67539f40f443_Out_2_Vector4, float4(1, 1, 1, 1), _Subtract_5efcd24f379a7586818aedc6dafa349a_Out_2_Vector4);
            float4 _Power_782bc6c8bdc5bf83baebfd71c5eddb91_Out_2_Vector4;
            Unity_Power_float4(_Subtract_5efcd24f379a7586818aedc6dafa349a_Out_2_Vector4, float4(2, 2, 2, 2), _Power_782bc6c8bdc5bf83baebfd71c5eddb91_Out_2_Vector4);
            float4 _Add_fd53c1b50a75d7889ab6ba6db3836384_Out_2_Vector4;
            Unity_Add_float4(_Multiply_0752bfb2233a3e80a9fb67539f40f443_Out_2_Vector4, float4(1, 1, 1, 1), _Add_fd53c1b50a75d7889ab6ba6db3836384_Out_2_Vector4);
            float4 _Power_1faf18b28832f88e8a27f84d5f73f0a1_Out_2_Vector4;
            Unity_Power_float4(_Add_fd53c1b50a75d7889ab6ba6db3836384_Out_2_Vector4, float4(2, 2, 2, 2), _Power_1faf18b28832f88e8a27f84d5f73f0a1_Out_2_Vector4);
            float4 _Divide_19d12880e30e418b80c6323c6e7717ee_Out_2_Vector4;
            Unity_Divide_float4(_Power_782bc6c8bdc5bf83baebfd71c5eddb91_Out_2_Vector4, _Power_1faf18b28832f88e8a27f84d5f73f0a1_Out_2_Vector4, _Divide_19d12880e30e418b80c6323c6e7717ee_Out_2_Vector4);
            float4 _Multiply_af45d4614a18cb8cb72c40d7247c2b93_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_ad9a3acc49910c80aad1a2286d95f7d4_Out_2_Vector4, _Divide_19d12880e30e418b80c6323c6e7717ee_Out_2_Vector4, _Multiply_af45d4614a18cb8cb72c40d7247c2b93_Out_2_Vector4);
            float4 _Lerp_46ff80efe7b75188aea459b332b9d54b_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_af45d4614a18cb8cb72c40d7247c2b93_Out_2_Vector4, _Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4, _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4, _Lerp_46ff80efe7b75188aea459b332b9d54b_Out_3_Vector4);
            UnityTexture2D _Property_5248cb3f54f14c82ac5e6121c03328da_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_REFLECTIONS_ROUGHNESS_MAP);
            float4 _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_5248cb3f54f14c82ac5e6121c03328da_Out_0_Texture2D.tex, _Property_5248cb3f54f14c82ac5e6121c03328da_Out_0_Texture2D.samplerstate, _Property_5248cb3f54f14c82ac5e6121c03328da_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_R_4_Float = _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4.r;
            float _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_G_5_Float = _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4.g;
            float _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_B_6_Float = _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4.b;
            float _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_A_7_Float = _SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4.a;
            float _Property_6387cbaf2e744d8e849559a0b884be8f_Out_0_Float = _REFLECTIONS_ROUGHNESS;
            float4 _Multiply_e6a1bb59861184898aa35820c219092b_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_355ba26dc23e5d8280ca3738bb54e475_RGBA_0_Vector4, (_Property_6387cbaf2e744d8e849559a0b884be8f_Out_0_Float.xxxx), _Multiply_e6a1bb59861184898aa35820c219092b_Out_2_Vector4);
            float4 _OneMinus_d4e451220a7714809338b389038e3245_Out_1_Vector4;
            Unity_OneMinus_float4(_Multiply_e6a1bb59861184898aa35820c219092b_Out_2_Vector4, _OneMinus_d4e451220a7714809338b389038e3245_Out_1_Vector4);
            surface.BaseColor = (_Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4.xyz);
            surface.NormalTS = _NormalFromTexture_d803cd8f749bd48389f0f8240bdd58d5_Out_5_Vector3;
            surface.Emission = (_Multiply_58182c51fe3ca8888fe37c35df7f9d5f_Out_2_Vector4.xyz);
            surface.Specular = (_Lerp_46ff80efe7b75188aea459b332b9d54b_Out_3_Vector4.xyz);
            surface.Smoothness = (_OneMinus_d4e451220a7714809338b389038e3245_Out_1_Vector4).x;
            surface.Occlusion = float(1);
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
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
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
        #define VARYINGS_NEED_NORMAL_WS
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
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
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
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS : INTERP0;
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
        float _BASE_COLOR_WEIGHT;
        float4 _BASE_COLOR;
        float4 _BASE_COLOR_MAP_TexelSize;
        float _REFLECTIONS_WEIGHT;
        float4 _REFLECTIONS_COLOR;
        float4 _REFLECTIONS_COLOR_MAP_TexelSize;
        float _REFLECTIONS_ROUGHNESS;
        float4 _REFLECTIONS_ROUGHNESS_MAP_TexelSize;
        float _METALNESS;
        float4 _METALNESS_MAP_TexelSize;
        float _REFLECTIONS_IOR;
        float4 _REFLECTIONS_IOR_MAP_TexelSize;
        float _TRANSPARENCY;
        float4 _TRANSPARENCY_MAP_TexelSize;
        float _EMISSION_WEIGHT;
        float4 _EMISSION_COLOR;
        float4 _EMISSION_COLOR_MAP_TexelSize;
        float _BUMP_MAP_STRENGTH;
        float4 _BUMP_MAP_TexelSize;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BASE_COLOR_MAP);
        SAMPLER(sampler_BASE_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_COLOR_MAP);
        SAMPLER(sampler_REFLECTIONS_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_ROUGHNESS_MAP);
        SAMPLER(sampler_REFLECTIONS_ROUGHNESS_MAP);
        TEXTURE2D(_METALNESS_MAP);
        SAMPLER(sampler_METALNESS_MAP);
        TEXTURE2D(_REFLECTIONS_IOR_MAP);
        SAMPLER(sampler_REFLECTIONS_IOR_MAP);
        TEXTURE2D(_TRANSPARENCY_MAP);
        SAMPLER(sampler_TRANSPARENCY_MAP);
        TEXTURE2D(_EMISSION_COLOR_MAP);
        SAMPLER(sampler_EMISSION_COLOR_MAP);
        TEXTURE2D(_BUMP_MAP);
        SAMPLER(sampler_BUMP_MAP);
        
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
        // GraphFunctions: <None>
        
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
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
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        
        
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
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
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
        float _BASE_COLOR_WEIGHT;
        float4 _BASE_COLOR;
        float4 _BASE_COLOR_MAP_TexelSize;
        float _REFLECTIONS_WEIGHT;
        float4 _REFLECTIONS_COLOR;
        float4 _REFLECTIONS_COLOR_MAP_TexelSize;
        float _REFLECTIONS_ROUGHNESS;
        float4 _REFLECTIONS_ROUGHNESS_MAP_TexelSize;
        float _METALNESS;
        float4 _METALNESS_MAP_TexelSize;
        float _REFLECTIONS_IOR;
        float4 _REFLECTIONS_IOR_MAP_TexelSize;
        float _TRANSPARENCY;
        float4 _TRANSPARENCY_MAP_TexelSize;
        float _EMISSION_WEIGHT;
        float4 _EMISSION_COLOR;
        float4 _EMISSION_COLOR_MAP_TexelSize;
        float _BUMP_MAP_STRENGTH;
        float4 _BUMP_MAP_TexelSize;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BASE_COLOR_MAP);
        SAMPLER(sampler_BASE_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_COLOR_MAP);
        SAMPLER(sampler_REFLECTIONS_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_ROUGHNESS_MAP);
        SAMPLER(sampler_REFLECTIONS_ROUGHNESS_MAP);
        TEXTURE2D(_METALNESS_MAP);
        SAMPLER(sampler_METALNESS_MAP);
        TEXTURE2D(_REFLECTIONS_IOR_MAP);
        SAMPLER(sampler_REFLECTIONS_IOR_MAP);
        TEXTURE2D(_TRANSPARENCY_MAP);
        SAMPLER(sampler_TRANSPARENCY_MAP);
        TEXTURE2D(_EMISSION_COLOR_MAP);
        SAMPLER(sampler_EMISSION_COLOR_MAP);
        TEXTURE2D(_BUMP_MAP);
        SAMPLER(sampler_BUMP_MAP);
        
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
        // GraphFunctions: <None>
        
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
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
        float _BASE_COLOR_WEIGHT;
        float4 _BASE_COLOR;
        float4 _BASE_COLOR_MAP_TexelSize;
        float _REFLECTIONS_WEIGHT;
        float4 _REFLECTIONS_COLOR;
        float4 _REFLECTIONS_COLOR_MAP_TexelSize;
        float _REFLECTIONS_ROUGHNESS;
        float4 _REFLECTIONS_ROUGHNESS_MAP_TexelSize;
        float _METALNESS;
        float4 _METALNESS_MAP_TexelSize;
        float _REFLECTIONS_IOR;
        float4 _REFLECTIONS_IOR_MAP_TexelSize;
        float _TRANSPARENCY;
        float4 _TRANSPARENCY_MAP_TexelSize;
        float _EMISSION_WEIGHT;
        float4 _EMISSION_COLOR;
        float4 _EMISSION_COLOR_MAP_TexelSize;
        float _BUMP_MAP_STRENGTH;
        float4 _BUMP_MAP_TexelSize;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BASE_COLOR_MAP);
        SAMPLER(sampler_BASE_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_COLOR_MAP);
        SAMPLER(sampler_REFLECTIONS_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_ROUGHNESS_MAP);
        SAMPLER(sampler_REFLECTIONS_ROUGHNESS_MAP);
        TEXTURE2D(_METALNESS_MAP);
        SAMPLER(sampler_METALNESS_MAP);
        TEXTURE2D(_REFLECTIONS_IOR_MAP);
        SAMPLER(sampler_REFLECTIONS_IOR_MAP);
        TEXTURE2D(_TRANSPARENCY_MAP);
        SAMPLER(sampler_TRANSPARENCY_MAP);
        TEXTURE2D(_EMISSION_COLOR_MAP);
        SAMPLER(sampler_EMISSION_COLOR_MAP);
        TEXTURE2D(_BUMP_MAP);
        SAMPLER(sampler_BUMP_MAP);
        
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
        
        void Unity_NormalFromTexture_float(TEXTURE2D_PARAM(Texture, Sampler), float2 UV, float Offset, float Strength, out float3 Out)
        {
            Offset = pow(Offset, 3) * 0.1;
            float2 offsetU = float2(UV.x + Offset, UV.y);
            float2 offsetV = float2(UV.x, UV.y + Offset);
            float normalSample = SAMPLE_TEXTURE2D(Texture, Sampler, UV);
            float uSample = SAMPLE_TEXTURE2D(Texture, Sampler, offsetU);
            float vSample = SAMPLE_TEXTURE2D(Texture, Sampler, offsetV);
            float3 va = float3(1, 0, (uSample - normalSample) * Strength);
            float3 vb = float3(0, 1, (vSample - normalSample) * Strength);
            Out = normalize(cross(va, vb));
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
            float3 NormalTS;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BUMP_MAP);
            float _Property_aa45efe06391478e8306b28a7606d7c8_Out_0_Float = _BUMP_MAP_STRENGTH;
            float3 _NormalFromTexture_d803cd8f749bd48389f0f8240bdd58d5_Out_5_Vector3;
            Unity_NormalFromTexture_float(TEXTURE2D_ARGS(_Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D.tex, _Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D.samplerstate), _Property_19bf65c5a3c97585a58fb518c89d3b96_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy), float(0.5), _Property_aa45efe06391478e8306b28a7606d7c8_Out_0_Float, _NormalFromTexture_d803cd8f749bd48389f0f8240bdd58d5_Out_5_Vector3);
            surface.NormalTS = _NormalFromTexture_d803cd8f749bd48389f0f8240bdd58d5_Out_5_Vector3;
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
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
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
        float _BASE_COLOR_WEIGHT;
        float4 _BASE_COLOR;
        float4 _BASE_COLOR_MAP_TexelSize;
        float _REFLECTIONS_WEIGHT;
        float4 _REFLECTIONS_COLOR;
        float4 _REFLECTIONS_COLOR_MAP_TexelSize;
        float _REFLECTIONS_ROUGHNESS;
        float4 _REFLECTIONS_ROUGHNESS_MAP_TexelSize;
        float _METALNESS;
        float4 _METALNESS_MAP_TexelSize;
        float _REFLECTIONS_IOR;
        float4 _REFLECTIONS_IOR_MAP_TexelSize;
        float _TRANSPARENCY;
        float4 _TRANSPARENCY_MAP_TexelSize;
        float _EMISSION_WEIGHT;
        float4 _EMISSION_COLOR;
        float4 _EMISSION_COLOR_MAP_TexelSize;
        float _BUMP_MAP_STRENGTH;
        float4 _BUMP_MAP_TexelSize;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BASE_COLOR_MAP);
        SAMPLER(sampler_BASE_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_COLOR_MAP);
        SAMPLER(sampler_REFLECTIONS_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_ROUGHNESS_MAP);
        SAMPLER(sampler_REFLECTIONS_ROUGHNESS_MAP);
        TEXTURE2D(_METALNESS_MAP);
        SAMPLER(sampler_METALNESS_MAP);
        TEXTURE2D(_REFLECTIONS_IOR_MAP);
        SAMPLER(sampler_REFLECTIONS_IOR_MAP);
        TEXTURE2D(_TRANSPARENCY_MAP);
        SAMPLER(sampler_TRANSPARENCY_MAP);
        TEXTURE2D(_EMISSION_COLOR_MAP);
        SAMPLER(sampler_EMISSION_COLOR_MAP);
        TEXTURE2D(_BUMP_MAP);
        SAMPLER(sampler_BUMP_MAP);
        
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
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
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
            float3 BaseColor;
            float3 Emission;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BASE_COLOR_MAP);
            float4 _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.tex, _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.samplerstate, _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_R_4_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.r;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_G_5_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.g;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_B_6_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.b;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_A_7_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.a;
            float4 _Property_15861e58e3f6bb879519e3649781db96_Out_0_Vector4 = _BASE_COLOR;
            float4 _Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4, _Property_15861e58e3f6bb879519e3649781db96_Out_0_Vector4, _Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4);
            float _Property_e0552345c111ee80a0adc278159e6477_Out_0_Float = _BASE_COLOR_WEIGHT;
            float4 _Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4, (_Property_e0552345c111ee80a0adc278159e6477_Out_0_Float.xxxx), _Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4);
            UnityTexture2D _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_METALNESS_MAP);
            float4 _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.tex, _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.samplerstate, _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_R_4_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.r;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_G_5_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.g;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_B_6_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.b;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_A_7_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.a;
            float _Property_3c20033bbb7f108d9458f3b347a29334_Out_0_Float = _METALNESS;
            float4 _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4, (_Property_3c20033bbb7f108d9458f3b347a29334_Out_0_Float.xxxx), _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4);
            float4 _Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4, float4(0, 0, 0, 0), _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4, _Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4);
            UnityTexture2D _Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_EMISSION_COLOR_MAP);
            float4 _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D.tex, _Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D.samplerstate, _Property_795b0a583211228fa3bd210d3e0fbcf3_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_R_4_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.r;
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_G_5_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.g;
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_B_6_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.b;
            float _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_A_7_Float = _SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4.a;
            float4 _Property_cc32b24f4c84c78c8aeeaedd3118be61_Out_0_Vector4 = _EMISSION_COLOR;
            float4 _Multiply_d9ba77df91f297869e9c43f48c3cd415_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_d8e089052c3ae887a36ec968dfccb76f_RGBA_0_Vector4, _Property_cc32b24f4c84c78c8aeeaedd3118be61_Out_0_Vector4, _Multiply_d9ba77df91f297869e9c43f48c3cd415_Out_2_Vector4);
            float _Property_3bbca4a4925b0389a1b42d2ee135b234_Out_0_Float = _EMISSION_WEIGHT;
            float4 _Multiply_58182c51fe3ca8888fe37c35df7f9d5f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_d9ba77df91f297869e9c43f48c3cd415_Out_2_Vector4, (_Property_3bbca4a4925b0389a1b42d2ee135b234_Out_0_Float.xxxx), _Multiply_58182c51fe3ca8888fe37c35df7f9d5f_Out_2_Vector4);
            surface.BaseColor = (_Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4.xyz);
            surface.Emission = (_Multiply_58182c51fe3ca8888fe37c35df7f9d5f_Out_2_Vector4.xyz);
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
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
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
        float _BASE_COLOR_WEIGHT;
        float4 _BASE_COLOR;
        float4 _BASE_COLOR_MAP_TexelSize;
        float _REFLECTIONS_WEIGHT;
        float4 _REFLECTIONS_COLOR;
        float4 _REFLECTIONS_COLOR_MAP_TexelSize;
        float _REFLECTIONS_ROUGHNESS;
        float4 _REFLECTIONS_ROUGHNESS_MAP_TexelSize;
        float _METALNESS;
        float4 _METALNESS_MAP_TexelSize;
        float _REFLECTIONS_IOR;
        float4 _REFLECTIONS_IOR_MAP_TexelSize;
        float _TRANSPARENCY;
        float4 _TRANSPARENCY_MAP_TexelSize;
        float _EMISSION_WEIGHT;
        float4 _EMISSION_COLOR;
        float4 _EMISSION_COLOR_MAP_TexelSize;
        float _BUMP_MAP_STRENGTH;
        float4 _BUMP_MAP_TexelSize;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BASE_COLOR_MAP);
        SAMPLER(sampler_BASE_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_COLOR_MAP);
        SAMPLER(sampler_REFLECTIONS_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_ROUGHNESS_MAP);
        SAMPLER(sampler_REFLECTIONS_ROUGHNESS_MAP);
        TEXTURE2D(_METALNESS_MAP);
        SAMPLER(sampler_METALNESS_MAP);
        TEXTURE2D(_REFLECTIONS_IOR_MAP);
        SAMPLER(sampler_REFLECTIONS_IOR_MAP);
        TEXTURE2D(_TRANSPARENCY_MAP);
        SAMPLER(sampler_TRANSPARENCY_MAP);
        TEXTURE2D(_EMISSION_COLOR_MAP);
        SAMPLER(sampler_EMISSION_COLOR_MAP);
        TEXTURE2D(_BUMP_MAP);
        SAMPLER(sampler_BUMP_MAP);
        
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
        // GraphFunctions: <None>
        
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
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
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
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
        float _BASE_COLOR_WEIGHT;
        float4 _BASE_COLOR;
        float4 _BASE_COLOR_MAP_TexelSize;
        float _REFLECTIONS_WEIGHT;
        float4 _REFLECTIONS_COLOR;
        float4 _REFLECTIONS_COLOR_MAP_TexelSize;
        float _REFLECTIONS_ROUGHNESS;
        float4 _REFLECTIONS_ROUGHNESS_MAP_TexelSize;
        float _METALNESS;
        float4 _METALNESS_MAP_TexelSize;
        float _REFLECTIONS_IOR;
        float4 _REFLECTIONS_IOR_MAP_TexelSize;
        float _TRANSPARENCY;
        float4 _TRANSPARENCY_MAP_TexelSize;
        float _EMISSION_WEIGHT;
        float4 _EMISSION_COLOR;
        float4 _EMISSION_COLOR_MAP_TexelSize;
        float _BUMP_MAP_STRENGTH;
        float4 _BUMP_MAP_TexelSize;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BASE_COLOR_MAP);
        SAMPLER(sampler_BASE_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_COLOR_MAP);
        SAMPLER(sampler_REFLECTIONS_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_ROUGHNESS_MAP);
        SAMPLER(sampler_REFLECTIONS_ROUGHNESS_MAP);
        TEXTURE2D(_METALNESS_MAP);
        SAMPLER(sampler_METALNESS_MAP);
        TEXTURE2D(_REFLECTIONS_IOR_MAP);
        SAMPLER(sampler_REFLECTIONS_IOR_MAP);
        TEXTURE2D(_TRANSPARENCY_MAP);
        SAMPLER(sampler_TRANSPARENCY_MAP);
        TEXTURE2D(_EMISSION_COLOR_MAP);
        SAMPLER(sampler_EMISSION_COLOR_MAP);
        TEXTURE2D(_BUMP_MAP);
        SAMPLER(sampler_BUMP_MAP);
        
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
        // GraphFunctions: <None>
        
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
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
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
        Blend One Zero
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
        float _BASE_COLOR_WEIGHT;
        float4 _BASE_COLOR;
        float4 _BASE_COLOR_MAP_TexelSize;
        float _REFLECTIONS_WEIGHT;
        float4 _REFLECTIONS_COLOR;
        float4 _REFLECTIONS_COLOR_MAP_TexelSize;
        float _REFLECTIONS_ROUGHNESS;
        float4 _REFLECTIONS_ROUGHNESS_MAP_TexelSize;
        float _METALNESS;
        float4 _METALNESS_MAP_TexelSize;
        float _REFLECTIONS_IOR;
        float4 _REFLECTIONS_IOR_MAP_TexelSize;
        float _TRANSPARENCY;
        float4 _TRANSPARENCY_MAP_TexelSize;
        float _EMISSION_WEIGHT;
        float4 _EMISSION_COLOR;
        float4 _EMISSION_COLOR_MAP_TexelSize;
        float _BUMP_MAP_STRENGTH;
        float4 _BUMP_MAP_TexelSize;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BASE_COLOR_MAP);
        SAMPLER(sampler_BASE_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_COLOR_MAP);
        SAMPLER(sampler_REFLECTIONS_COLOR_MAP);
        TEXTURE2D(_REFLECTIONS_ROUGHNESS_MAP);
        SAMPLER(sampler_REFLECTIONS_ROUGHNESS_MAP);
        TEXTURE2D(_METALNESS_MAP);
        SAMPLER(sampler_METALNESS_MAP);
        TEXTURE2D(_REFLECTIONS_IOR_MAP);
        SAMPLER(sampler_REFLECTIONS_IOR_MAP);
        TEXTURE2D(_TRANSPARENCY_MAP);
        SAMPLER(sampler_TRANSPARENCY_MAP);
        TEXTURE2D(_EMISSION_COLOR_MAP);
        SAMPLER(sampler_EMISSION_COLOR_MAP);
        TEXTURE2D(_BUMP_MAP);
        SAMPLER(sampler_BUMP_MAP);
        
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
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
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
            float3 BaseColor;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BASE_COLOR_MAP);
            float4 _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.tex, _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.samplerstate, _Property_9d17cbb6439aca85a24988a0a8b99551_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_R_4_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.r;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_G_5_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.g;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_B_6_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.b;
            float _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_A_7_Float = _SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4.a;
            float4 _Property_15861e58e3f6bb879519e3649781db96_Out_0_Vector4 = _BASE_COLOR;
            float4 _Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_ba9bc922f95df0839bda10d1a99ca268_RGBA_0_Vector4, _Property_15861e58e3f6bb879519e3649781db96_Out_0_Vector4, _Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4);
            float _Property_e0552345c111ee80a0adc278159e6477_Out_0_Float = _BASE_COLOR_WEIGHT;
            float4 _Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_6c64c5333693798c83f4416ebeecd08c_Out_2_Vector4, (_Property_e0552345c111ee80a0adc278159e6477_Out_0_Float.xxxx), _Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4);
            UnityTexture2D _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_METALNESS_MAP);
            float4 _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.tex, _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.samplerstate, _Property_d2f1c8bc06dba98ea480cf25af4f4fe9_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_R_4_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.r;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_G_5_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.g;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_B_6_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.b;
            float _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_A_7_Float = _SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4.a;
            float _Property_3c20033bbb7f108d9458f3b347a29334_Out_0_Float = _METALNESS;
            float4 _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_77815abe08c5fc858b9cb0f7c8051e1e_RGBA_0_Vector4, (_Property_3c20033bbb7f108d9458f3b347a29334_Out_0_Float.xxxx), _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4);
            float4 _Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4;
            Unity_Lerp_float4(_Multiply_2ecea188399960828cf70e47d4692e33_Out_2_Vector4, float4(0, 0, 0, 0), _Multiply_036554f181704c8790bbeb19225c76a2_Out_2_Vector4, _Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4);
            surface.BaseColor = (_Lerp_f9719ca4b513268a9c70de0cecb23d94_Out_3_Vector4.xyz);
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