cmake_minimum_required(VERSION 3.16)

project(sh3d_viewer_qml VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Xml Quick3D)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appsh3d_viewer_qml
    src/main.cpp
)

qt_add_qml_module(appsh3d_viewer_qml
    URI sh3d_viewer_qml
    QML_FILES
        qml/Main.qml






        qml/SceneLoader.qml


        QML_FILES
        QML_FILES qml/views/WallDelegate.qml
        QML_FILES qml/models/RoomModel.qml
        QML_FILES qml/models/HomeModel.qml
        QML_FILES qml/models/CameraModel.qml qml/models/DoorModel.qml qml/models/FurnitureModel.qml qml/models/LightModel.qml qml/models/RoomModel.qml qml/models/WindowModel.qml
        QML_FILES qml/models/WallModel.qml
        QML_FILES qml/views/FurnitureDelegate.qml
        QML_FILES qml/views/RoomDelegate.qml

    # SOURCES models/BackgroundImage.h models/Camera.h models/Compass.h models/Environment.h models/FurnitureVisibleProperty.h models/Home.cpp models/Home.h models/Print.h models/PrintedLevel.h models/Property.h
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appsh3d_viewer_qml PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appsh3d_viewer_qml
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appsh3d_viewer_qml
    PRIVATE Qt6::Quick
)

install(TARGETS appsh3d_viewer_qml
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
