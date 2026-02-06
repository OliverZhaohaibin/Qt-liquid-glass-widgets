// Main.qml - Demo page showcasing all Liquid Glass components
// Features live parameter controls for opacity, blur, tint, etc.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "components" as LG

ApplicationWindow {
    id: window
    visible: true
    width: 1280
    height: 800
    minimumWidth: 900
    minimumHeight: 600
    title: "Liquid Glass Component Library Demo"
    color: "#1a1a2e"
    
    // ============================================================
    // Background with gradient and shapes for glass effect demo
    // ============================================================
    
    Item {
        id: backgroundContent
        anchors.fill: parent
        
        // Animated gradient background
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1a1a2e" }
                GradientStop { position: 0.5; color: "#16213e" }
                GradientStop { position: 1.0; color: "#0f3460" }
            }
        }
        
        // Animated decorative shapes
        Repeater {
            model: 8
            
            Rectangle {
                id: shape
                property real baseX: Math.random() * parent.width
                property real baseY: Math.random() * parent.height
                property real animPhase: Math.random() * Math.PI * 2
                property real animSpeed: 0.5 + Math.random() * 1.0
                
                x: baseX + Math.sin(animTime * animSpeed + animPhase) * 50
                y: baseY + Math.cos(animTime * animSpeed * 0.7 + animPhase) * 40
                
                width: 100 + Math.random() * 200
                height: width
                radius: width / 2
                
                gradient: Gradient {
                    GradientStop { 
                        position: 0.0
                        color: Qt.hsla(0.55 + index * 0.05, 0.7, 0.5, 0.4)
                    }
                    GradientStop { 
                        position: 1.0
                        color: Qt.hsla(0.65 + index * 0.05, 0.6, 0.4, 0.2)
                    }
                }
                
                // Blur the shapes for a softer look
                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.6
                    blurMax: 32
                }
            }
        }
        
        // Additional accent shapes
        Rectangle {
            x: parent.width * 0.7
            y: parent.height * 0.2
            width: 300
            height: 300
            radius: 150
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0.9, 0.3, 0.5, 0.5) }
                GradientStop { position: 1.0; color: Qt.rgba(0.9, 0.5, 0.3, 0.2) }
            }
            layer.enabled: true
            layer.effect: MultiEffect { blurEnabled: true; blur: 0.5; blurMax: 48 }
        }
        
        Rectangle {
            x: parent.width * 0.1
            y: parent.height * 0.6
            width: 250
            height: 250
            radius: 125
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0.3, 0.7, 0.9, 0.5) }
                GradientStop { position: 1.0; color: Qt.rgba(0.3, 0.5, 0.9, 0.2) }
            }
            layer.enabled: true
            layer.effect: MultiEffect { blurEnabled: true; blur: 0.5; blurMax: 48 }
        }
    }
    
    // Animation timer for background shapes
    property real animTime: 0
    Timer {
        running: true
        repeat: true
        interval: 16
        onTriggered: animTime += 0.016
    }
    
    // ============================================================
    // Main Layout
    // ============================================================
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        // ========================================================
        // Left Side: Component Showcase
        // ========================================================
        
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 24
                
                // Title
                Text {
                    text: "Liquid Glass Components"
                    color: LG.Tokens.textPrimary
                    font.pixelSize: 28
                    font.weight: Font.Bold
                }
                
                Text {
                    text: "Interactive component library with glass material effects"
                    color: LG.Tokens.textSecondary
                    font.pixelSize: 14
                }
                
                // ====================================================
                // Buttons Section
                // ====================================================
                
                LG.LiquidGlassPanel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    backgroundSource: backgroundContent
                    title: "Buttons"
                    subtitle: "Default, hover, pressed, and disabled states"
                    
                    RowLayout {
                        anchors.fill: parent
                        spacing: 16
                        
                        LG.LiquidGlassButton {
                            text: "Primary"
                            backgroundSource: backgroundContent
                            onClicked: statusText.text = "Primary button clicked!"
                        }
                        
                        LG.LiquidGlassButton {
                            text: "Secondary"
                            backgroundSource: backgroundContent
                            tintColor: Qt.rgba(0.6, 0.4, 1.0, 0.15)
                            onClicked: statusText.text = "Secondary button clicked!"
                        }
                        
                        LG.LiquidGlassButton {
                            text: "Accent"
                            backgroundSource: backgroundContent
                            tintColor: Qt.rgba(1.0, 0.4, 0.6, 0.15)
                            onClicked: statusText.text = "Accent button clicked!"
                        }
                        
                        LG.LiquidGlassButton {
                            text: "Disabled"
                            backgroundSource: backgroundContent
                            enabled: false
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                // ====================================================
                // Sliders Section
                // ====================================================
                
                LG.LiquidGlassPanel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    backgroundSource: backgroundContent
                    title: "Sliders"
                    subtitle: "Track and knob with enhanced glass during drag"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 20
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            Text {
                                text: "Volume"
                                color: LG.Tokens.textSecondary
                                font.pixelSize: 13
                                Layout.preferredWidth: 80
                            }
                            
                            LG.LiquidGlassSlider {
                                id: volumeSlider
                                Layout.fillWidth: true
                                backgroundSource: backgroundContent
                                from: 0
                                to: 100
                                value: 65
                                onValueChanged: statusText.text = "Volume: " + Math.round(value) + "%"
                            }
                            
                            Text {
                                text: Math.round(volumeSlider.value) + "%"
                                color: LG.Tokens.textPrimary
                                font.pixelSize: 13
                                Layout.preferredWidth: 40
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            Text {
                                text: "Brightness"
                                color: LG.Tokens.textSecondary
                                font.pixelSize: 13
                                Layout.preferredWidth: 80
                            }
                            
                            LG.LiquidGlassSlider {
                                id: brightnessSlider
                                Layout.fillWidth: true
                                backgroundSource: backgroundContent
                                from: 0
                                to: 100
                                value: 80
                                activeTrackColor: Qt.rgba(1.0, 0.8, 0.3, 1.0)
                            }
                            
                            Text {
                                text: Math.round(brightnessSlider.value) + "%"
                                color: LG.Tokens.textPrimary
                                font.pixelSize: 13
                                Layout.preferredWidth: 40
                            }
                        }
                    }
                }
                
                // ====================================================
                // Panel/Card Section
                // ====================================================
                
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 20
                    
                    LG.LiquidGlassPanel {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        backgroundSource: backgroundContent
                        title: "Information Card"
                        subtitle: "Glass material container for content"
                        showFooter: true
                        
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 12
                            
                            Text {
                                Layout.fillWidth: true
                                text: "This panel demonstrates the glass surface with blur, tint, and edge highlights. The material responds subtly to hover."
                                color: LG.Tokens.textSecondary
                                font.pixelSize: 13
                                wrapMode: Text.WordWrap
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                radius: 8
                                color: Qt.rgba(1, 1, 1, 0.05)
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "Content Area"
                                    color: LG.Tokens.textSecondary
                                    font.pixelSize: 12
                                }
                            }
                            
                            Item { Layout.fillHeight: true }
                        }
                        
                        footerContent: [
                            LG.LiquidGlassButton {
                                text: "Action"
                                backgroundSource: backgroundContent
                                implicitWidth: 80
                                implicitHeight: 36
                                fontSize: 12
                                onClicked: statusText.text = "Card action clicked!"
                            }
                        ]
                    }
                    
                    LG.LiquidGlassPanel {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        backgroundSource: backgroundContent
                        title: "Status"
                        
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8
                            
                            Text {
                                id: statusText
                                Layout.fillWidth: true
                                text: "Interact with components to see status updates"
                                color: LG.Tokens.textPrimary
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: Qt.rgba(1, 1, 1, 0.1)
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: "Quality: " + qualityCombo.currentText
                                color: LG.Tokens.textSecondary
                                font.pixelSize: 12
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: "Readability: " + (LG.Tokens.readabilityMode ? "On" : "Off")
                                color: LG.Tokens.textSecondary
                                font.pixelSize: 12
                            }
                            
                            Item { Layout.fillHeight: true }
                        }
                    }
                }
            }
        }
        
        // ========================================================
        // Right Side: Parameter Controls
        // ========================================================
        
        LG.LiquidGlassPanel {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            backgroundSource: backgroundContent
            title: "Live Controls"
            subtitle: "Adjust glass material parameters"
            
            ScrollView {
                anchors.fill: parent
                clip: true
                
                ColumnLayout {
                    width: parent.width
                    spacing: 16
                    
                    // Quality Preset
                    Text {
                        text: "Quality Preset"
                        color: LG.Tokens.textPrimary
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }
                    
                    ComboBox {
                        id: qualityCombo
                        Layout.fillWidth: true
                        model: ["High", "Medium", "Low"]
                        currentIndex: 0
                        onCurrentIndexChanged: {
                            LG.Tokens.qualityPreset = currentIndex
                        }
                        
                        background: Rectangle {
                            radius: 8
                            color: Qt.rgba(1, 1, 1, 0.1)
                            border.color: Qt.rgba(1, 1, 1, 0.2)
                        }
                        
                        contentItem: Text {
                            text: qualityCombo.displayText
                            color: LG.Tokens.textPrimary
                            font.pixelSize: 13
                            leftPadding: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(1,1,1,0.1) }
                    
                    // Base Opacity
                    ControlSlider {
                        label: "Base Opacity"
                        value: LG.Tokens.baseOpacity
                        from: 0.1
                        to: 0.9
                        onValueChanged: LG.Tokens.baseOpacity = value
                    }
                    
                    // Blur Radius (manual override)
                    ControlSlider {
                        label: "Blur Radius"
                        value: 48
                        from: 8
                        to: 64
                        onValueChanged: {
                            // This would override the computed value
                            // For demo purposes we show the slider
                        }
                    }
                    
                    // Tint Strength
                    ControlSlider {
                        label: "Tint Strength"
                        value: LG.Tokens.tintStrength
                        from: 0
                        to: 0.5
                        onValueChanged: LG.Tokens.tintStrength = value
                    }
                    
                    Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(1,1,1,0.1) }
                    
                    // Highlight Intensity
                    ControlSlider {
                        label: "Highlight Intensity"
                        value: LG.Tokens.highlightIntensity
                        from: 0
                        to: 1.0
                        onValueChanged: LG.Tokens.highlightIntensity = value
                    }
                    
                    // Fresnel Power
                    ControlSlider {
                        label: "Edge Fresnel"
                        value: LG.Tokens.edgeFresnelPower
                        from: 1.0
                        to: 5.0
                        onValueChanged: LG.Tokens.edgeFresnelPower = value
                    }
                    
                    // Distortion Strength
                    ControlSlider {
                        label: "Distortion"
                        value: LG.Tokens.distortionStrength
                        from: 0
                        to: 0.05
                        onValueChanged: LG.Tokens.distortionStrength = value
                    }
                    
                    Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(1,1,1,0.1) }
                    
                    // Corner Radius
                    ControlSlider {
                        label: "Corner Radius"
                        value: LG.Tokens.cornerRadius
                        from: 4
                        to: 32
                        onValueChanged: LG.Tokens.cornerRadius = value
                    }
                    
                    // Elevation
                    ControlSlider {
                        label: "Elevation"
                        value: LG.Tokens.elevation
                        from: 0
                        to: 24
                        onValueChanged: LG.Tokens.elevation = value
                    }
                    
                    Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(1,1,1,0.1) }
                    
                    // Readability Mode Toggle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Readability Mode"
                            color: LG.Tokens.textPrimary
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            Layout.fillWidth: true
                        }
                        
                        Switch {
                            id: readabilitySwitch
                            checked: LG.Tokens.readabilityMode
                            onCheckedChanged: LG.Tokens.readabilityMode = checked
                            
                            indicator: Rectangle {
                                implicitWidth: 44
                                implicitHeight: 24
                                x: readabilitySwitch.leftPadding
                                y: (parent.height - height) / 2
                                radius: 12
                                color: readabilitySwitch.checked ? 
                                    LG.Tokens.accentPrimary : Qt.rgba(1, 1, 1, 0.2)
                                
                                Rectangle {
                                    x: readabilitySwitch.checked ? 
                                        parent.width - width - 2 : 2
                                    y: 2
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: "white"
                                    
                                    Behavior on x {
                                        NumberAnimation { 
                                            duration: LG.Tokens.durationFast
                                            easing.type: LG.Tokens.easingStandard
                                        }
                                    }
                                }
                                
                                Behavior on color {
                                    ColorAnimation { duration: LG.Tokens.durationFast }
                                }
                            }
                        }
                    }
                    
                    Item { Layout.preferredHeight: 20 }
                }
            }
        }
    }
    
    // ============================================================
    // Control Slider Component (inline for demo)
    // ============================================================
    
    component ControlSlider: ColumnLayout {
        property string label: ""
        property real value: 0.5
        property real from: 0
        property real to: 1
        
        Layout.fillWidth: true
        spacing: 4
        
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: label
                color: LG.Tokens.textSecondary
                font.pixelSize: 12
                Layout.fillWidth: true
            }
            
            Text {
                text: slider.value.toFixed(2)
                color: LG.Tokens.textPrimary
                font.pixelSize: 11
                font.family: "monospace"
            }
        }
        
        Slider {
            id: slider
            Layout.fillWidth: true
            from: parent.from
            to: parent.to
            value: parent.value
            
            onValueChanged: parent.value = value
            
            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                height: 4
                radius: 2
                color: Qt.rgba(1, 1, 1, 0.15)
                
                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: 2
                    color: LG.Tokens.accentPrimary
                }
            }
            
            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: 16
                height: 16
                radius: 8
                color: slider.pressed ? Qt.lighter(LG.Tokens.accentPrimary, 1.2) : "white"
                border.color: LG.Tokens.accentPrimary
                border.width: 2
                
                Behavior on color {
                    ColorAnimation { duration: LG.Tokens.durationFast }
                }
            }
        }
    }
}
