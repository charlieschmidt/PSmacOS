# libpsmacosbridging cmake configuration file

cmake_minimum_required(VERSION 2.8)
set(CMAKE_MACOSX_RPATH 1)
project(libpsmacosbridging)

if ( ${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR} )
    message( FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there. You may need to remove CMakeCache.txt." )
endif()

set(GCC_COMPILE_FLAGS "-std=c99 -Wall -pedantic -g -fobjc-arc")

execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpversion
                OUTPUT_VARIABLE GCC_VERSION)
if (GCC_VERSION VERSION_GREATER 4.9 OR GCC_VERSION VERSION_EQUAL 4.9)
    set(GCC_COMPILE_FLAGS "${GCC_COMPILE_FLAGS} -fdiagnostics-color=auto")
endif()
set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} ${GCC_COMPILE_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -pedantic -g")

#set_source_files_properties(*.m PROPERTIES COMPILE_FLAGS "-x objective-c")

set(LIBPSMACOSBRIDGING_PRIVATE_LIBS ${LIBPSMACOSBRIDGING_PRIVATE_LIBS} "-framework Cocoa")

# Source files
set(OBJC_HEADERS
    libpsmacosbridging.h
)

set(OBJC_SOURCE
    bridge_gridview.m
    bridge_memory.m
    bridge_messagebox.m
    bridge_pasteboard.m
)

# Set the output folders
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Make the library
add_library(psmacosbridging SHARED ${OBJC_HEADERS} ${OBJC_SOURCE})
set_target_properties(psmacosbridging PROPERTIES SOVERSION 1)
target_link_libraries(psmacosbridging LINK_PRIVATE ${LIBPSMACOSBRIDGING_PRIVATE_LIBS})

# Install options
install(TARGETS psmacosbridging
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)


