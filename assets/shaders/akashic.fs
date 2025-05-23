#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define MY_HIGHP_OR_MEDIUMP highp
#else
	#define MY_HIGHP_OR_MEDIUMP mediump
#endif

//watch shader Mods/FickleFox/assets/shaders/akashic.fs
extern MY_HIGHP_OR_MEDIUMP vec2 akashic;
extern MY_HIGHP_OR_MEDIUMP number dissolve;
extern MY_HIGHP_OR_MEDIUMP number time;
extern MY_HIGHP_OR_MEDIUMP vec4 texture_details;
extern MY_HIGHP_OR_MEDIUMP vec2 image_details;
extern bool shadow;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_1;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_2;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) {
        return vec4(shadow ? vec3(0.,0.,0.) : tex.xyz, shadow ? tex.a*0.3: tex.a);
    }

    float adjusted_dissolve = (dissolve*dissolve*(3.-2.*dissolve))*1.02 - 0.01;

	float t = time * 10.0 + 2003.;
	vec2 floored_uv = (floor((uv*texture_details.ba)))/max(texture_details.b, texture_details.a);
    vec2 uv_scaled_centered = (floored_uv - 0.5) * 2.3 * max(texture_details.b, texture_details.a);
	
	vec2 field_part1 = uv_scaled_centered + 50.*vec2(sin(-t / 143.6340), cos(-t / 99.4324));
	vec2 field_part2 = uv_scaled_centered + 50.*vec2(cos( t / 53.1532),  cos( t / 61.4532));
	vec2 field_part3 = uv_scaled_centered + 50.*vec2(sin(-t / 87.53218), sin(-t / 49.0000));

    float field = (1.+ (
        cos(length(field_part1) / 19.483) + sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) +
        cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92) ))/2.;
    vec2 borders = vec2(0.2, 0.8);

    float res = (.5 + .5* cos( (adjusted_dissolve) / 82.612 + ( field + -.5 ) *3.14))
    - (floored_uv.x > borders.y ? (floored_uv.x - borders.y)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.y > borders.y ? (floored_uv.y - borders.y)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.x < borders.x ? (borders.x - floored_uv.x)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.y < borders.x ? (borders.x - floored_uv.y)*(5. + 5.*dissolve) : 0.)*(dissolve);

    if (tex.a > 0.01 && burn_colour_1.a > 0.01 && !shadow && res < adjusted_dissolve + 0.8*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) {
        if (!shadow && res < adjusted_dissolve + 0.5*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) {
            tex.rgba = burn_colour_1.rgba;
        } else if (burn_colour_2.a > 0.01) {
            tex.rgba = burn_colour_2.rgba;
        }
    }

    return vec4(shadow ? vec3(0.,0.,0.) : tex.xyz, res > adjusted_dissolve ? (shadow ? tex.a*0.3: tex.a) : .0);
}


vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 tex = Texel(texture, texture_coords);
    vec2 uv = (((texture_coords) * (image_details)) - texture_details.xy * texture_details.ba) / texture_details.ba;

    number low = min(tex.r, min(tex.g, tex.b));
    number high = max(tex.r, max(tex.g, tex.b));
    number delta = high - low - 0.1;
    
    //distnace from center for warping effect
    vec2 center = vec2(0.5, 0.5);  
    float warpAmount = 0.15 * sin(time * 7.5 * 3) + 0.15 * cos(time * 7.5);  

    // comment out for the 'uno' card like look from previous
    center.x += warpAmount * sin(uv.y * 25.0); 
    center.y += warpAmount * cos(uv.x * 25.0); 
    
    
    float distanceFromCenter = length(uv - center);
    float vignetteRadius = 0.4;

    // Exit Early if Near White, But Only Far from Center
    if (high > 0.999 && distanceFromCenter > vignetteRadius) {  
        return dissolve_mask(vec4(0.0, 0.0, 0.0, tex.a) * colour, texture_coords, uv);  
    }

    // odes not work?
    // if (high > 0.9972223333) {  
    //     return dissolve_mask(vec4(0.0, 0.0, 0.0, tex.a) * colour, texture_coords, uv);  
    // }

    // from negarive shine
    number fac = 0.8 + 0.9 * sin(11. * uv.x + 4.32 * uv.y + akashic.r * 12. + cos(akashic.r * 5.3 + uv.y * 4.2 - uv.x * 4.));
    number fac2 = 0.5 + 0.5 * sin(8. * uv.x + 2.32 * uv.y + akashic.r * 5. - cos(akashic.r * 2.3 + uv.x * 8.2));
    number fac3 = 0.5 + 0.5 * sin(10. * uv.x + 5.32 * uv.y + akashic.r * 6.111 + sin(akashic.r * 5.3 + uv.y * 3.2));
    number fac4 = 0.5 + 0.5 * sin(3. * uv.x + 2.32 * uv.y + akashic.r * 8.111 + sin(akashic.r * 1.3 + uv.y * 11.2));
    number fac5 = sin(0.9 * 16. * uv.x + 5.32 * uv.y + akashic.r * 12. + cos(akashic.r * 5.3 + uv.y * 4.2 - uv.x * 4.));

    number maxfac = 0.7 * max(max(fac, max(fac2, max(fac3, 0.0))) + (fac + fac2 + fac3 * fac4), 0.);

    // looks weird
    vec3 inverted = mix(tex.rgb, 1.0 - tex.rgb, smoothstep(0.3, 1.0, high));

    
    float gradientFactor = (uv.x + uv.y) * 0.5;  
    vec3 blueTint = vec3(0.2, 0.4, 1.0);  
    vec3 redTint = vec3(1.0, 0.2, 0.3); 

    vec3 finalColor = mix(blueTint, redTint, gradientFactor) * inverted;
    
    finalColor.r = finalColor.r - delta + delta * maxfac * (0.7 + fac5 * 0.27) - 0.1;
    finalColor.g = finalColor.g - delta + delta * maxfac * (0.7 - fac5 * 0.27) - 0.1;
    finalColor.b = finalColor.b - delta + delta * maxfac * 0.7 - 0.1;

    tex.rgb = finalColor;
    tex.a = tex.a * (0.5 * max(min(1., max(0., 0.3 * max(low * 0.2, delta) + min(max(maxfac * 0.1, 0.), 0.4))), 0.) + 0.15 * maxfac * (0.1 + delta));

    return dissolve_mask(tex * colour, texture_coords, uv);
}

//region default stuff
extern MY_HIGHP_OR_MEDIUMP vec2 mouse_screen_pos;
extern MY_HIGHP_OR_MEDIUMP float hovering;
extern MY_HIGHP_OR_MEDIUMP float screen_scale;

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    if (hovering <= 0.){
        return transform_projection * vertex_position;
    }
    float mid_dist = length(vertex_position.xy - 0.5*love_ScreenSize.xy)/length(love_ScreenSize.xy);
    vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy)/screen_scale;
    float scale = 0.2*(-0.03 - 0.3*max(0., 0.3-mid_dist))
                *hovering*(length(mouse_offset)*length(mouse_offset))/(2. -mid_dist);

    return transform_projection * vertex_position + vec4(0,0,0,scale);
}
#endif