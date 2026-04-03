cmake_minimum_required(VERSION 3.16)

project(sh3d_viewer_qml VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Xml Quick3D Quick3DPrivate Quick3DAssetUtilsPrivate)

qt_standard_project_setup(REQUIRES 6.10)

set(BUILD_TESTS OFF)
set(INSTALL_FILES OFF)
add_subdirectory(qmicroz)

add_subdirectory(rcc)

qt_add_executable(appsh3d_viewer_qml
    src/main.cpp
    src/sh3dasseturlhandler.h src/sh3dasseturlhandler.cpp
)

qt_add_resources(appsh3d_viewer_qml "assimpimporter_options"
    FILES resources/assimpimporter_options.json)

qt_add_qml_module(appsh3d_viewer_qml
    URI sh3d_viewer_qml
    VERSION 1.0

    QML_FILES
        qml/Main.qml
        qml/SceneLoader.qml
        qml/views/WallDelegate.qml
        qml/models/RoomModel.qml
        qml/models/HomeModel.qml
        qml/models/CameraModel.qml qml/models/DoorModel.qml qml/models/FurnitureModel.qml qml/models/LightModel.qml qml/models/RoomModel.qml qml/models/WindowModel.qml
        qml/models/WallModel.qml
        qml/views/FurnitureDelegate.qml
        qml/views/RoomDelegate.qml
        qml/views/FloorOrCeiling.qml
        qml/models/RoomPointsModel.qml
        qml/models/Sh3dXmlModel.qml
        qml/models/LightSourceModel.qml
        qml/views/LightDelegate.qml
        qml/models/MaterialModel.qml

    RESOURCES qml/js/earcut.js

    RESOURCES
        resources/default.mtl

    #RESOURCES resources/lake_pier_1k.hdr
    #RESOURCES resources/kloofendal_48d_partly_cloudy_puresky_1k.hdr
    #RESOURCES resources/OpenfootageNET_Paris_MenilmontonDAY_low.hdr
    #RESOURCES resources/little_paris_eiffel_tower_1k.hdr
    #RESOURCES resources/little_paris_eiffel_tower_2k.hdr

    SOURCES src/Sh3dHomeModel.h src/Sh3dHomeModel.cpp
    SOURCES src/sh3druntimeloader.cpp src/sh3druntimeloader.h
)

# Add include directories so target can find the QMLELEMENTS
target_include_directories(appsh3d_viewer_qml PRIVATE
   ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appsh3d_viewer_qml PROPERTIES
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appsh3d_viewer_qml
    PRIVATE Qt6::Quick Qt6::Quick3D Qt6::Xml
    PRIVATE Qt6::Quick3DPrivate Qt6::Quick3DAssetUtilsPrivate
    PRIVATE qmicroz
)

install(TARGETS appsh3d_viewer_qml
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
