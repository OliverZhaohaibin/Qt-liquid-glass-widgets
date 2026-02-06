// LiquidGlassButton.qml - Interactive button with Liquid Glass material
// Features: default/hover/pressed/disabled states, ripple/specular sweep effect

import QtQuick
import QtQuick.Controls
import QtQuick.Effects

AbstractButton {
    id: root
    
    // ============================================================
    // Public Properties
    // ============================================================
    
    // Source item for background blur
    property Item backgroundSource: null
    
    // Button styling
    property real cornerRadius: Tokens.cornerRadius
    property color textColor: enabled ? Tokens.textPrimary : Tokens.textDisabled
    property real fontSize: 14
    property bool showIcon: false
    property string iconSource: ""
    
    // Material overrides
    property real blurRadius: Tokens.effectiveBlurRadius
    property real baseOpacity: Tokens.effectiveOpacity
    property color tintColor: Tokens.tintColor
    property real highlightIntensity: Tokens.effectiveHighlightIntensity
    
    // Accessibility
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.description: "Liquid glass button"
    
    // Default size
    implicitWidth: Math.max(100, contentRow.implicitWidth + 32)
    implicitHeight: 44
    
    // Focus handling
    focusPolicy: Qt.StrongFocus
    
    // ============================================================
    // Internal State
    // ============================================================
    
    property real _hoverProgress: 0
    property real _pressProgress: 0
    property point _pointerPos: Qt.point(width / 2, height / 2)
    property real _rippleProgress: 0
    property point _rippleCenter: Qt.point(width / 2, height / 2)
    
    // Track hover position
    HoverHandler {
        id: hoverHandler
        onPointChanged: {
            if (hovered) {
                root._pointerPos = Qt.point(point.position.x, point.position.y)
            }
        }
    }
    
    // Track press for ripple using pressedChanged signal
    TapHandler {
        id: tapHandler
        onPressedChanged: {
            if (pressed) {
                root._rippleCenter = Qt.point(point.position.x, point.position.y)
                rippleAnimation.restart()
            }
        }
    }
    
    // Smooth state transitions
    Behavior on _hoverProgress {
        NumberAnimation {
            duration: Tokens.durationNormal
            easing.type: Tokens.easingStandard
        }
    }
    
    Behavior on _pressProgress {
        NumberAnimation {
            duration: Tokens.durationFast
            easing.type: Tokens.easingStandard
        }
    }
    
    // State bindings
    states: [
        State {
            name: "disabled"
            when: !root.enabled
            PropertyChanges { target: root; _hoverProgress: 0; _pressProgress: 0 }
        },
        State {
            name: "pressed"
            when: root.pressed && root.enabled
            PropertyChanges { target: root; _pressProgress: 1 }
        },
        State {
            name: "hovered"
            when: root.hovered && root.enabled && !root.pressed
            PropertyChanges { target: root; _hoverProgress: 1 }
        },
        State {
            name: "default"
            when: !root.hovered && !root.pressed && root.enabled
            PropertyChanges { target: root; _hoverProgress: 0; _pressProgress: 0 }
        }
    ]
    
    // Ripple animation
    NumberAnimation {
        id: rippleAnimation
        target: root
        property: "_rippleProgress"
        from: 0
        to: 1
        duration: 400
        easing.type: Easing.OutQuad
    }
    
    // ============================================================
    // Visual Representation
    // ============================================================
    
    background: Item {
        id: buttonBackground
        
        // Scale animation on press
        transform: Scale {
            origin.x: width / 2
            origin.y: height / 2
            xScale: 1 + (Tokens.hoverScaleBoost - 1) * root._hoverProgress 
                    + (Tokens.pressedScaleBoost - 1) * root._pressProgress
            yScale: xScale
            
            Behavior on xScale {
                NumberAnimation {
                    duration: Tokens.durationFast
                    easing.type: Tokens.easingBounce
                }
            }
        }
        
        // Glass surface
        LiquidGlassSurface {
            id: glassSurface
            anchors.fill: parent
            backgroundSource: root.backgroundSource
            cornerRadius: root.cornerRadius
            blurRadius: root.blurRadius
            baseOpacity: root.enabled ? 
                (root.baseOpacity + 0.1 * root._hoverProgress + 0.15 * root._pressProgress) :
                (root.baseOpacity * Tokens.disabledOpacity)
            tintColor: root.tintColor
            highlightIntensity: root.highlightIntensity + 
                Tokens.hoverHighlightBoost * root._hoverProgress +
                Tokens.pressedHighlightBoost * root._pressProgress
            distortionStrength: Tokens.distortionStrength +
                Tokens.hoverDistortionBoost * root._hoverProgress +
                Tokens.pressedDistortionBoost * root._pressProgress
            hovered: root.hovered
            pressed: root.pressed
            pointerPosition: root._pointerPos
            elevation: Tokens.elevation * (1 + 0.2 * root._hoverProgress - 0.3 * root._pressProgress)
            
            // Specular sweep effect on hover
            Rectangle {
                id: specularSweep
                width: parent.width * 0.4
                height: parent.height * 2
                rotation: 30
                
                // Position based on pointer
                x: root._pointerPos.x - width / 2
                y: root._pointerPos.y - height / 2
                
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.4; color: Qt.rgba(1, 1, 1, 0.15 * root._hoverProgress) }
                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.25 * root._hoverProgress) }
                    GradientStop { position: 0.6; color: Qt.rgba(1, 1, 1, 0.15 * root._hoverProgress) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                
                opacity: root._hoverProgress
                
                Behavior on x { NumberAnimation { duration: 50 } }
                Behavior on y { NumberAnimation { duration: 50 } }
            }
            
            // Ripple effect on press
            Rectangle {
                id: ripple
                x: root._rippleCenter.x - width / 2
                y: root._rippleCenter.y - height / 2
                width: Math.max(parent.width, parent.height) * 2.5 * root._rippleProgress
                height: width
                radius: width / 2
                color: Qt.rgba(1, 1, 1, 0.3 * (1 - root._rippleProgress))
                opacity: 1 - root._rippleProgress
                visible: root._rippleProgress > 0 && root._rippleProgress < 1
            }
        }
        
        // Focus ring
        Rectangle {
            anchors.fill: parent
            anchors.margins: -Tokens.focusRingWidth
            radius: root.cornerRadius + Tokens.focusRingWidth
            color: "transparent"
            border.color: Tokens.focusRingColor
            border.width: Tokens.focusRingWidth
            visible: root.activeFocus
            opacity: root.activeFocus ? 1.0 : 0.0
            
            Behavior on opacity {
                NumberAnimation { duration: Tokens.durationFast }
            }
        }
    }
    
    // ============================================================
    // Content
    // ============================================================
    
    contentItem: Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8
        
        // Optional icon
        Image {
            id: iconImage
            source: root.iconSource
            width: 20
            height: 20
            visible: root.showIcon && root.iconSource !== ""
            anchors.verticalCenter: parent.verticalCenter
            opacity: root.enabled ? 1.0 : Tokens.disabledOpacity
            
            Behavior on opacity {
                NumberAnimation { duration: Tokens.durationNormal }
            }
        }
        
        // Text label
        Text {
            id: buttonText
            text: root.text
            color: root.textColor
            font.pixelSize: root.fontSize
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
            
            // Subtle scale on press
            transform: Scale {
                origin.x: buttonText.width / 2
                origin.y: buttonText.height / 2
                xScale: 1 - 0.02 * root._pressProgress
                yScale: xScale
            }
            
            Behavior on color {
                ColorAnimation { duration: Tokens.durationNormal }
            }
        }
    }
    
    // ============================================================
    // Keyboard Handling
    // ============================================================
    
    Keys.onReturnPressed: {
        if (enabled) {
            root._rippleCenter = Qt.point(width / 2, height / 2)
            rippleAnimation.restart()
            clicked()
        }
    }
    
    Keys.onSpacePressed: {
        if (enabled) {
            root._rippleCenter = Qt.point(width / 2, height / 2)
            rippleAnimation.restart()
            clicked()
        }
    }
}
