# Sagittarius

Sagittarius is a game made by George Prosser (not me). 

Here is the itch.io page where he released the game:

<iframe src="https://itch.io/embed/31280" height="167" width="552" frameborder="0"><a href="https://gprosser.itch.io/sagittarius">Sagittarius by George Prosser</a></iframe>



## How to Build and Run

I recommend that if you are installing this game simply to play it then you download it directly from the itch.io page that is linked and run that. It would be more stable, and would be directly from the creator. In order to run the `.love` file from the itch.io link you will need LOVE version [0.9.1](https://love2d.org/wiki/0.9.1).

However if you still want to build and run this (for whatever reason: maybe you want to make changes) then here are the steps to do so:

1.  Install LOVE (verison 11.4 (Mysterious Mysteries))
2.  Clone the repo into a directory
3.  run `love .` in said directory



## What I Have Changed To Port Sagittarius

-   Fixed the colour-space
    -   Changed the colours from 8-bit ints (0 to 255) to floats (0 to 1)
-   Ported the old graphics from using `love.graphics.setStencil` to `love.graphics.stencil`:
    -   Used the `StencilAction` `'replace'`
    -   Used `false` for `keepvalues` (stencil must be wiped if no longer present)
    -   Enabled stencils on the canvas: `love.graphics.setCanvas(canvas, stencil=true)`
    -   Reset the screen buffer every frame with `love.graphics.clear()`
-   Fixed love's input bindings:
    -   Changed the mouse inputs from being indexed `l` and `r` to `1` and `2`
    -   Changed the spacebar inputs from being indexed `' '` to `'space'`



## TODO

-   Controller/Joystick Support
-   Sockets?

