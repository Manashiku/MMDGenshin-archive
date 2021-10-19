// TEXTURES : 
texture2D diffuseTexture : MATERIALTEXTURE;
texture2D lightmapTexture : MATERIALSPHEREMAP ;
texture2D rampTexture     : MATERIALTOONTEXTURE;


#define merge(a,b) a##b // simple macro for merging things
texture2D faceTexture : TEXTURE < string ResourceName = merge("sub/tex/", face_tex_name); >;
texture2D metalTexture : TEXTURE < string ResourceName = "sub/tex/Avatar_Tex_MetalMap.png"; >;

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
