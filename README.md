# Roblox-3D-Engine
A satisfactory 3D Engine that works for roblox.\
Check the latest release and the Wiki.

## Features
- Object File loading
- Textures
- View Plane Clipping
- Z Depth Buffer
- Support for CFrame Matrices
- Model functions like moving, rotating and sizing
- And much more!

## Other Information
To render textures and read them inside roblox, my engine uses the [CanvasDraw] module. I do not own this module, and it is only as optimized as the creator made it to be.
This also uses ported code from Python which this guy made: https://www.youtube.com/c/@FinFet. It also uses a triangle clipping function that was ported from this guy's ConsoleGameEngine: https://www.youtube.com/c/@javidx9.
I will probably be updating this repository to fix other bugs or use other methods. If you are using this, __please credit me__.
> Note: ~~This engine is not perfect, it still needs to be optimized more~~ Like it can be optimized more lmao it uses multithreading, native code, and DynamicImage.

![blast](Screenshots/Screenshot 2023-10-09 093557.png)

[CanvasDraw]: <https://devforum.roblox.com/t/canvasdraw-a-powerful-pixel-based-graphics-engine-draw-pixels-lines-triangles-read-png-image-data-and-much-more/1624633>
[CanvasDraw Image Importer]: <https://create.roblox.com/marketplace/asset/8580432843/CanvasDraw-Image-Importer>
[Objects/Cube.lua]: <https://github.com/OrangeCash090/Roblox-3D-Engine/blob/main/Objects/Cube.lua>
