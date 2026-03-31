# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: BSD-3-Clause

#####################################################################
## rcc Tool:
#####################################################################

add_library(rcc
        main.cpp
        rcc.cpp rcc.h
)

# target
target_compile_definitions(rcc PUBLIC QT_NO_CAST_FROM_ASCII QT_NO_FOREACH QT_RCC QT_USE_NODISCARD_FILE_OPEN QT_NO_URL_CAST_FROM_STRING)
target_link_libraries(rcc PRIVATE Qt${QT_VERSION_MAJOR}::Core)
target_include_directories(rcc PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

if(BUILD_SHARED_LIBS)
  target_compile_definitions(rcc PRIVATE MAKE_SHARED)
endif()

