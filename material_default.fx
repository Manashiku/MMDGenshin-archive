// =================================================================================================//
//                                GENSHIN IMPACT REPLICA SHADER  v0.1                               //
//                         Date : 8/23/2021                  Updated :                              //
// =================================================================================================//
// This is the material options for the shader. It's recommended to make multiple copies of this    //
// and edit it those and to save the original one. For the most part you won't actually have to..   //
// Unless you need to add the back side of a material or something..                                //
// This one is specifically for the characters because the environments use a different type of     //
// shader in game.                                                                                  //
// =================================================================================================//
// OPTIONS : 
// #define exported_from_noesis // this is important because theres really important data that will be missing
// if it wasnt and it will mess up how it is rendered
// Culling
#define is_double_sided 
    // #define use_second_uv // use secondary uv as texture coordinates for flipped faces (double side)
    
// Face options : 
#define face_tex_name "Avatar_Male_Tex_FaceLightmap.png" 
// put the face light map in the tex folder in sub and just write the name of it as a string on face_tex_name so like "texturename.extension"

// Shadow options :
#define face_shadow_pow 0.5 // controls the change speed of the shadow when the light faces the middle of the face
#define shadow_rate 0.5 
// changes shadow scale
// choose between 0-4, check the ramps to figure out which ones to use
#define material_ramp_0 0 
#define material_ramp_1 0
#define material_ramp_2 2
#define material_ramp_3 1
#define material_ramp_4 1
// defaults are: a = 1 b = 4 c = 0 d = 2 e = 3
// youll actuall have to play around with these for each model and material since 
// regions arent consistent between models
// some only use a few
// and other use all 5
// there may be a 1-2 value error but these are close enough
// #define use_custom_ground_shadow
// tbh this is probably only useful if youre like me and dont load stages 

// Specular options : 
#define use_specular 
#define use_toon_specular // use this for the hard edge specular highlights
// specular color
#define specular_color float4(1.0, 1.0, 1.0, 1.0) 
// specular power/ shininess
#define specular_power_0 6 
#define specular_power_1 10 
#define specular_power_2 10 
#define specular_power_3 10 
#define specular_power_4 10 
// specular rate/multi/intensity
#define specular_rate_0 0.0500000007 
#define specular_rate_1 0.0769999996
#define specular_rate_2 0.100001 
#define specular_rate_3 0.100001
#define specular_rate_4 0.100001

// Blush options : 
#define blush_strength 0.2 // max strength, for things that dont use blush set this to 0
#define blush_facial "blush" // name of facial for blush
#define blush_color float4(1.0, 0.0620689243, 0.0, 1.0)

// Glow options : 
// #define is_glow
#define glow_color float4(1.0, 1.0, 1.0, 1.0)

// Outline options : 
// #define use_outline
#define outline_thickness 1.0
// #define use_fov_scale // if you plan on making any renders with perspective off, turn this off
// you will also need to change the outline_thickness accordingly
// #define use_diffuse_texture // use diffuse texture to calculate outline color 
#define use_lightmap_alpha_for_material_region 
// in the same way the alpha channel in the lightmap is used for getting material regions for the ramps
// this will give you more control over what colors certain parts use
// #define outline_color_rgb2float // this will do the conversion from rgb values to float automatically for you
#define outline_color_0 float4(0.161764681, 0.108347729, 0.084450677, 1) // this is the only one thatll be used if you turn off lightmap use
#define outline_color_1 float4(0.625, 0.329191923, 0.303308785, 1)
#define outline_color_2 float4(0.257136673, 0.293339133, 0.426470578, 1)
#define outline_color_3 float4(1, 1, 1, 1)
#define outline_color_4 float4(0.625, 0.329191923, 0.303308785, 1)

// Rim options : 
#define use_rim
// #define use_standard
// turn off standard to use a rim thats been offset by the y normal vector, its a different look but not accurate
#define rim_thickness 1.5
#define rim_softness  5 // the higher the value the harder the rim edge is 
#define rim_color float4(1.0, 1.0, 1.0, 0.25) // rgb color, alpha intensity

// Metal options :
#define use_metal
#define metal_tex_name "dummy.png"
// put the metal texture in the tex folder in sub and just write the name of it as a string on metal_tex_name so like "texturename.extension"
#define metal_comp_test 0.85 // tests blue channel against this value to determine affected area for the metal matcap
#define metal_scale       float2(1.0, 1.0)
#define metal_dark_color  float4(0.514705896, 0.301276207, 0.193014711, 1.0)
#define metal_light_color float4(1.0, 1.0, 1.0, 1.0)
#define metal_specular    float4(1.0, 1.0, 1.0, 1.0)
#define metal_in_shadow   float4(0.784746528, 0.772549093, 0.815686345, 1.0) 

// =================================================================================================//
#include "shader.fxh"
