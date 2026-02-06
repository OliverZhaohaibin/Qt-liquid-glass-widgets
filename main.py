#!/usr/bin/env python3
"""
Liquid Glass Component Library - PySide6 Entry Point

This application demonstrates a "Liquid Glass" style component library
that approximates Apple's Liquid Glass material and interaction semantics.

Run with: python main.py
Requires: PySide6 (Qt 6.5+)
"""

import sys
import os
from pathlib import Path

from PySide6.QtCore import QUrl, QCoreApplication
from PySide6.QtGui import QGuiApplication, QSurfaceFormat
from PySide6.QtQml import QQmlApplicationEngine


def setup_opengl():
    """Configure OpenGL settings for optimal rendering."""
    fmt = QSurfaceFormat()
    fmt.setVersion(3, 3)
    fmt.setProfile(QSurfaceFormat.CoreProfile)
    fmt.setSamples(4)  # Anti-aliasing
    fmt.setSwapInterval(1)  # VSync for smooth 60fps
    QSurfaceFormat.setDefaultFormat(fmt)


def main():
    # Set application attributes before creating QGuiApplication
    QCoreApplication.setAttribute(
        __import__('PySide6.QtCore', fromlist=['Qt']).Qt.AA_ShareOpenGLContexts
    )
    
    setup_opengl()
    
    app = QGuiApplication(sys.argv)
    app.setApplicationName("Liquid Glass Demo")
    app.setOrganizationName("LiquidGlass")
    app.setOrganizationDomain("liquidglass.demo")
    
    engine = QQmlApplicationEngine()
    
    # Get the directory containing main.py
    app_dir = Path(__file__).parent.resolve()
    qml_dir = app_dir / "qml"
    components_dir = qml_dir / "components"
    
    # Add import paths for QML modules
    engine.addImportPath(str(qml_dir))
    engine.addImportPath(str(components_dir))
    
    # Load the main QML file
    main_qml = qml_dir / "Main.qml"
    
    if not main_qml.exists():
        print(f"Error: Main.qml not found at {main_qml}")
        return 1
    
    engine.load(QUrl.fromLocalFile(str(main_qml)))
    
    if not engine.rootObjects():
        print("Error: Failed to load QML")
        return 1
    
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
