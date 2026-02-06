// LiquidGlassSurface.qml - General-purpose glass surface/material container
// Base component for all Liquid Glass effects with blur, tint, fresnel, and distortion

import QtQuick
import QtQuick.Effects

Item {
    id: root
    
    // ============================================================
    // Public Properties - Override tokens as needed
    // ============================================================
    
    // Source item to capture for background blur (required)
    property Item backgroundSource: null
    
    // Material properties (default to token values)
    property real blurRadius: Tokens.effectiveBlurRadius
    property real downsampleFactor: Tokens.downsampleFactor
    property real baseOpacity: Tokens.effectiveOpacity
    property color tintColor: Tokens.tintColor
    property real tintStrength: Tokens.tintStrength
    property real noiseAmount: Tokens.noiseAmount
    property real distortionStrength: Tokens.distortionStrength
    property real highlightIntensity: Tokens.effectiveHighlightIntensity
    property real edgeFresnelPower: Tokens.edgeFresnelPower
    property color edgeHighlightColor: Tokens.edgeHighlightColor
    property real cornerRadius: Tokens.cornerRadius
    property real elevation: Tokens.elevation
    property color shadowColor: Tokens.shadowColor
    property bool readabilityMode: Tokens.readabilityMode
    
    // Interactive state (can be controlled externally)
    property bool hovered: false
    property bool pressed: false
    property point pointerPosition: Qt.point(width / 2, height / 2)
    
    // Animation time for shader effects
    property real animationTime: 0
    
    // Content to display on top of the glass
    default property alias content: contentContainer.data
    
    // ============================================================
    // Private Properties - Computed from state
    // ============================================================
    
    // Animated highlight intensity with state modifiers
    property real _effectiveHighlight: highlightIntensity
    
    // Animated distortion with state modifiers
    property real _effectiveDistortion: distortionStrength
    
    // Normalized pointer position (0-1)
    readonly property point _normalizedPointer: Qt.point(
        pointerPosition.x / Math.max(width, 1),
        pointerPosition.y / Math.max(height, 1)
    )
    
    // Animation timer for subtle effects
    Timer {
        running: true
        repeat: true
        interval: 16  // ~60fps
        onTriggered: animationTime += 0.016
    }
    
    // State change handler to update animated properties
    onHoveredChanged: updateEffectiveValues()
    onPressedChanged: updateEffectiveValues()
    onHighlightIntensityChanged: updateEffectiveValues()
    onDistortionStrengthChanged: updateEffectiveValues()
    
    function updateEffectiveValues() {
        let baseHighlight = highlightIntensity
        if (pressed) baseHighlight += Tokens.pressedHighlightBoost
        else if (hovered) baseHighlight += Tokens.hoverHighlightBoost
        _effectiveHighlight = baseHighlight
        
        let baseDistortion = distortionStrength
        if (pressed) baseDistortion += Tokens.pressedDistortionBoost
        else if (hovered) baseDistortion += Tokens.hoverDistortionBoost
        _effectiveDistortion = baseDistortion
    }
    
    // Smooth animations for state changes
    Behavior on _effectiveHighlight {
        NumberAnimation {
            duration: Tokens.durationNormal
            easing.type: Tokens.easingStandard
        }
    }
    
    Behavior on _effectiveDistortion {
        NumberAnimation {
            duration: Tokens.durationNormal
            easing.type: Tokens.easingStandard
        }
    }
    
    // ============================================================
    // Shadow Layer
    // ============================================================
    
    Rectangle {
        id: shadowRect
        anchors.fill: parent
        anchors.margins: -elevation
        radius: cornerRadius + elevation / 2
        color: "transparent"
        
        // Use MultiEffect for shadow if available
        layer.enabled: elevation > 0
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: root.shadowColor
            shadowBlur: Math.min(root.elevation / 64, 1.0)  // Normalize to 0-1 range, clamped
            shadowVerticalOffset: root.elevation / 2
            shadowHorizontalOffset: 0
            shadowOpacity: 0.5
        }
    }
    
    // ============================================================
    // Background Capture & Blur
    // ============================================================
    
    // Capture the background content
    ShaderEffectSource {
        id: backgroundCapture
        sourceItem: root.backgroundSource
        anchors.fill: parent
        
        // Map to correct region of the source
        sourceRect: Qt.rect(
            root.x, 
            root.y, 
            root.width, 
            root.height
        )
        
        // Performance: enable texture mirroring and downsampling
        textureSize: Qt.size(
            root.width * root.downsampleFactor,
            root.height * root.downsampleFactor
        )
        
        live: true
        recursive: false
        hideSource: false
        visible: false
    }
    
    // ============================================================
    // Glass Effect Container
    // ============================================================
    
    Item {
        id: glassContainer
        anchors.fill: parent
        
        // Clip to rounded rectangle
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
            maskSource: ShaderEffectSource {
                sourceItem: Rectangle {
                    width: root.width
                    height: root.height
                    radius: root.cornerRadius
                    color: "white"
                }
            }
        }
        
        // Blurred background with MultiEffect
        Item {
            id: blurredBackground
            anchors.fill: parent
            
            // Source image
            Image {
                id: sourceProxy
                anchors.fill: parent
                visible: false
            }
            
            // Apply blur using MultiEffect
            MultiEffect {
                id: blurEffect
                anchors.fill: parent
                source: backgroundCapture
                
                // Blur settings
                blurEnabled: true
                blurMax: 64
                blur: root.blurRadius / 64  // Normalize to 0-1
                blurMultiplier: 1.0
                
                // Saturation adjustment for glass feel
                saturation: readabilityMode ? -0.1 : 0.1
            }
        }
        
        // ============================================================
        // Glass Shader Effect - Lens Distortion, Chromatic Aberration, Fresnel
        // Creates realistic glass volume with edge highlights and color dispersion
        // ============================================================
        
        ShaderEffect {
            id: glassShader
            anchors.fill: parent
            
            // Shader uniforms
            property variant source: backgroundCapture
            property real time: root.animationTime
            property real opacity_: root.baseOpacity
            property color tint: root.tintColor
            property real tintStr: root.tintStrength
            property real noise: root.noiseAmount
            property real distortion: root._effectiveDistortion
            property real highlight: root._effectiveHighlight
            property real fresnel: root.edgeFresnelPower
            property color edgeColor: root.edgeHighlightColor
            property point pointer: root._normalizedPointer
            property real hoverState: root.hovered ? 1.0 : 0.0
            property real pressState: root.pressed ? 1.0 : 0.0
            property point resolution: Qt.point(root.width, root.height)
            property real cornerRad: root.cornerRadius / Math.min(root.width, root.height)
            
            // ========================================================
            // VERTEX SHADER
            // ========================================================
            vertexShader: "
                #version 440
                layout(location = 0) in vec4 qt_Vertex;
                layout(location = 1) in vec2 qt_MultiTexCoord0;
                layout(location = 0) out vec2 texCoord;
                layout(std140, binding = 0) uniform buf {
                    mat4 qt_Matrix;
                    float qt_Opacity;
                };
                void main() {
                    texCoord = qt_MultiTexCoord0;
                    gl_Position = qt_Matrix * qt_Vertex;
                }
            "
            
            // ========================================================
            // FRAGMENT SHADER - Realistic Glass Lens Effect
            // Features: Lens distortion, chromatic aberration, fresnel edges
            // ========================================================
            fragmentShader: "
                #version 440
                layout(location = 0) in vec2 texCoord;
                layout(location = 0) out vec4 fragColor;
                
                layout(std140, binding = 0) uniform buf {
                    mat4 qt_Matrix;
                    float qt_Opacity;
                };
                
                layout(binding = 1) uniform sampler2D source;
                
                // Custom uniforms
                layout(std140, binding = 2) uniform custom {
                    float time;
                    float opacity_;
                    vec4 tint;
                    float tintStr;
                    float noise;
                    float distortion;
                    float highlight;
                    float fresnel;
                    vec4 edgeColor;
                    vec2 pointer;
                    float hoverState;
                    float pressState;
                    vec2 resolution;
                    float cornerRad;
                };
                
                // Hash function for noise
                float hash(vec2 p) {
                    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
                }
                
                // Small epsilon to prevent division by zero when normalizing vectors near center
                const float NORMALIZE_EPSILON = 0.001;
                
                // 2D noise function
                float noise2D(vec2 p) {
                    vec2 i = floor(p);
                    vec2 f = fract(p);
                    f = f * f * (3.0 - 2.0 * f);
                    
                    float a = hash(i);
                    float b = hash(i + vec2(1.0, 0.0));
                    float c = hash(i + vec2(0.0, 1.0));
                    float d = hash(i + vec2(1.0, 1.0));
                    
                    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
                }
                
                // Lens distortion function - creates convex glass effect
                vec2 lensDistort(vec2 uv, float strength) {
                    vec2 center = vec2(0.5);
                    vec2 delta = uv - center;
                    float dist = length(delta);
                    
                    // Barrel distortion for convex lens effect
                    float distortAmount = 1.0 + strength * dist * dist;
                    return center + delta * distortAmount;
                }
                
                vec3 sampleBackground(vec2 uv) {
                    return texture(source, clamp(uv, 0.0, 1.0)).rgb;
                }

                void main() {
                    vec2 uv = texCoord;
                    vec2 center = mix(vec2(0.5), pointer, 0.15 * hoverState + 0.08 * pressState);
                    vec2 delta = uv - center;
                    float distFromCenter = length(delta);
                    
                    // === Lens Refraction Model ===
                    // Create a convex surface normal (pseudo-sphere)
                    vec2 sphereCoord = delta * 2.0;
                    float radiusSq = dot(sphereCoord, sphereCoord);
                    float height = sqrt(max(1.0 - radiusSq, 0.0));
                    float curvature = 0.65 + distortion * 8.0;
                    vec3 normal = normalize(vec3(sphereCoord * curvature, height));
                    
                    // Add subtle noise-based micro-surface distortion for organic glass feel
                    float n1 = noise2D(uv * 6.0 + time * 0.3);
                    float n2 = noise2D(uv * 8.0 - time * 0.2);
                    vec2 noiseOffset = vec2(n1 - 0.5, n2 - 0.5) * noise * 0.6;
                    normal.xy += noiseOffset * 0.35;
                    normal = normalize(normal);
                    
                    // === Real-time Edge Chromatic Dispersion ===
                    // Stronger dispersion at the perimeter
                    float edgeDispersionFactor = smoothstep(0.2, 0.95, distFromCenter * 1.4);
                    float timeModulation = 1.0 + 0.12 * sin(time * 2.0 + distFromCenter * 6.0);
                    
                    // Base IOR with subtle edge-dependent dispersion
                    float iorBase = 1.08 + distortion * 4.0;
                    float iorR = iorBase - edgeDispersionFactor * 0.010;
                    float iorG = iorBase;
                    float iorB = iorBase + edgeDispersionFactor * 0.018;
                    
                    vec3 viewDir = vec3(0.0, 0.0, 1.0);
                    vec3 refrR = refract(-viewDir, normal, 1.0 / iorR);
                    vec3 refrG = refract(-viewDir, normal, 1.0 / iorG);
                    vec3 refrB = refract(-viewDir, normal, 1.0 / iorB);
                    
                    float refractionScale = (0.035 + distortion * 1.4) * timeModulation;
                    vec2 uvR = uv + refrR.xy / max(refrR.z, NORMALIZE_EPSILON) * refractionScale + noiseOffset;
                    vec2 uvG = uv + refrG.xy / max(refrG.z, NORMALIZE_EPSILON) * refractionScale + noiseOffset;
                    vec2 uvB = uv + refrB.xy / max(refrB.z, NORMALIZE_EPSILON) * refractionScale + noiseOffset;
                    
                    // Slight lens distortion to keep the volume effect
                    vec2 lensUV = lensDistort(uv, distortion * 1.8);
                    uvR = mix(uvR, lensUV, 0.2);
                    uvG = mix(uvG, lensUV, 0.2);
                    uvB = mix(uvB, lensUV, 0.2);
                    
                    vec3 refractedColor = vec3(
                        sampleBackground(uvR).r,
                        sampleBackground(uvG).g,
                        sampleBackground(uvB).b
                    );
                    
                    // === Micro diffusion for realistic glass softness ===
                    float diffusion = clamp(opacity_ + distortion * 2.0, 0.0, 1.0);
                    vec2 blurStep = vec2(0.0025 + diffusion * 0.004);
                    vec3 softSample = (
                        sampleBackground(uv + blurStep) +
                        sampleBackground(uv - blurStep) +
                        sampleBackground(uv + vec2(blurStep.x, -blurStep.y)) +
                        sampleBackground(uv + vec2(-blurStep.x, blurStep.y))
                    ) * 0.25;
                    vec3 bgColor = mix(refractedColor, softSample, diffusion * 0.35);
                    
                    // === Edge Dispersion Highlight ===
                    vec3 dispersionTint = vec3(0.0);
                    if (edgeDispersionFactor > 0.2) {
                        float angle = atan(delta.y, delta.x);
                        float hue = (angle + 3.14159) / (2.0 * 3.14159);
                        vec3 rainbow;
                        rainbow.r = abs(hue * 6.0 - 3.0) - 1.0;
                        rainbow.g = 2.0 - abs(hue * 6.0 - 2.0);
                        rainbow.b = 2.0 - abs(hue * 6.0 - 4.0);
                        rainbow = clamp(rainbow, 0.0, 1.0);
                        float dispersionIntensity = (edgeDispersionFactor - 0.2) * 0.22 * highlight;
                        dispersionTint = rainbow * dispersionIntensity;
                    }
                    
                    // === Fresnel Edge Effect ===
                    float edgeFactor = pow(distFromCenter * 1.8, fresnel);
                    edgeFactor = clamp(edgeFactor, 0.0, 1.0);
                    vec3 fresnelGlow = vec3(1.0) * edgeFactor * highlight * 0.6;
                    
                    // === Specular Highlights ===
                    vec3 lightDir = normalize(vec3(-0.3, -0.6, 0.8));
                    float specular = pow(max(dot(normal, lightDir), 0.0), 48.0);
                    float rimSpecular = pow(max(dot(normal, lightDir), 0.0), 12.0) * edgeFactor;
                    vec3 specularColor = vec3(1.0, 0.98, 0.95) * (specular * 0.9 + rimSpecular * 0.5) * highlight;
                    
                    // === Inner Highlight / Caustic Effect ===
                    float caustic = exp(-distFromCenter * distFromCenter * 6.0) * highlight * 0.32;
                    float ring = smoothstep(0.28, 0.35, distFromCenter) * smoothstep(0.5, 0.42, distFromCenter);
                    caustic += ring * highlight * 0.18;
                    
                    // === Combine Effects ===
                    vec3 glassColor = mix(bgColor, tint.rgb, tintStr * 0.5);
                    glassColor += dispersionTint;
                    glassColor += fresnelGlow;
                    glassColor += vec3(1.0) * caustic;
                    glassColor += specularColor;
                    
                    // === Glass Volume Opacity ===
                    float volumeOpacity = opacity_ + edgeFactor * 0.18;
                    volumeOpacity -= (1.0 - distFromCenter) * 0.06;
                    volumeOpacity = clamp(volumeOpacity, 0.1, 0.95);
                    
                    fragColor = vec4(glassColor, volumeOpacity) * qt_Opacity;
                }
            "
        }
        
        // ============================================================
        // Readability Overlay (when enabled)
        // ============================================================
        
        Rectangle {
            id: readabilityOverlay
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, Tokens.readabilityOverlayOpacity)
            visible: root.readabilityMode
            opacity: root.readabilityMode ? 1.0 : 0.0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: Tokens.durationNormal
                    easing.type: Tokens.easingStandard
                }
            }
        }
        
        // ============================================================
        // Content Container
        // ============================================================
        
        Item {
            id: contentContainer
            anchors.fill: parent
            anchors.margins: 1  // Slight inset to avoid edge clipping
        }
    }
}
