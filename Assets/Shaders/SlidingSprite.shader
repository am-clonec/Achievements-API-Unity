Shader "Custom/SlidingSprite"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        // Scroll speed on X and Y axes (units per second)
        _ScrollSpeedX ("Scroll Speed X", Float) = 1.0
        _ScrollSpeedY ("Scroll Speed Y", Float) = 0.0

        // How many times the texture tiles across the sprite
        _TilingX ("Tiling X", Float) = 1.0
        _TilingY ("Tiling Y", Float) = 1.0

        // Standard sprite/UI toggles
        [MaterialToggle] PixelSnap ("Pixel Snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"           = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType"      = "Transparent"
            "PreviewType"     = "Plane"
            "CanUseSpriteAtlas" = "True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha   // Pre-multiplied alpha (matches Unity's sprite default)

        Pass
        {
            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            #pragma target   2.0
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA
            #include "UnitySprites.cginc"

            // ── Custom uniforms ──────────────────────────────────────────────
            float _ScrollSpeedX;
            float _ScrollSpeedY;
            float _TilingX;
            float _TilingY;

            // ── Vertex output ────────────────────────────────────────────────
            struct v2f_sliding
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // ── Vertex shader ────────────────────────────────────────────────
            v2f_sliding vert(appdata_t IN)
            {
                v2f_sliding OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
                OUT.vertex = UnityObjectToClipPos(OUT.vertex);

                OUT.texcoord = IN.texcoord;
                OUT.color    = IN.color * _Color * _RendererColor;

                #ifdef PIXELSNAP_ON
                OUT.vertex = UnityPixelSnap(OUT.vertex);
                #endif

                return OUT;
            }

            // ── Fragment shader ──────────────────────────────────────────────
            fixed4 frag(v2f_sliding IN) : SV_Target
            {
                // Apply tiling, then offset by time-driven scroll
                float2 uv = IN.texcoord * float2(_TilingX, _TilingY)
                          + float2(_ScrollSpeedX, _ScrollSpeedY) * _Time.y;

                // frac() makes the texture repeat infinitely
                uv = frac(uv);

                fixed4 c = SampleSpriteTexture(uv) * IN.color;

                #if ETC1_EXTERNAL_ALPHA
                    fixed4 alpha = UNITY_SAMPLE_TEX2D(_AlphaTex, uv);
                    c.a = lerp(c.a, alpha.r, _EnableExternalAlpha);
                #endif

                c.rgb *= c.a;   // pre-multiply
                return c;
            }
            ENDCG
        }
    }
}
