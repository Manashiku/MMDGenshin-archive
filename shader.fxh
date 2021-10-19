// =================================================================================================//
//                                GENSHIN IMPACT REPLICA SHADER  v0.1                               //
// =================================================================================================//
// Genshin Impact style shading recreated for MMD using HLSL by Manashiku                           //
//  File : main.fxsub
//  Date : 8/3/2021                                                                                 //
// =================================================================================================//
#include "header.fxh"
//==============================================================================================================//
// STRUCTS :
struct vs_out
{
    float4 pos    : POSITION;
    float4 uv     : TEXCOORD0; // uv / texture coordinates, xy = uv1 zw = uv2
    float3 normal : TEXCOORD1; // world space normals
    float4 vertex : TEXCOORD2; // vertex color
    float3 view   : TEXCOORD3; // view vector
};

struct edge_out
{
    float4 pos : POSITION;
    float2 uv  : TEXCOORD0;
    float4 vertex : TEXCOORD1;
};

struct shadow_out
{
    float4 pos : POSITION;
    float2 uv : TEXCOORD0;
};
//==============================================================================================================//
// VERTEX :
vs_out vs_0(float4 pos : POSITION, float3 normal : NORMAL, float4 vertexColor : TEXCOORD2, float2 uv : TEXCOORD0, float2 uv2 : TEXCOORD1)
{
    vs_out o;
    o.pos = mul(pos, mmd_world_view_projection);
    o.normal = normal;
    o.uv = float4(uv,uv2);
    o.vertex = vertexColor;
    o.view = cameraPosition - mul(pos.xyz, (float3x3)mmd_world);
    // o.pos = calculate_ground_shadow(pos);
    // o.pos = mul(o.pos, vpMatrix());
    return o;
}

edge_out edge_vs(float4 pos : POSITION, float3 normal : NORMAL, float4 vertexColor : TEXCOORD2, float2 uv : TEXCOORD0)
{
    edge_out o;
    float3 camera = cameraPosition - mul(pos.xyz, (float3x3)mmd_world);
    pos.xyz = outline(pos, cameraPosition, normal, outline_thickness,  vertexColor.a) ;
    o.pos = mul(pos, mmd_world_view_projection);
    o.uv = uv;
    o.vertex = vertexColor;
    return o;
}

shadow_out vs_gs(float4 pos : POSITION, float2 uv : TEXCOORD0)
{
    shadow_out o;
    o.pos = calculate_ground_shadow(pos);
    o.pos = mul(o.pos, mmd_view_projection);
    o.uv = uv;
    return o;
}

//==============================================================================================================//
// PIXEL : 
float4 ps_0(vs_out i, float side : VFACE, uniform bool use_uv2) : COLOR0
{
    // INITIALIZE INPUTS : 
    float2 uv = i.uv; 
    if(use_uv2)
    {
        uv = i.uv.zw;
    }
    float3 normal = normalize(i.normal);
    float4 color = modelColor;
    normal.z *= side;
    //normal = face_normal(faceSampler, normal, uv);

    // DOT PRODUCTS : 
    float ndotl = dot(normal, -lightDirection) * 0.5  + 0.5;

    // SAMPLE TEXTURES : 
    float4 diffuse = tex2D(diffuseSampler, uv);
    float4 light   = tex2D(lightSampler, uv);
    // theres probably a way smarter way to do this but im not smart
    float light_remove = light.g;
    if(light.g > 0.8)
    {
        light_remove = 1;
    }
    float rim_light_highlight = light.r;
    float rate = shadow_rate;
    if(!use_subtexture)
    {
        light_remove = light.a;
        if(light_remove > 0.2) light_remove = 1.0;
        light.rba = float3(0,0,1);
        rate = 0;
    }
    float black_lines = 1;
    if(light.g < 0.2) // same thing from the ramp function but this time to avoid harsh line at the borders, set black_lines to light.g
    {
        if(use_subtexture)
        {
            black_lines = light.g;
        }
    }
    float ramp_ndotl = calculate_ndotl(uv, normal);
    ramp_ndotl = ramp_ndotl * i.vertex.r * saturate(side); // saturate(side) is the VFACE value clamped
    float ramp_value = step(shadow_rate, ramp_ndotl); // compare shadow_rate and ramp_ndotl
    ramp_value = max(ramp_value, saturate(pow(light_remove,5))); // get the greater value between the two 
    ramp_value = ramp_value * black_lines;
    
    // TOON RAMP
    float3 toon = new_ramp_function(uv, light.a, light.g*side, normal, i.vertex.r);

    // SPECULAR 
    float3 specular = specular_shading(normalize(i.view), normal, light.b, light.a); 

    // RIM
    float3 rim_in_light  = rim_shading(normalize(i.view), normal, i.vertex.g * rim_light_highlight );
    float3 rim = rim_in_light;

    // METAL
    float3 metal = metal_shading(metalSampler, normal, light.r, ramp_value);

    // PROCESS COLOR : 
    color.rgb = color.rgb * diffuse.rgb;
    #ifdef use_specular
    color.rgb = color.rgb + specular ;
    #endif 
    #ifdef use_rim
    if(!use_subtexture && light_remove > 0.2) rim = 0;
    color.rgb = color.rgb + rim;
    #endif
    #ifdef use_metal
    color.rgb = color.rgb * metal;
    #endif

    color.rgb = lerp(color * toon, color, ramp_value);

    #ifdef is_glow
    color.rgb = diffuse.rgb * diffuse.a * glow_color;
    #endif

    if(!use_subtexture)
    {
        color.rgb = color.rgb * make_blush(diffuse.a);
    }
    return color;
}


float4 edge_ps(edge_out i) : COLOR0
{
    // initailize inputs
    float2 uv = i.uv;
    // sample textures 
    float4 diffuse = float4(tex2D(diffuseSampler, uv).rgb,1.0);
    float light_alpha = tex2D(lightSampler, uv).a;
    if(!use_subtexture)
    {
        light_alpha = 1; // since the shadow tex is packed different than the light tex, this works
    }
    // use controlled outline color 
    float4 outline_color = float4(outlineRGB2Float(outline_color_0.rgb),outline_color_0.a);
    #ifdef  use_lightmap_alpha_for_material_region
    outline_color = float4(outline_color_from_materialID(light_alpha),1);
    #endif
    #ifdef use_diffuse_texture
    diffuse.rgb = pow(abs(diffuse)*0.9, 3);
    #else
    diffuse = 1;
    #endif
    float4 final_color = outline_color * modelColor; // modelColor is used to make the outline dark with the rest of the model when the light is turned down
    // it also helps with any parts that are set to have a non-zero alpha in pmxe
    #ifdef use_diffuse_texture
    final_color = diffuse;
    #endif
    return final_color;
}

float4 ps_gs() : COLOR0
{
    return float4(0.25, 0.25, 0.25, 1.0);
}

//==============================================================================================================//
// TECH
technique tech_0 < string MMDPass = "object_ss"; >
{
      
    pass modelDraw
    {
        cullmode = ccw;
        VertexShader = compile vs_3_0 vs_0();
        PixelShader = compile ps_3_0 ps_0(false);
    }
    #ifndef is_glow
    #ifdef is_double_sided
    pass flippedDraw
    {
        cullmode = cw;
        VertexShader = compile vs_3_0 vs_0();
        #ifdef use_second_uv
        PixelShader = compile ps_3_0 ps_0(true);
        #else
        PixelShader = compile ps_3_0 ps_0(false);
        #endif
    }
    #endif
    #ifdef use_outline
    pass edgeDraw
    {
        cullmode = cw;
        VertexShader = compile vs_3_0 edge_vs();
        PixelShader = compile ps_3_0 edge_ps();
    }
    #endif
    #ifdef use_custom_ground_shadow
     pass shadowDraw
    {
        cullmode = none;
        VertexShader = compile vs_3_0 vs_gs();
        PixelShader = compile ps_3_0 ps_gs();
    }
    #endif
    #endif
}
#ifdef is_glow
#endif

technique tech_1 < string MMDPass = "object"; >
{
    pass modelDraw
    {
        cullmode = none;
        VertexShader = compile vs_3_0 vs_0();
        PixelShader = compile ps_3_0 ps_0(false);
    }
}