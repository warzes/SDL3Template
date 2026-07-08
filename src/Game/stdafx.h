#pragma once

#if defined(_MSC_VER)
#	pragma warning(push, 3)
#	pragma warning(disable : 5262)
#endif

#define _USE_MATH_DEFINES

#if defined(__EMSCRIPTEN__)
#	include <emscripten/emscripten.h>
#elif defined(_WIN32)
#else
#endif

#include <cassert>
#include <cstdint>
#include <cmath>
#include <cstdio>
#include <cstring>

#include <SDL3/SDL.h>

#include <nlohmann/json.hpp>

#include <stb/stb_image.h>

#include <Engine/engine.h>

#if defined(_MSC_VER)
#	pragma warning(pop)
#endif