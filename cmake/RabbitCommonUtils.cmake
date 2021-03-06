include(CMakePackageConfigHelpers)
include(CMakeParseArguments)
include(GenerateExportHeader)

# 产生android平台分发设置
# 详见： ${QT_INSTALL_DIR}/features/android/android_deployment_settings.prf
function(GENERATED_DEPLOYMENT_SETTINGS)
    cmake_parse_arguments(PARA "" "NAME;APPLACTION;ANDROID_SOURCES_DIR" "" ${ARGN})

    if(NOT ANDROID_NDK)
        set(ANDROID_NDK $ENV{ANDROID_NDK})
        if(NOT ANDROID_NDK)
            set(ANDROID_NDK ${ANDROID_NDK_ROOT})
            if(NOT ANDROID_NDK)
                set(ANDROID_NDK $ENV{ANDROID_NDK_ROOT})
            endif()
        endif()
    endif()

    if(NOT ANDROID_SDK)
        set(ANDROID_SDK $ENV{ANDROID_SDK})
        if(NOT ANDROID_SDK)
            set(ANDROID_SDK ${ANDROID_SDK_ROOT})
            if(NOT ANDROID_SDK)
                set(ANDROID_SDK $ENV{ANDROID_SDK_ROOT})
            endif()
        endif()
    endif()

    if(NOT DEFINED BUILD_TOOS_VERSION)
        set(BUILD_TOOS_VERSION $ENV{BUILD_TOOS_VERSION})
    endif()
    if(NOT DEFINED BUILD_TOOS_VERSION)
        set(BUILD_TOOS_VERSION "28.0.3")
    endif()
    
    if(DEFINED PARA_NAME)
        set(_file_name ${PARA_NAME})
        #message("file_name:${PARA_NAME}")
    else()
        SET(_file_name "${PROJECT_BINARY_DIR}/android-lib${PROJECT_NAME}.so-deployment-settings.json")
    endif()

    FILE(WRITE ${_file_name} "{\n")
    FILE(APPEND ${_file_name} "\"description\": \"This file is generated by qmake to be read by androiddeployqt and should not be modified by hand.\",\n")
    FILE(APPEND ${_file_name} "\"qt\":\"${QT_INSTALL_DIR}\",\n")
    FILE(APPEND ${_file_name} "\"sdk\":\"${ANDROID_SDK}\",\n")
    FILE(APPEND ${_file_name} "\"sdkBuildToolsRevision\":\"${BUILD_TOOS_VERSION}\",\n")
    FILE(APPEND ${_file_name} "\"ndk\":\"${ANDROID_NDK}\",\n")

    FILE(APPEND ${_file_name} "\"stdcpp-path\":\"${ANDROID_NDK}/sources/cxx-stl/llvm-libc++/libs/${ANDROID_ABI}/libc++_shared.so\",\n")
    FILE(APPEND ${_file_name} "\"useLLVM\":true,\n")
    FILE(APPEND ${_file_name} "\"toolchain-prefix\":\"llvm\",\n")
    FILE(APPEND ${_file_name} "\"tool-prefix\":\"llvm\",\n")

    IF(CMAKE_HOST_WIN32)
        IF(ANDROID_NDK_HOST_X64)
            FILE(APPEND ${_file_name} "\"ndk-host\":\"windows-x86_64\",\n")
        ELSE()
            FILE(APPEND ${_file_name} "\"ndk-host\":\"windows\",\n")
        ENDIF()
    ELSE()
        IF(ANDROID_NDK_HOST_X64)
            FILE(APPEND ${_file_name} "\"ndk-host\":\"linux-x86_64\",\n")
	ELSE()
	    FILE(APPEND ${_file_name} "\"ndk-host\":\"linux\",\n")
        ENDIF()
    ENDIF()
    FILE(APPEND ${_file_name} "\"target-architecture\":\"${CMAKE_ANDROID_ARCH_ABI}\",\n")
    IF(DEFINED PARA_ANDROID_SOURCES_DIR)
        FILE(APPEND ${_file_name} "\"android-package-source-directory\":\"${PARA_ANDROID_SOURCES_DIR}\",\n")
    else()
        FILE(APPEND ${_file_name} "\"android-package-source-directory\":\"${PROJECT_SOURCE_DIR}/android\",\n")
    endif()
    IF(ANDROID_EXTRA_LIBS)
        FILE(APPEND ${_file_name} "\"android-extra-libs\":\"${ANDROID_EXTRA_LIBS}\",\n")
    ENDIF(ANDROID_EXTRA_LIBS)
    if(DEFINED PARA_APPLACTION)
        FILE(APPEND ${_file_name} "\"application-binary\":\"${PARA_APPLACTION}\"\n")
        #message("app_bin:${PARA_APPLACTION}")
    else()
        FILE(APPEND ${_file_name} "\"application-binary\":\"${CMAKE_BINARY_DIR}/bin/lib${PROJECT_NAME}.so\"\n")
    endif()
    FILE(APPEND ${_file_name} "}")
endfunction(GENERATED_DEPLOYMENT_SETTINGS)

# 得到子目录
macro(SUBDIRLIST result curdir)
    file(GLOB children RELATIVE ${curdir} ${curdir}/*)
    set(dirlist "")
    foreach(child ${children})
        if(IS_DIRECTORY ${curdir}/${child})
            LIST(APPEND dirlist ${child})
        endif()
    endforeach()
    set(${result} ${dirlist})
endmacro()

# 安装指定目标文件
function(INSTALL_TARGETS)
    cmake_parse_arguments(PARA "" "" "TARGETS" ${ARGN})
    if(NOT DEFINED PARA_TARGETS)
        return()
    endif()

    foreach(component ${PARA_TARGETS})
        if(ANDROID)
            INSTALL(FILES $<TARGET_FILE:${component}>
                DESTINATION "libs/${ANDROID_ABI}"
                    COMPONENT Runtime)
        elseif(WIN32)
            INSTALL(FILES $<TARGET_FILE:${component}>
                DESTINATION "${CMAKE_INSTALL_BINDIR}"
                    COMPONENT Runtime)
        else()
            INSTALL(FILES $<TARGET_FILE:${component}>
                DESTINATION "${CMAKE_INSTALL_LIBDIR}"
                    COMPONENT Runtime)
        endif()
    endforeach()
endfunction()

# 安装目标
#    [必须]NAME              目标名
#    ISEXE                  是执行程序目标还是库目标
#    ISPLUGIN               是插件
#    RUNTIME
#    LIBRARY
#    ARCHIVE
#    PUBLIC_HEADER    头文件的安装位置
#    INCLUDES         导出安装头文件位置
function(INSTALL_TARGET)
    cmake_parse_arguments(PARA "ISEXE;ISPLUGIN"
        "NAME;RUNTIME;LIBRARY;ARCHIVE;PUBLIC_HEADER;"
        "INCLUDES"
        ${ARGN})
    if(NOT DEFINED PARA_NAME)
        message(FATAL_ERROR "Use:
            INSTALL_TARGET
                NAME name
                [ISEXE]
                [RUNTIME ...]
                [LIBRARY ...]
                [ARCHIVE ...]
                [PUBLIC_HEADER ...]
                [INCLUDES ...]"
                )
    endif()
    
    # Install target
    if(ANDROID)
        if(NOT DEFINED PARA_RUNTIME)
            set(PARA_RUNTIME "libs/${ANDROID_ABI}")
        endif()
        if(NOT DEFINED PARA_LIBRARY)
            set(PARA_LIBRARY "libs/${ANDROID_ABI}")
        endif()
        if(NOT DEFINED PARA_ARCHIVE)
            set(PARA_ARCHIVE "${CMAKE_INSTALL_LIBDIR}")
        endif()
    elseif(WIN32)
        if(NOT DEFINED PARA_RUNTIME)
            set(PARA_RUNTIME "${CMAKE_INSTALL_BINDIR}")
        endif()
        if(NOT DEFINED PARA_LIBRARY)
            set(PARA_LIBRARY "${CMAKE_INSTALL_BINDIR}")
        endif()
        if(NOT DEFINED PARA_ARCHIVE)
            set(PARA_ARCHIVE "${CMAKE_INSTALL_LIBDIR}")
        endif()
    else()
        if(NOT DEFINED PARA_RUNTIME)
            set(PARA_RUNTIME "${CMAKE_INSTALL_BINDIR}")
        endif()
        if(NOT DEFINED PARA_LIBRARY)
            set(PARA_LIBRARY "${CMAKE_INSTALL_LIBDIR}")
        endif()
        if(NOT DEFINED PARA_ARCHIVE)
            set(PARA_ARCHIVE "${CMAKE_INSTALL_LIBDIR}")
        endif()
    endif()
    
    if(PARA_ISEXE)
        INSTALL(TARGETS ${PARA_NAME}
                    COMPONENT Runtime
                RUNTIME DESTINATION "${PARA_RUNTIME}"
                LIBRARY DESTINATION "${PARA_LIBRARY}"
                ARCHIVE DESTINATION "${PARA_ARCHIVE}"
                )
            
        #分发
        IF(ANDROID)
            Set(JSON_FILE ${CMAKE_BINARY_DIR}/android_deployment_settings.json)
            GENERATED_DEPLOYMENT_SETTINGS(NAME ${JSON_FILE}
                ANDROID_SOURCES_DIR ${PARA_ANDROID_SOURCES_DIR}
                APPLACTION "${CMAKE_BINARY_DIR}/bin/lib${PARA_NAME}.so")

            add_custom_target(APK #注意 需要把 ${QT_INSTALL_DIR}/bin 加到环境变量PATH中
                    COMMAND "${QT_INSTALL_DIR}/bin/androiddeployqt"
                        --output ${CMAKE_INSTALL_PREFIX}
                        --input ${JSON_FILE}
                        --verbose
                        --gradle
                        --android-platform ${ANDROID_PLATFORM}
                )
        ENDIF(ANDROID)

    else()
                
        if(PARA_ISPLUGIN)
            INSTALL(TARGETS ${PARA_NAME}
                LIBRARY DESTINATION "${PARA_LIBRARY}"
                    COMPONENT Runtime
                )
        else()
            if(NOT DEFINED PARA_PUBLIC_HEADER)
                set(PARA_PUBLIC_HEADER ${CMAKE_INSTALL_INCLUDEDIR}/${PARA_NAME})
            endif()
            if(NOT DEFINED PARA_INCLUDES)
                set(PARA_INCLUDES ${CMAKE_INSTALL_INCLUDEDIR})
            endif()
            
            INSTALL(TARGETS ${PARA_NAME}
                EXPORT ${PARA_NAME}Config
                RUNTIME DESTINATION "${PARA_RUNTIME}"
                    COMPONENT Runtime
                LIBRARY DESTINATION "${PARA_LIBRARY}"
                    COMPONENT Runtime
                ARCHIVE DESTINATION "${PARA_ARCHIVE}"
                PUBLIC_HEADER DESTINATION ${PARA_PUBLIC_HEADER}
                INCLUDES DESTINATION ${PARA_INCLUDES}
                )
            
            export(TARGETS ${PARA_NAME}
                APPEND FILE ${CMAKE_BINARY_DIR}/${PARA_NAME}Config.cmake
                )
            
            # Install cmake configure files
            install(EXPORT ${PARA_NAME}Config
                DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake"
                )
            # Install cmake version configure file
            if(DEFINED PARA_VERSION)
                write_basic_package_version_file(
                    "${CMAKE_BINARY_DIR}/${PARA_NAME}ConfigVersion.cmake"
                    VERSION ${PARA_VERSION}
                    COMPATIBILITY AnyNewerVersion)
                install(FILES "${CMAKE_BINARY_DIR}/${PARA_NAME}ConfigVersion.cmake"
                    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake")
            endif()
        endif()
    endif()

    # 分发
    IF(WIN32 AND (BUILD_SHARED_LIBS OR PARA_ISEXE))
        IF(MINGW)
            # windeployqt 分发时，是根据是否 strip 来判断是否是 DEBUG 版本,而用mingw编译时,qt没有自动 strip
            add_custom_command(TARGET ${PARA_NAME} POST_BUILD
                COMMAND strip "$<TARGET_FILE:${PARA_NAME}>"
                )
        ENDIF()

        #注意 需要把 ${QT_INSTALL_DIR}/bin 加到环境变量PATH中
        add_custom_command(TARGET ${PARA_NAME} POST_BUILD
            COMMAND "${QT_INSTALL_DIR}/bin/windeployqt"
            --compiler-runtime
            --verbose 7
            "$<TARGET_FILE:${PARA_NAME}>"
            )

        if(PARA_ISEXE)
            INSTALL(DIRECTORY "$<TARGET_FILE_DIR:${PARA_NAME}>/"
                DESTINATION "${PARA_RUNTIME}"
                    COMPONENT Runtime)
        endif()
    ENDIF()
endfunction()

# 增加目标
# 参数：
#    ISEXE                   是执行程序目标还是库目标
#    ISPLUGIN                是插件
#    WINDOWS                 窗口程序
#    NAME                    目标名
#    OUTPUT_DIR              目标生成目录
#    VERSION                 版本
#    ANDROID_SOURCES_DIR     Android 源码文件目录
#    [必须]SOURCE_FILES       源文件（包括头文件，资源文件等）
#    INSTALL_HEADER_FILES    如果是库，要安装的头文件
#    INCLUDE_DIRS            包含目录
#    PRIVATE_INCLUDE_DIRS    私有包含目录
#    LIBS                    公有依赖库
#    PRIVATE_LIBS            私有依赖库
#    DEFINITIONS             公有宏定义
#    PRIVATE_DEFINITIONS     私有宏宏义
#    OPTIONS                 公有选项
#    PRIVATE_OPTIONS         私有选项
#    FEATURES                公有特性
#    PRIVATE_FEATURES        私有特性
#    INSTALL_PUBLIC_HEADER   要的头文件安装位置
#    INSTALL_INCLUDES        包含头文件位置
#    INSTALL_LIBRARY_DIR     库安装位置
function(ADD_TARGET)
    SET(MUT_PARAS
        SOURCE_FILES            #源文件（包括头文件，资源文件等）
        INSTALL_HEADER_FILES    #如果是库，要安装的头文件
        INCLUDE_DIRS            #包含目录
        PRIVATE_INCLUDE_DIRS    #私有包含目录
        LIBS                    #公有依赖库
        PRIVATE_LIBS            #私有依赖库
        DEFINITIONS             #公有宏定义
        PRIVATE_DEFINITIONS     #私有宏宏义
        OPTIONS                 #公有选项
        PRIVATE_OPTIONS         #私有选项
        FEATURES                #公有特性
        PRIVATE_FEATURES        #私有特性
        INSTALL_INCLUDES        #导出包安装的头文件目录
        )
    cmake_parse_arguments(PARA "ISEXE;ISPLUGIN;ISWINDOWS"
        "NAME;OUTPUT_DIR;VERSION;ANDROID_SOURCES_DIR;INSTALL_PUBLIC_HEADER;INSTALL_LIBRARY_DIR"
        "${MUT_PARAS}"
        ${ARGN})
    if(NOT DEFINED PARA_SOURCE_FILES)
        message(FATAL_ERROR "Use:
            ADD_TARGET
                [NAME name]
                [ISEXE]
                [ISPLUGIN]
                [ISWINDOWS]
                SOURCE_FILES source1 [source2 ... header1 ...]]
                [INSTALL_HEADER_FILES header1 [header2 ...]]
                [LIBS lib1 [lib2 ...]]
                [PRIVATE_LIBS lib1 [lib2 ...]]
                [INCLUDE_DIRS [include_dir1 ...]]
                [PRIVATE_INCLUDE_DIRS [include_dir1 ...]]
                [DEFINITIONS [definition1 ...]]
                [PRIVATE_DEFINITIONS [defnitions1 ...]]
                [OUTPUT_DIR output_dir]
                [PRIVATE_OPTIONS option1 [option2 ...]]
                [OPTIONS option1 [option2 ...]]
                [FEATURES feature1 [feature2 ...]]
                [PRIVATE_FEATURES feature1 [feature2 ...]]
                [VERSION version]
                [ANDROID_SOURCES_DIR android_source_dir]
                [INSTALL_LIBRARY_DIR dir]")
        return()
    endif()

    if(NOT DEFINED PARA_NAME)
        set(PARA_NAME ${PROJECT_NAME})
    endif()
    
    if(PARA_ISEXE)
        if(ANDROID)
            add_library(${PARA_NAME} SHARED ${PARA_SOURCE_FILES} ${PARA_INSTALL_HEADER_FILES})
        else()
            if(DEFINED PARA_ISWINDOWS AND WIN32)
                set(WINDOWS_APP WIN32)
            endif()    
            add_executable(${PARA_NAME} ${WINDOWS_APP} ${PARA_SOURCE_FILES} ${PARA_INSTALL_HEADER_FILES})
            
            if(MINGW)
                set_target_properties(${PARA_NAME} PROPERTIES LINK_FLAGS_RELEASE "-mwindows")
            elseif(MSVC)
                if(Qt5_VERSION VERSION_LESS "5.7.0")
                    set_target_properties(${PARA_NAME} PROPERTIES LINK_FLAGS
                        "/SUBSYSTEM:WINDOWS\",5.01\" /ENTRY:mainCRTStartup")
                else()
                    set_target_properties(${PARA_NAME} PROPERTIES LINK_FLAGS
                        "/SUBSYSTEM:WINDOWS /ENTRY:mainCRTStartup")
                endif()
            endif()
        endif()
    else()
        string(TOLOWER ${PARA_NAME} LOWER_PROJECT_NAME)
        set(PARA_INSTALL_HEADER_FILES ${PARA_INSTALL_HEADER_FILES} 
            ${CMAKE_CURRENT_BINARY_DIR}/${LOWER_PROJECT_NAME}_export.h)
        
        add_library(${PARA_NAME} ${PARA_SOURCE_FILES} ${PARA_INSTALL_HEADER_FILES})
        
        GENERATE_EXPORT_HEADER(${PARA_NAME})
        file(COPY ${CMAKE_CURRENT_BINARY_DIR}/${LOWER_PROJECT_NAME}_export.h
            DESTINATION ${CMAKE_BINARY_DIR})
    endif()

    if(DEFINED PARA_OUTPUT_DIR)
        set_target_properties(${PARA_NAME} PROPERTIES
            LIBRARY_OUTPUT_DIRECTORY ${PARA_OUTPUT_DIR}
            ARCHIVE_OUTPUT_DIRECTORY ${PARA_OUTPUT_DIR}
            RUNTIME_OUTPUT_DIRECTORY ${PARA_OUTPUT_DIR}
            )
    else()
        set_target_properties(${PARA_NAME} PROPERTIES
            LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
            RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
            ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
            )
    endif()

    if(DEFINED PARA_INSTALL_HEADER_FILES)
        set_target_properties(${PARA_NAME} PROPERTIES
            PUBLIC_HEADER "${PARA_INSTALL_HEADER_FILES}" # Install head files
            )
    endif()

    if(DEFINED PARA_VERSION)
        set_target_properties(${PARA_NAME} PROPERTIES
            VERSION ${PARA_VERSION})
    else()
	    get_target_property(PARA_VERSION ${PARA_NAME} VERSION)
    endif()
    
    if(DEFINED PARA_LIBS)
        target_link_libraries(${PARA_NAME} PUBLIC ${PARA_LIBS})
    endif()
    
    if(DEFINED PARA_PRIVATE_LIBS)
        target_link_libraries(${PARA_NAME} PRIVATE ${PARA_PRIVATE_LIBS})
    endif()

    if(DEFINED PARA_DEFINITIONS)
        target_compile_definitions(${PARA_NAME} PUBLIC ${PARA_DEFINITIONS})
    endif()
    
    if(DEFINED PARA_PRIVATE_DEFINITIONS)
        target_compile_definitions(${PARA_NAME} PRIVATE ${PARA_PRIVATE_DEFINITIONS})
    endif()

    if(DEFINED PARA_INCLUDE_DIRS)
        target_include_directories(${PARA_NAME} PUBLIC ${PARA_INCLUDE_DIRS})
    endif()

    if(DEFINED PARA_PRIVATE_INCLUDE_DIRS)
        target_include_directories(${PARA_NAME} PRIVATE ${PARA_PRIVATE_INCLUDE_DIRS})
    endif()
    
    if(DEFINED PARA_OPTIONS)
        target_compile_options(${PARA_NAME} PUBLIC ${PARA_OPTIONS})
    endif()

    if(DEFINED PARA_PRIVATE_OPTIONS)
        target_compile_options(${PARA_NAME} PRIVATE ${PARA_PRIVATE_OPTIONS})
    endif()

    if(DEFINED PARA_FEATURES)
        target_compile_features(${PARA_NAME} PUBLIC ${PARA_FEATURES})
    endif()

    if(DEFINED PARA_PRIVATE_FEATURES)
        target_compile_features(${PARA_NAME} PRIVATE ${PARA_PRIVATE_FEATURES})
    endif()

    INSTALL_TARGET(NAME ${PARA_NAME}
        ${PARA_ISPLUGIN}
        PUBLIC_HEADER ${PARA_INSTALL_PUBLIC_HEADER}
        INCLUDES ${PARA_INSTALL_INCLUDES}
        LIBRARY ${PARA_INSTALL_LIBRARY_DIR})
    
endfunction()

# 增加插件目标
# 参数：
#  NAME                    目标名
#  OUTPUT_DIR              目标生成目录
#  VERSION                 版本
#  ANDROID_SOURCES_DIR     Android 源码文件目录
#  [必须]SOURCE_FILES       源文件（包括头文件，资源文件等）
#  INCLUDE_DIRS            包含目录
#  PRIVATE_INCLUDE_DIRS    私有包含目录
#  LIBS                    公有依赖库
#  PRIVATE_LIBS            私有依赖库
#  DEFINITIONS             公有宏定义
#  PRIVATE_DEFINITIONS     私有宏宏义
#  OPTIONS                 公有选项
#  PRIVATE_OPTIONS         私有选项
#  FEATURES                公有特性
#  PRIVATE_FEATURES        私有特性
#  INSTALL_DIR             插件库安装目录
function(ADD_PLUGIN_TARGET)
    SET(MUT_PARAS
        SOURCE_FILES            #源文件（包括头文件，资源文件等）
        INCLUDE_DIRS            #包含目录
        LIBS                    #公有依赖库
        PRIVATE_LIBS            #私有依赖库
        DEFINITIONS             #公有宏定义
        PRIVATE_DEFINITIONS     #私有宏宏义
        OPTIONS                 #公有选项
        PRIVATE_OPTIONS         #私有选项
        FEATURES                #公有特性
        PRIVATE_FEATURES        #私有特性
        )
    cmake_parse_arguments(PARA ""
        "NAME;OUTPUT_DIR;VERSION;ANDROID_SOURCES_DIR;INSTALL_DIR"
        "${MUT_PARAS}"
        ${ARGN})
    if(NOT DEFINED PARA_SOURCE_FILES)
        message(FATAL_ERROR "Use:
            ADD_TARGET
                [NAME name]
                SOURCE_FILES source1 [source2 ... header1 ...]]
                [LIBS lib1 [lib2 ...]]
                [PRIVATE_LIBS lib1 [lib2 ...]]
                [INCLUDE_DIRS [include_dir1 ...]]
                [PRIVATE_INCLUDE_DIRS [include_dir1 ...]]
                [DEFINITIONS [definition1 ...]]
                [PRIVATE_DEFINITIONS [defnitions1 ...]]
                [OUTPUT_DIR output_dir]
                [PRIVATE_OPTIONS option1 [option2 ...]]
                [OPTIONS option1 [option2 ...]]
                [FEATURES feature1 [feature2 ...]]
                [PRIVATE_FEATURES feature1 [feature2 ...]]
                [VERSION version]
                [ANDROID_SOURCES_DIR android_source_dir]")
        return()
    endif()
    
    if(NOT DEFINED PARA_OUTPUT_DIR)
        set(PARA_OUTPUT_DIR ${CMAKE_BINARY_DIR}/plugins)
    endif()
    
    if(NOT DEFINED PARA_INSTALL_DIR)
        set(PARA_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/plugins)
    endif()
    
    ADD_TARGET(NAME ${PARA_NAME}
        ISPLUGIN
        OUTPUT_DIR ${PARA_OUTPUT_DIR}
        VERSION ${PARA_VERSION}
        ANDROID_SOURCES_DIR ${PARA_ANDROID_SOURCES_DIR}
        SOURCE_FILES ${PARA_SOURCE_FILES}
        LIBS ${PARA_LIBS}
        PRIVATE_LIBS ${PARA_PRIVATE_LIBS}
        DEFINITIONS ${PARA_DEFINITIONS}
        PRIVATE_DEFINITIONS ${PARA_PRIVATE_DEFINITIONS}
        OPTIONS ${PARA_OPTIONS}
        PRIVATE_OPTIONS ${PARA_PRIVATE_OPTIONS}
        FEATURES ${FEATURES}
        PRIVATE_FEATURES ${PRIVATE_FEATURES}
        PRIVATE_INCLUDE_DIRS ${PARA_PRIVATE_INCLUDE_DIRS}
        INSTALL_DIR ${PARA_INSTALL_DIR}
        )
endfunction()
