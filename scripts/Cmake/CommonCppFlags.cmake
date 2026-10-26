#-------------------------------------------------------------------------------------------
# Compiler Flag Detection
#-------------------------------------------------------------------------------------------
# TODO: This is currently duplicated in EASTL can we consolidate somehow?
include(CheckCXXCompilerFlag)

check_cxx_compiler_flag("-fchar8_t" EATHREAD_HAS_FCHAR8T_FLAG)
check_cxx_compiler_flag("/Zc:char8_t" EATHREAD_HAS_ZCCHAR8T_FLAG)

if(EATHREAD_HAS_FCHAR8T_FLAG)
    set(EATHREAD_CHAR8T_FLAG "-fchar8_t")
    set(EATHREAD_NO_CHAR8T_FLAG "-fno-char8_t")
elseif(EATHREAD_HAS_ZCCHAR8T_FLAG)
    set(EATHREAD_CHAR8T_FLAG "/Zc:char8_t")
    set(EATHREAD_NO_CHAR8T_FLAG "/Zc:char8_t-")
endif()

#-------------------------------------------------------------------------------------------
# C++ Standard
#-------------------------------------------------------------------------------------------
# Build with the newest C++ standard the compiler supports, unless one was explicitly
# selected through CMAKE_CXX_STANDARD.
if(NOT DEFINED CMAKE_CXX_STANDARD)
    if(MSVC) # cl and clang-cl
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++latest")
    else()
        foreach(EATHREAD_STD_FLAG -std=c++26 -std=c++2c -std=c++23 -std=c++2b -std=c++20 -std=c++2a -std=c++17 -std=c++1z -std=c++14 -std=c++1y -std=c++11)
            string(MAKE_C_IDENTIFIER "EATHREAD_HAS_${EATHREAD_STD_FLAG}_FLAG" EATHREAD_STD_FLAG_VAR)
            check_cxx_compiler_flag(${EATHREAD_STD_FLAG} ${EATHREAD_STD_FLAG_VAR})
            if(${EATHREAD_STD_FLAG_VAR})
                set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${EATHREAD_STD_FLAG}")
                break()
            endif()
        endforeach()
    endif()
endif()

#-------------------------------------------------------------------------------------------
# Compiler Flags
#-------------------------------------------------------------------------------------------
if(UNIX AND "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel" )
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fasm-blocks" )
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "3.1")
        message(FATAL_ERROR "Building with a Apple clang version less than 3.1 is not supported.")
    endif()
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND NOT CMAKE_CXX_SIMULATE_ID MATCHES "MSVC") # clang, but not clang-cl.
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "3.0")
        message(FATAL_ERROR "Building with a clang version less than 3.0 is not supported.")
    endif()
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.7.3")
        message(FATAL_ERROR "Building with a gcc version less than 4.7.3 is not supported.")
    endif()
elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    # Report the real language version in __cplusplus and use the standard-conforming preprocessor.
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4 /permissive- /Zc:__cplusplus")
    check_cxx_compiler_flag("/Zc:preprocessor" EATHREAD_HAS_ZCPREPROCESSOR_FLAG)
    if(EATHREAD_HAS_ZCPREPROCESSOR_FLAG)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:preprocessor")
    endif()
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND CMAKE_CXX_SIMULATE_ID MATCHES "MSVC") # clang-cl
    # Two-phase name lookup in every language mode: before C++20, clang-cl defaults to delayed template parsing.
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /permissive-")
endif()


if (CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -D_DEBUG")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -D_DEBUG")
endif()
