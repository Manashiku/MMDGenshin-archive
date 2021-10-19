// global material and functions
float3 lightDirection : DIRECTION < string Object = "Light"; >;
float2 screenSize : VIEWPORTPIXELSIZE; // current screen size in pixels

float4x4 model_matrix : CONTROLOBJECT < string name = "(self)";>;
float4x4 head_bone : CONTROLOBJECT < string name = "(self)"; string item = "“ª"; >;
float4x4 neck_bone : CONTROLOBJECT < string name = "(self)"; string item = "Žñ"; >;
float4x4 center_bone : CONTROLOBJECT < string name = "(self)"; string item = "ƒZƒ“ƒ^["; >;
float blush_morph : CONTROLOBJECT < string name = "(self)"; string item = blush_facial; >; // this will be turned into a bool thats more responsive
float time_of_day : CONTROLOBJECT < string name = "genshin.pmx"; string item = "time of day"; >; // this will be turned into a bool thats more responsive

float4x4 mirror_world : CONTROLOBJECT < string name = "(self)"; >;

// MATERIAL COLOR :
float4 materialDiffuse : DIFFUSE < string Object  = "Geometry"; >;
float4 materialAmbient : AMBIENT < string Object  = "Geometry"; >;
float4 materialEmissive : EMISSIVE < string Object = "Geometry"; >;
float3 lightDiffuse : DIFFUSE < string Object  = "Light"; >;
float3 lightAmbient : AMBIENT < string Object  = "Light"; >;
static float4 modelDiffuse = materialDiffuse * float4(lightDiffuse, 1.0);
static float4 modelAmbient = saturate(materialAmbient * float4(lightAmbient, 1.0) + materialEmissive);
static float4 modelColor = saturate(modelAmbient + modelDiffuse); // this final model color will be multiplied by the diffuse texture

//==============================================================================================

float camera_fov()
{
    float t = mmd_projection[1].y; // get the fov from the projection matrix
    float Rad2Deg = 180 / 3.1415;
    float fov = atan(1.0f / t) * 2.0 * Rad2Deg;
    return fov;
}

float3 outline(float3 pos, float3 camera_pos, float3 normal, float outline_rate, float outline_threshold)
{
    // combined outline scaling approach
    // uses outline scaled based on distance from camera, screen size, and current frames fov
    float3 world_pos = mul(pos, mmd_world);
    float dist = distance(camera_pos, world_pos) / screenSize.y; 
    float fov = camera_fov();
    #ifndef use_fov_scale
    fov = 1;
    #endif
    float expand = dist * outline_threshold * outline_rate *fov;
    pos = pos.xyz + normalize(normal) * expand;// * adjust_outline_width;
    return pos;
}

float3 outlineRGB2Float(float3 color)
{
    #ifdef outline_color_rgb2float
    color = color / 255;
    #endif
    return color;
}

float3 outline_color_from_materialID(float alpha)
{   

    // float3 skin = step(abs(alpha  * 255 - 255),  30) * outlineRGB2Float(outline_color_0.rgb);
    // float3 tight = step(abs(alpha * 255 - 179 ), 30) * outlineRGB2Float(outline_color_1.rgb);
    // float3 soft = step(abs(alpha  * 255 - 77),   30) * outlineRGB2Float(outline_color_2.rgb);
    // float3 hard = step(abs(alpha  * 255 - 0),    30) * outlineRGB2Float(outline_color_3.rgb);
    // float3 metal = step(abs(alpha * 255 - 126),  30) * outlineRGB2Float(outline_color_4.rgb);

    float3 outline = outlineRGB2Float(outline_color_0.rgb);
    if(0.4 > alpha && alpha > 0.2)
    {
        outline = outlineRGB2Float(outline_color_1.rgb);
    }
    if(0.6 > alpha && alpha > 0.4)
    { 
        outline = outlineRGB2Float(outline_color_2.rgb);
    }
    if(0.8 > alpha && alpha > 0.6)
    {
        outline = outlineRGB2Float(outline_color_3.rgb);
    }
    if(alpha > 0.8)
    {
        outline = outlineRGB2Float(outline_color_4.rgb);
    }

    // float3 outline = skin + tight + soft + hard + metal;
    return outline;
}

float3 debug_visualize_material_regions(float alpha)
{ 
    float3 A = step(abs(alpha  * 255 - 255),  30) * float3(1.0, 0.0, 0.0);
    float3 B = step(abs(alpha * 255 - 179 ), 30) * float3(0.0, 1.0, 0.0);
    float3 C = step(abs(alpha  * 255 - 77),   30) * float3(0.0, 0.0, 1.0);
    float3 D = step(abs(alpha  * 255 - 0),    30) * float3(1.0, 0.0, 1.0);
    float3 E = step(abs(alpha * 255 - 126),  30) * float3(1.0, 1.0, 0.0);

    float3 color = A + B + C + D + E;
    return color;
}

float4 calculate_ground_shadow(float4 pos)
{
    // i only wrote this in because the face shadow has a sweet spot that ends up making the standard mmd ground shadow very very lonh
    lightDirection.y = -1;
    float scaling_matrix  = length(mirror_world._11_12_13);
    float scaling_inverse = 1.0 / scaling_matrix;
    float3x3 inverse_matrix = transpose((float3x3)mirror_world) * scaling_inverse;
    float4x4 inverse_world = float4x4(inverse_matrix[0],0,
                                      inverse_matrix[1],0, 
                                      inverse_matrix[2],0,
                                      -mul(mirror_world._41_42_43, inverse_matrix),1);
    float3 planar_position = mirror_world._41_42_43;
    float3 planar_normal   = mul(float3(0.0, 1.0, 0.0), (float3x3)mirror_world);
    float scale            = length(mirror_world._11_12_13) * 0.1;

    float3 light_position = pos.xyz + (lightDirection);
    float A = dot(planar_normal, planar_position - light_position);
    float B = dot(planar_normal, pos.xyz - planar_position);
    float C = dot(planar_normal, pos.xyz - light_position);
    pos = float4(pos.xyz * A + light_position * B, C) * 0.5;
    pos = mul(pos, inverse_world);
    pos.y = 0.0;
    return pos;
}

float2 sphereUV(float3 normal) // based on sphere mapping article on microsoft website
{
    float2 uv;
    normal = mul(normal, (float3x3) mmd_view); // camera space vertex normals
    normal.x = (normal.x / 2) + 0.5; // add the bias to set the zero-distortion point at the center of the sphere map
    normal.y = (normal.y / 2) + 0.5;
    normal.y = -normal.y; // invert y axis to correct the flipped image 
    // while this is a different formula for sphere mapping than the one typically used for mmd 
    // it produces virtually identical results with maybe a 0.1% error
    uv = normal.xy; // move edited normals to uv variable
    uv = uv * metal_scale;
    return uv; // output final uv coordinates
}

float calculate_ndotl(float2 uv, float3 normal)
{
    // if(!use_subtexture)
    // {
    //     lightDirection.y = 0;
    // }
    float3 light_direction = (lightDirection);
    // the other shaders ive seen just do normalize(lightdirection) here but ive actually found
    // that mmds light misbehaves in the fdotl part so i just normalize it only in rdotl
   
    // sample face shadows 
    float shadow_right = tex2D(faceSampler, float2(      uv.x, uv.y));
    float shadow_left  = tex2D(faceSampler, float2(1.0 - uv.x, uv.y));

    // get forward and right directions of head bone
    float3 head_right  = head_bone._11_12_13; 
    float3 head_foward = head_bone._31_32_33; 
    // i originally got the bone directions based on how unity gets them for scripting
    // but that was actually breaking it
    // so just get the directions directly from the bone matrix
    
    // calculate dot products
    float rdotl = dot(normalize(head_right.xz),      -normalize(light_direction.xz));
    float fdotl = dot(normalize(head_foward.xz),     -light_direction.xz);

    // calculate light angle
    float angle = ( acos(rdotl) / 3.14159 ) * 2;
    
    // initialize shadow
    float shadow = 1.0; // if i dont do this, the if statement breaks shadow

    shadow_right = saturate(pow(abs(shadow_right), face_shadow_pow));
    shadow_left  = saturate(pow(abs(shadow_left),  face_shadow_pow));
    // if rdotl is greater than 0, use the right shadow map and do 1 minus the angle
    // else, use the left shadow map and do angle minus 1
    if(rdotl > 0)
    {
        angle = 1.0 - angle;
        shadow = shadow_right;
    }  
    else
    {
        angle = angle - 1.0;
        shadow = shadow_left;
    }
    
    // finally, compare angle to shadow and then compare fdotl to 0
    // the shadow_step will be used as the x vector of the ramp coordinates
    // multiply shadow_step by facing_step to get corrected facing direction
    float shadow_step = step(angle, shadow);
    if(angle > shadow)
    {
        shadow_step = 0;
    } 
    else
    {
        shadow_step = 1;
    }
    float facing_step = step(fdotl, 0);
    
    shadow_step = shadow_step * facing_step;
    float ndotl = dot(normal, -lightDirection);
    if(!use_subtexture && use_spheremap) // instead of relying on too many material.fx files, take advantage of the 3 spa types to toggle things on and off
    {
        return saturate(shadow_step );
    } else
    {
        return saturate((ndotl * 0.5 + 0.5));
    }
}

float3 new_ramp_function(float2 uv, float alpha, float green, float3 normal, float vertex_ao)
{
    float ndotl = calculate_ndotl(uv, normal);//;
    float black_lines = 1.0;
    if(green < 0.2)
    {   
        if(use_subtexture) 
        // Check if MMD subtexture flag set on material. This probably isnt needed if writing for a 
        // different engine but this is the only way i can keep the control.fx line count down
        {
            black_lines = 0;
        }
    } 
    ndotl = (ndotl  * vertex_ao * black_lines); // fix ndotl area to use vertex ao and only the pure black from light ao
    float ramp_ndotl = saturate(ndotl * (1.0 / shadow_rate - 0.003)); // adjust the size to eliminate any odd areas

    //ramp_ndotl = min(green, ramp_ndotl);
    float2 ramp_uv[10] = { // create array with the coords to use for the ramp
                           float2(ramp_ndotl, 0.05),
                           float2(ramp_ndotl, 0.15),
                           float2(ramp_ndotl, 0.25),
                           float2(ramp_ndotl, 0.35),
                           float2(ramp_ndotl, 0.45),
                           float2(ramp_ndotl, 0.55),
                           float2(ramp_ndotl, 0.65),
                           float2(ramp_ndotl, 0.75),
                           float2(ramp_ndotl, 0.85),
                           float2(ramp_ndotl, 0.95)
                         }; // ramp_uv.y = uv position on y axis [0-1]
    // sample all sections from the ramp
    float3 warm_ramp_1 = tex2D(rampSampler, ramp_uv[0]);
    float3 warm_ramp_2 = tex2D(rampSampler, ramp_uv[1]);
    float3 warm_ramp_3 = tex2D(rampSampler, ramp_uv[2]);
    float3 warm_ramp_4 = tex2D(rampSampler, ramp_uv[3]);
    float3 warm_ramp_5 = tex2D(rampSampler, ramp_uv[4]);
    float3 cool_ramp_1 = tex2D(rampSampler, ramp_uv[5]);
    float3 cool_ramp_2 = tex2D(rampSampler, ramp_uv[6]);
    float3 cool_ramp_3 = tex2D(rampSampler, ramp_uv[7]);
    float3 cool_ramp_4 = tex2D(rampSampler, ramp_uv[8]);
    float3 cool_ramp_5 = tex2D(rampSampler, ramp_uv[9]);

    float3 ramp[10] = { warm_ramp_1, warm_ramp_2, warm_ramp_3, warm_ramp_4, warm_ramp_5, cool_ramp_1, cool_ramp_2, cool_ramp_3, cool_ramp_4, cool_ramp_5}; // array of all ramps
  
    // the old way i did this gave material regions very ugly borders
    // i was looking at something honkai related and figured it might work for genshin
    float3 warm = ramp[material_ramp_0];
    float3 cool = ramp[material_ramp_0 + 5]; // move up 5 to get the cool color
    if(0.4 > alpha && alpha > 0.2)
    {
        warm = ramp[material_ramp_1];
        cool = ramp[material_ramp_1 + 5];
    }
    else if(0.6 > alpha && alpha > 0.4)
    { 
        warm = ramp[material_ramp_2];
        cool = ramp[material_ramp_2 + 5];
    }
    else if(0.8 > alpha && alpha > 0.6)
    {
        warm = ramp[material_ramp_3];
        cool = ramp[material_ramp_3 + 5];
    }
    else if(alpha > 0.8)
    {
        warm = ramp[material_ramp_4];
        cool = ramp[material_ramp_4 + 5];
    }

    float3 finalRamp = lerp(warm, cool, time_of_day); // finally, lerp between warm and cool depending on time_of_day slider
    return finalRamp; // output final ramp color
}

float3 specular_shading(float3 view, float3 normal, float blue, float alpha)
{   
    // get corrected specular power/shininess and rate based on material regions
    // from alpha channel of the lightmap texture
    // initialize both power and rate with the values for the regions that are < 0.2
    float power = specular_power_0;
    float rate  = specular_rate_0;
    if(0.4 > alpha && alpha > 0.2) 
    {
        float power = specular_power_1;
        float rate  = specular_rate_1;
    }
    else if(0.6 > alpha && alpha > 0.4)
    { 
        float power = specular_power_2;
        float rate  = specular_rate_2;
    }
    else if(0.8 > alpha && alpha > 0.6)
    {
        float power = specular_power_3;
        float rate  = specular_rate_3;
    }
    else if(alpha > 0.8)
    {
        float power = specular_power_4;
        float rate  = specular_rate_4;
    }

    float3 half_vector = normalize(-lightDirection + view); // half vector
    // take inverse of lightDirection to point it the right way

    // dot product of the normal and half vector
    float ndoth = pow(dot(normal, half_vector), power / blue);
    #ifdef use_toon_specular
    ndoth = smoothstep(0.19, 0.2, ndoth);
    #endif
    ndoth = min(ndoth, blue);
    // unlike the power and rate, theres only one specular color for all the materials
    // but this can very easily be expanded to be the same
    return specular_color.rgb * ndoth * rate;
}

float3 rim_shading(float3 view, float3 normal, float rim_mask)
{
    float ndotv = dot(normal, view); 
    ndotv = saturate(1.0 - ndotv); 
    float normal_multi = 1;
    #ifndef use_standard //
    normal_multi = normal.y;
    #endif
    //                            v this is to make it thicker and the edge of it sharper
    ndotv = saturate(pow(ndotv * rim_thickness, rim_softness) * saturate(normal_multi)); 
    // i originally intended for this to not be user controlled
    // but i feel for some things you might want a softer rim 
    // this is a neat trick i learned from working on the love live arcade shader
    // you multiply ndotv by the y vector from the normal in order to point it upward a bit
    // it makes it look nicer but its not accurate to the original game
    // so theres the option to opt out of it instead
    float3 rim = lerp(0,rim_color.rgb * ndotv * rim_color.a, ndotv);
    return rim_color.rgb * ndotv * rim_color.a ;
}

float3 metal_shading(sampler metal_sampler, float3 normal, float metal_mask, float shadow)
{
    // sample metal texture
    float matcap = tex2D(metal_sampler, sphereUV(normal * metal_mask));
    float area = 0; // starting area is 0
    if(metal_mask > 0.75)
    {
        area = metal_mask; // because of weird hard edges, setting area to metal_mask reduces them
    }

    float3 metal = lerp(metal_dark_color, metal_light_color, matcap) * metal_specular;
    metal = lerp(metal * metal_in_shadow, metal, shadow);
    metal = lerp(1.0, metal, area);
    return  metal;
}

float3 make_blush(float mask)
{ 
    float blush_rate = blush_morph * blush_strength; // set maximum strength
    return lerp(1, blush_color, mask * blush_rate); // this will be multiplied over the base diffuse color
}
