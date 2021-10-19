# MMDGenshin
Shader written for MMD to replicate the visual style of Genshin Impact

# Important
This is not the full shader but because my motivation is starting to waver, I'm releasing the shader as a beta for now. I will continue to work on it as normal.
This page could go down or change completely at any point.

## How to use 
1. Create a new folder inside of sub called tex.
   - This is where you'll put your metal and face shadow textures.
   - I won't provide any files. Theres are tutorials around for creating the kind of texture needed for the face.
2. Create a copy of the material_default.fx and change the settings for the model youre working on
3. In PMX Editor, put the ramp texture in the toon slot.
4. Put the lightmaps in the spa/sph slot and set the type to subtex for everything that isnt the face.
5. For the face, you will want to load the _shadow texture into the spa/sph slot instead and set it to either Add or Multu. 


## Rules 
- You may distribute your edited material files but do not repackage the entire original shader. That means only the .fx file you load into mmd should be shared.
- If you use this shader, you must write the shader name or mine somwhere where it is easily seen. 
- You are free to use this as a reference for your own shaders but just like above, credit me where it will be easily seen.

## Contact 
If you find any issues or have questions, feel free to create a new issue here or DM me on [Twitter](https://twitter.com/Manashiku) or on Discord ( mana#3458 ). 

## Resources
These were incredibly helpful
https://zhuanlan.zhihu.com/p/360229590
https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample
