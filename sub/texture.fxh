// TEXTURES : 
texture2D diffuseTexture : MATERIALTEXTURE;
texture2D lightmapTexture : MATERIALSPHEREMAP ;
texture2D rampTexture     : MATERIALTOONTEXTURE;


#define merge(a,b) a##b // simple macro for merging things
texture2D faceTexture : TEXTURE < string ResourceName  = merge("sub/tex/", face_tex_name);  >;
texture2D metalTexture : TEXTURE < string ResourceName = merge("sub/tex/", metal_tex_name); >;
#ifdef get_lightmap_red_from_separate_image
texture2D lightmap_red_tex : TEXTURE < string ResourceName  = merge("sub/tex/", get_lightmap_red_from_separate_image);  >;
#endif
#ifdef get_lightmap_green_from_separate_image
texture2D lightmap_green_tex : TEXTURE < string ResourceName  = merge("sub/tex/", get_lightmap_green_from_separate_image);  >;
#endif
#ifdef get_lightmap_blue_from_separate_image
texture2D lightmap_blue_tex : TEXTURE < string ResourceName  = merge("sub/tex/", get_lightmap_blue_from_separate_image);  >;
#endif
#ifdef get_lightmap_alpha_from_separate_image
texture2D lightmap_alpha_tex : TEXTURE < string ResourceName  = merge("sub/tex/", get_lightmap_alpha_from_separate_image);  >;
#endif

// =============================================================
// SAMPLERS : 
sampler diffuseSampler = sampler_state
{
    texture = <diffuseTexture>;
    //SRGBTexture = true;
    FILTER = ANISOTROPIC;
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
};
sampler lightSampler = sampler_state
{
    texture = <lightmapTexture>;
    // SRGBTexture = true;
    FILTER = ANISOTROPIC;
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
};

#ifdef get_lightmap_red_from_separate_image
sampler light_redSampler = sampler_state
{
    texture = <lightmap_red_tex>;
    FILTER = ANISOTROPIC;
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
};
#endif
#ifdef get_lightmap_green_from_separate_image
sampler light_greeenSampler = sampler_state
{
    texture = <lightmap_green_tex>;
    FILTER = ANISOTROPIC;
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
};
#endif
#ifdef get_lightmap_blue_from_separate_image
sampler light_blueSampler = sampler_state
{
    texture = <lightmap_blue_tex>;
    FILTER = ANISOTROPIC;
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
};
#endif
#ifdef get_lightmap_alpha_from_separate_image
sampler light_alphaSampler = sampler_state
{
    texture = <lightmap_alpha_tex>;
    FILTER = ANISOTROPIC;
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
};
#endif

sampler rampSampler = sampler_state
{
    texture = <rampTexture>;
    
    FILTER = NONE;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
};
sampler faceSampler = sampler_state
{
    texture = <faceTexture>;
    
    FILTER = ANISOTROPIC;
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
};



sampler metalSampler = sampler_state
{
    texture = <metalTexture>;
    FILTER = ANISOTROPIC;
    ADDRESSU = WRAP;
    ADDRESSV = WRAP;
};
