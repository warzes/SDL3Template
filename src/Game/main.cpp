#include "stdafx.h"
//=============================================================================
#if defined(_MSC_VER)
#	pragma comment( lib, "3rdparty.lib" )
#	pragma comment( lib, "Engine.lib" )
#endif
//=============================================================================
static int gDone;
static SDL_Window* gWindow = NULL;
static SDL_Renderer* gRenderer = NULL;
//=============================================================================
bool update()
{
	SDL_Event e;
	if (SDL_PollEvent(&e))
	{
		if (e.type == SDL_EVENT_QUIT)
		{
			return false;
		}
		if (e.type == SDL_EVENT_KEY_UP && e.key.key == SDLK_ESCAPE)
		{
			return false;
		}
	}

	return true;
}
//=============================================================================
void render(Uint64 aTicks)
{
	SDL_FRect rect;

	SDL_SetRenderDrawColor(gRenderer, 33, 33, 33, SDL_ALPHA_OPAQUE);
	SDL_RenderClear(gRenderer);

	SDL_SetRenderDrawColor(gRenderer, 0, 0, 255, SDL_ALPHA_OPAQUE);
	rect.x = rect.y = 100;
	rect.w = 440;
	rect.h = 280;
	SDL_RenderFillRect(gRenderer, &rect);

	SDL_SetRenderDrawColor(gRenderer, 0, 255, 0, SDL_ALPHA_OPAQUE);
	rect.x += 30;
	rect.y += 30;
	rect.w -= 60;
	rect.h -= 60;
	SDL_RenderRect(gRenderer, &rect);

	SDL_SetRenderDrawColor(gRenderer, 255, 255, 0, SDL_ALPHA_OPAQUE);
	SDL_RenderLine(gRenderer, 0, 0, 640, 480);
	SDL_RenderLine(gRenderer, 0, 480, 640, 0);

	SDL_RenderPresent(gRenderer);
}
//=============================================================================
void loop()
{
	if (!update())
	{
		gDone = 1;
#ifdef __EMSCRIPTEN__
		emscripten_cancel_main_loop();
#endif
	}
	else
	{
		render(SDL_GetTicks());
	}
}
//=============================================================================
int main(int argc, char* argv[])
{
	FooEngine(); // TODO: delete

	if (!SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS))
	{
		SDL_Log("Couldn't initialize SDL: %s", SDL_GetError());
		return SDL_APP_FAILURE;
	}

	if (!SDL_CreateWindowAndRenderer("Minimal", 640, 480, SDL_WINDOW_RESIZABLE, &gWindow, &gRenderer))
	{
		SDL_Log("Couldn't create window/renderer: %s", SDL_GetError());
		return SDL_APP_FAILURE;
	}
	SDL_SetRenderLogicalPresentation(gRenderer, 640, 480, SDL_LOGICAL_PRESENTATION_LETTERBOX);

#ifdef __EMSCRIPTEN__
	emscripten_set_main_loop(loop, 0, 1);
#else
	while (!gDone)
	{
		loop();
	}
#endif

	SDL_DestroyRenderer(gRenderer);
	SDL_DestroyWindow(gWindow);
	SDL_Quit();
}
//=============================================================================
