#ifndef NEO_FUR_LIGHTING_INCLUDED
#define NEO_FUR_LIGHTING_INCLUDED

//#define NEO_FUR_SHADING_MODEL_STYLIZED

#ifdef NEO_FUR_SHADING_MODEL_STYLIZED
#include "NeoFurLightingStylized.cginc"
#else
#include "NeoFurLightingPBS.cginc"
//#include "NeoFurLightingPBSOB.cginc"
#endif

#endif
