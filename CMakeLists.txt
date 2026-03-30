cmake_minimum_required(VERSION 3.16)

project(vkStat
    VERSION 1
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS QuickControls2)
find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Sql)

qt_standard_project_setup(REQUIRES 6.10)

set(CPP_FILES
    dbdriver4.cpp dbdriver4.h
)

set(DB_FILES
    data/db.sqlite
)

set(JS_FILES
    qt/js/std.js
    qt/js/v146/sqlDocuments.js
    qt/js/v146/sqlItem.js
    qt/js/v146/sqlStatAcnts.js

)
set(REPORT_FILES
)

set(ICON_FILES
)

qt_add_executable(appvkStat
    main.cpp
)

qt_add_qml_module(appvkStat
    URI vkStat
    QML_FILES
        qt/qml/Main.qml
        qt/qml/ItemCrnt.qml qt/qml/ModelCrnt.qml
        qt/qml/LogView.qml
        qt/qml/PopupSelect.qml
        qt/qml/ItemMonth.qml qt/qml/ModelMonth.qml
        qt/qml/ItemYear.qml qt/qml/ModelYear.qml
        ${JS_FILES}
    SOURCES
        ${CPP_FILES}
)


qt_add_resources(appvkStat "app_res"
    PREFIX "/"
    FILES
        ${ICON_FILES}
        ${DB_FILES}
        README.md
        .gitignore
        TODO.txt
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appvkStat PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appvkStat
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appvkStat
    PRIVATE Qt6::Core
    PRIVATE Qt6::QuickControls2
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Sql
)

install(TARGETS appvkStat
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    message(STATUS "macOS-specific QML and sources. Project: ${PROJECT_NAME} v.${PROJECT_VERSION}")
    # message(STATUS "macOS-specific QML and sources. Folder: ${CMAKE_BINARY_DIR}")
    # macOS-specific files
    set_source_files_properties(${DB_FILES} PROPERTIES MACOSX_PACKAGE_LOCATION "MacOS/data")
    # set_source_files_properties(${REPORT_FILES} PROPERTIES MACOSX_PACKAGE_LOCATION "MacOS/report")
    # file(MAKE_DIRECTORY MACOSX_PACKAGE_LOCATION "MacOS/report")

elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    message(STATUS "Windows-specific QML and sources.")

elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(STATUS "Linux-specific QML and sources.")
else()
    message(FATAL_ERROR "Unsupported OS. No kernelproxy.h defined for ${CMAKE_SYSTEM_NAME}.")
endif()
