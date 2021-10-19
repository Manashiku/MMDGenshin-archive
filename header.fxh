#define alphaclip_threshold 0.5

bool use_subtexture;
bool use_spheremap;

float4 EgColor;
//=========================================================================

float4x4 mmd_world_view_projection : WORLDVIEWPROJECTION;
float4x4 mmd_view                  : VIEW;
float4x4 mmd_world                 : WORLD;
float4x4 mmd_view_projection       : VIEWPROJECTION;
float4x4 mmd_projection            : PROJECTION;

float3 cameraPosition : POSITION < string Object = "Camera"; >;
//=========================================================================
#ifndef is_genshin_x_file  
// seems silly to have all these load and process when its just the .x calling for the header
#include "sub/texture.fxh"
#include "sub/material.fxh"

#endif