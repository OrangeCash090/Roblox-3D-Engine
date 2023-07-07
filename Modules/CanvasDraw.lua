--[[
	================== CanvasDraw ===================
	
	Created by: Ethanthegrand (@Ethanthegrand14)
	
	Last updated: 10/02/2023
	Version: 3.1.2
	
	Learn how to use the module here: https://devforum.roblox.com/t/1624633
	Detailed API Documentation: https://devforum.roblox.com/t/2017699
	
	Copyright © 2022 - 2023 | CanvasDraw
]]
--[[
	============== QUICK API REFERENCE ==============

	CanvasDraw Functions:
	
	   - CanvasDraw.new(Frame: GuiObject, Resolution: Vector2?, CanvasColour: Color3?) : Canvas
	      * Constructs and returns a canvas class/object
	
	   - CanvasDraw.GetImageDataFromSaveObject(SaveObject: Folder): {...}
	      * Reads the selected SaveObject's compressed ImageData and returns a readable ImageData class
	      
	   - CanvasDraw.CreateSaveObject(ImageData: Table, InstantCreate: boolean?): Folder
	      * Returns a physical save object (a folder instance) containing compressed ImageData.
	      * This instance can be stored anywhere in your place and be loaded into CanvasDraw at any time.
		  * When 'InstantCreate' is set to false, CanvasDraw will slowly create the SaveObject to 
		    avoid lag (Doing this is recommended for large images).
	   
	   - CanvasDraw.GetPixelFromImage(ImageData: Table, Point: Vector2): Color3, number
	   - CanvasDraw.GetPixelFromImageXY(ImageData: Table, X: number, Y: number): Color3, number
	      * Returns a tuple of the pixel colour and the pixel alpha value from a point in the ImageData.
	
	Canvas Properties:
		
	   - OutputWarnings: boolean
	      * Determines whether any warning messages will appear in the output if something is out of place 
	        or not working correctly according to the module.
	   
	   - AutoUpdate: boolean
	      * Determines whether the canvas will automatically update and render the pixels on the canvas every heartbeat.
	      * Set this property to false and call the Update() method to manually update and render the canvas.
	   
	   - Canvas.CanvasColour: Color3 [READ ONLY]
	      * The default background colour of the generated canvas.
	   
	   - Canvas.Resolution: Vector2 [READ ONLY]
	      * The current resolution of the canvas.
	   
	Canvas Drawing Methods:
	
	   - Canvas:FloodFill(Point: Vector2, Colour: Color3) : {...}
	     * This function will fill an area of pixels on the canvas of the specific colour that your point is on.
	     * An array will also be returned containing all pixel points that were used to fill with.
	     
	  - Canvas:DrawPixel(Point: Vector2, Colour: Color3) : Vector2
	  - Canvas:SetPixel(X: number, Y: number, Colour: Color3)
	     * Places a pixel on the canvas
	  
	  - Canvas:DrawCircle(Point: Vector2, Radius: number, Colour: Color3, Fill: boolean?) : {...}
	  - Canvas:DrawCircleXY(X: number, Y: number, Radius: number, Colour: Color3, Fill: boolean?)
	     * Draws a circle at a desired point with a set radius and colour.
	  
	  - Canvas:DrawRectangle(PointA: Vector2, PointB: Vector2, Colour: Color3, Fill: boolean?) : {...}
	  - Canvas:DrawRectangleXY(X1: number, Y1: number, X2: number, Y2: number, Colour: Color3, Fill: boolean?)
	     * Draws a simple rectangle shape from point A (top left) to point B (bottom right).
	  
	  - Canvas:DrawTriangle(PointA: Vector2, PointB: Vector2, PointC: Vector2, Colour: Color3, Fill: boolean?) : {...}
	  - Canvas:DrawTriangleXY(X1: number, Y1: number, X2: number, Y2: number, X3: number, Y3: number, Colour: Color3, Fill: boolean?)
	     * Draws a three sided triangle from three points on the canvas.
	  
	  - Canvas:DrawLine(PointA: Vector2, PointB: Vector2, Colour: Color3) : {...}
	  - Canvas:DrawLineXY(X1: number, Y1: number, X1: number, Y1: number, Colour: Color3)
	     * Draws a simple pixel line from two points on the canvas.
	  
	  - Canvas:DrawText(Text: string, Point: Vector2, Colour: Color3, Scale: number?, Wrap: boolean?, Spacing: number?)
	  - Canvas:DrawTextXY(Text: string, X: number, Y: number, Colour: Color3, Scale: number?, Wrap: boolean?, Spacing: number?)
	     * Draw simple pixel text on the canvas.
	
	  - Canvas:DrawImage(ImageData: Table, Point: Vector2?, Scale: Vector2?, TransparencyEnabled: boolean?)
	  - Canvas:DrawImageXY(ImageData: Table, X: number?, Y: number?, ScaleX: number?, ScaleY: number?, TransparencyEnabled: boolean?)
	     * Draws an image to the canvas from ImageData.
	
	Canvas Fetch Methods:
	
	   - Canvas:GetPixel(Point: Vector2) : Color3
	   - Canvas:GetPixelXY(X: number, Y: number) : Color3
	      * Returns the chosen pixel's colour (Color3)
	   
	   - Canvas:GetPixels(PointA: Vector2?, PointB: Vector2?) : {...}
	      * Returns all pixels ranging from PointA to PointB
	   
	   - Canvas:GetMousePoint() : Vector2? [CLIENT ONLY]
	      * If the client's mouse is within the canvas, a canvas point (Vector2) will be returned
	        Otherwise, nothing will be returned (nil)
	      * This function is compatible with Guis and SurfaceGuis
	        
	        
	Canvas ImageData Methods:
	
	   - Canvas:CreateImageDataFromCanvas(PointA: Vector2?, PointB: Vector2?) : ImageData
	      * Returns an ImageData class/table from the canvas pixels from PointA to PointB or the whole canvas.
	   
	
	Other Canvas Methods:
	
	   - Canvas:DestroyCanvas()
	      * Destroys the canvas
	   
	   - Canvas:FillCanvas(Colour: Color3)
	      * Replaces every pixel on the canvas with a colour
	   
	   - Canvas:ClearCanvas()
	      * Replaces every current pixel on the canvas with the canvas colour
	      
	   - Canvas:Update()
	      * Manually update/render the canvas (if Canvas.AutoUpdate is set to 'false')
	
	Canvas Events:
	
	   - Canvas.Updated(DeltaTime)
	      * The same as RunService.Heartbeat.
	      * This event is what CanvasDraw uses to update the canvas every frame when the AutoUpdate property is set to true.
	      

]]

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Modules
local GradientCanvas = require(script:WaitForChild("FastCanvas")) -- Credits to BoatBomber
local StringCompressor = require(script:WaitForChild("StringCompressor")) -- Credits to 1waffle1 and BoatBomber
local PixelTextCharacters = require(script:WaitForChild("TextCharacters"))
local VectorFuncs = require(script:WaitForChild("VectorFuncs")) -- Credits to Krystaltinan

local CanvasDrawModule = {}

-- These variables are only accessed by this module (do not edit)
local SaveObjectResolutionLimit = Vector2.new(256, 256) -- Roblox string value character limits T-T
local CanvasResolutionLimit = Vector2.new(256, 256) -- Too many frames can cause rendering issues for roblox. So I think having this limit will help solve this problem for now.

-- Micro optimisations
local TableInsert = table.insert
local TableFind = table.find
local RoundN = math.round
local Vector2New = Vector2.new
local CeilN = math.ceil

--== BUILT-IN FUNCTIONS ==--

local function GetRange(A, B)
	if A > B then
		return RoundN(A - B), -1
	else
		return RoundN(B - A), 1
	end
end

local function RoundPoint(Point)
	local X = RoundN(Point.X)
	local Y = RoundN(Point.Y)
	return Vector2New(X, Y)
end

local function PointToPixelIndex(Point, Resolution)
	local X = RoundN(Point.X)
	local Y = RoundN(Point.Y)
	local ResX = Resolution.X
	local ResY = Resolution.Y
	
	return X + ((Y - 1) * ResX)
end

local function XYToPixelIndex(X, Y, ResolutionX)
	return X + ((Y - 1) * ResolutionX)
end


--== MODULE FUCNTIONS ==--

-- Canvas functions

function CanvasDrawModule.new(Frame: GuiObject, Resolution: Vector2?, CanvasColour: Color3?)
	local Canvas = {
		-- Modifyable properties/events
		OutputWarnings = true,
		AutoUpdate = true,

		-- Read only
		Resolution = Vector2New(100, 100),
		Updated = RunService.Heartbeat, -- Event
	}
	
	
	--==<< Interal Functions >>==--

	local function OutputWarn(Message)
		if Canvas.OutputWarnings then
			warn("(!) CanvasDraw Module Warning: '" .. Message .. "'")
		end
	end

	local function GetIndexForCanvasPixels(X, Y)
		return X + ((Y - 1) * Canvas.CurrentResX)
	end
	
	
	--==<< Canvas Set-up >>==--
	
	-- Parameter defaults
	if CanvasColour then
		Canvas.CanvasColour = CanvasColour 
	else
		Canvas.CanvasColour = Frame.BackgroundColor3
	end

	if Resolution then
		if Resolution.X > CanvasResolutionLimit.X or Resolution.Y > CanvasResolutionLimit.Y then
			OutputWarn("A canvas cannot be built with a resolution larger than " .. CanvasResolutionLimit.X .. " x " .. CanvasResolutionLimit.Y .. ".")
			Resolution = CanvasResolutionLimit
		end
		Canvas.Resolution = Resolution
		Canvas.CurrentResX = Resolution.X
		Canvas.CurrentResY = Resolution.Y
	else
		Canvas.CurrentResX = 100
		Canvas.CurrentResY = 100
	end

	-- Create the canvas
	local InternalCanvas = GradientCanvas.new(Canvas.CurrentResX, Canvas.CurrentResY)
	InternalCanvas:SetParent(Frame)
	
	Canvas.AutoUpdateConnection = RunService.Heartbeat:Connect(function()
		if InternalCanvas and Canvas.AutoUpdate then
			InternalCanvas:Render()
		end
	end)
	
	Canvas.CurrentCanvasFrame = Frame

	for Y = 1, Canvas.CurrentResY do
		for X = 1, Canvas.CurrentResX do
			InternalCanvas:SetPixel(X, Y, Canvas.CanvasColour)
		end
	end
	
	InternalCanvas:Render()
	
	Canvas.InternalCanvas = InternalCanvas
	
	
	
	--============================================================================================================--
	--====  <<   Canvas API   >>   ================================================================================--
	--============================================================================================================--
	
	--==<< Canvas Functions >>==--
	
	function Canvas:DestroyCanvas()
		InternalCanvas:Destroy()
		self.InternalCanvas = nil
		self.CurrentCanvasFrame = nil
		self.AutoUpdateConnection:Disconnect()
	end

	function Canvas:FillCanvas(Colour: Color3)
		for Y = 1, self.CurrentResY do
			for X = 1, self.CurrentResX do
				self:SetPixel(X, Y, Colour)
			end
		end
	end

	function Canvas:ClearCanvas()
		self:FillCanvas(self.CanvasColour)
	end

	function Canvas:Update()
		InternalCanvas:Render()
	end


	--==<< Fetch Functions >>==--

	function Canvas:GetPixel(Point: Vector2): Color3
		Point = RoundPoint(Point)

		local X = Point.X
		local Y = Point.Y

		if X > 0 and Y > 0 and X <= self.CurrentResX and Y <= self.CurrentResY then
			return InternalCanvas:GetPixel(X, Y)
		end
	end

	function Canvas:GetPixelXY(X: number, Y: number): Color3
		return self.InternalCanvas:GetPixel(X, Y)
	end

	function Canvas:GetPixels(PointA: Vector2, PointB: Vector2): {}
		local PixelsArray = {}

		-- Get the all pixels between PointA and PointB
		if PointA and PointB then
			local DistX, FlipMultiplierX = GetRange(PointA.X, PointB.X)
			local DistY, FlipMultiplierY = GetRange(PointA.Y, PointB.Y)

			for Y = 0, DistY do
				for X = 0, DistX do
					local Point = Vector2New(PointA.X + X * FlipMultiplierX, PointA.Y + Y * FlipMultiplierY)
					local Pixel = self:GetPixel(Point)
					if Pixel then
						TableInsert(PixelsArray, Pixel)
					end
				end
			end
		else
			-- If there isn't any points in the paramaters, then return all pixels in the canvas
			for Y = 1, self.CurrentResX do
				for X = 1, self.CurrentResY do
					local Pixel = self:GetPixelXY(X, Y)
					if Pixel then
						TableInsert(PixelsArray, Pixel)
					end
				end
			end
		end

		return PixelsArray
	end

	function Canvas:GetMousePoint(): Vector2?
		if RunService:IsClient() then
			local MouseLocation = UserInputService:GetMouseLocation()
			
			local CanvasFrameSize = self.CurrentCanvasFrame.AbsoluteSize
			local GradientCanvasFrameSize = self.CurrentCanvasFrame.GradientCanvas.AbsoluteSize
			local CanvasPosition = self.CurrentCanvasFrame.AbsolutePosition
			
			local SurfaceGui = Frame:FindFirstAncestorOfClass("SurfaceGui")
			
			if not SurfaceGui then
				-- Gui
				local MousePoint = Vector2New(MouseLocation.X, MouseLocation.Y) - CanvasPosition

				-- Roblox top bar exist T-T
				MousePoint -= Vector2New(0, 36)

				-- Convert the mouse location into canvas point
				local TransformedPoint = (MousePoint / GradientCanvasFrameSize) -- Normalised
				
				TransformedPoint *= self.Resolution -- Canvas space
				TransformedPoint += Vector2.new(0.5, 0.5) --Vector2New(1 / self.CurrentResX, 1 / self.CurrentResY) * self.Resolution * 0.5

				-- Make sure everything is aligned when the canvas is at different aspect ratios
				local RatioDifference = Vector2New(CanvasFrameSize.X / GradientCanvasFrameSize.X, CanvasFrameSize.Y / GradientCanvasFrameSize.Y) - Vector2New(1, 1)
				TransformedPoint -= (RatioDifference / 2) * self.Resolution

				TransformedPoint = RoundPoint(TransformedPoint)

				-- If the point is within the canvas, return it.
				if TransformedPoint.X > 0 and TransformedPoint.Y > 0 and TransformedPoint.X <= self.CurrentResX and TransformedPoint.Y <= self.CurrentResY then
					return TransformedPoint
				end
			else
				-- SurfaceGui
				local Part = SurfaceGui.Adornee or SurfaceGui:FindFirstAncestorWhichIsA("BasePart") 
				local Camera = workspace.CurrentCamera
				
				local GradientCanvasFrame = Frame:FindFirstChild("GradientCanvas")
				
				if Part and GradientCanvasFrame then
					local Params = RaycastParams.new()
					Params.FilterType = Enum.RaycastFilterType.Whitelist
					Params.FilterDescendantsInstances = {Part}

					local UnitRay = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)

					local Result = workspace:Raycast(UnitRay.Origin, UnitRay.Direction * 1000, Params)

					if Result then
						local Normal = Result.Normal
						local IntersectionPos = Result.Position

						if VectorFuncs.normalVectorToFace(Part, Normal) ~= SurfaceGui.Face then
							return
						end
						
						-- Credits to @Krystaltinan for some of this code
						local hitCF = CFrame.lookAt(IntersectionPos, IntersectionPos + Normal)

						local topLeftCorners = VectorFuncs.getTopLeftCorners(Part)
						local topLeftCFrame = topLeftCorners[SurfaceGui.Face]

						local hitOffset = topLeftCFrame:ToObjectSpace(hitCF)

						local ScreenPos = Vector2.new(
							math.abs(hitOffset.X), 
							math.abs(hitOffset.Y)
						)

						-- Ensure the calculations work for all faces
						if SurfaceGui.Face == Enum.NormalId.Front or SurfaceGui.Face == Enum.NormalId.Back then
							ScreenPos -= Vector2.new(Part.Size.X / 2, Part.Size.Y / 2)
							ScreenPos /= Vector2.new(Part.Size.X, Part.Size.Y)
						else
							return -- Other faces don't seem to work for now
						end
						
						local PositionalOffset
						local AspectRatioDifference = GradientCanvasFrameSize / CanvasFrameSize
						local SurfaceGuiSizeDifference = SurfaceGui.AbsoluteSize / CanvasFrameSize
						
						--print(SurfaceGuiSizeDifference)
						
						local PosFixed = ScreenPos + Vector2.new(0.5, 0.5) -- Move origin to top left
						
						ScreenPos = PosFixed * SurfaceGui.AbsoluteSize -- Convert to SurfaceGui space
						
						ScreenPos -= CanvasPosition
						
						local TransformedPoint = (ScreenPos / GradientCanvasFrameSize) -- Normalised

						TransformedPoint *= self.Resolution -- Canvas space
						TransformedPoint += Vector2.new(0.5, 0.5)

						-- Make sure everything is aligned when the canvas is at different aspect ratios
						local RatioDifference = Vector2New(CanvasFrameSize.X / GradientCanvasFrameSize.X, CanvasFrameSize.Y / GradientCanvasFrameSize.Y) - Vector2New(1, 1)
						TransformedPoint -= (RatioDifference / 2) * self.Resolution

						TransformedPoint = RoundPoint(TransformedPoint)

						-- If the point is within the canvas, return it.
						if TransformedPoint.X > 0 and TransformedPoint.Y > 0 and TransformedPoint.X <= self.CurrentResX and TransformedPoint.Y <= self.CurrentResY then
							return TransformedPoint
						end
						
						return TransformedPoint
					end
				end	
			end
		else
			OutputWarn("Failed to get point from mouse (you cannot use this function on the server. Please call this function from a LocalScript).")
		end
	end


	--==<< Canvas Image Data Functions >>==--
	
	function Canvas:CreateImageDataFromCanvas(PointA: Vector2, PointB: Vector2): {}
		-- Set the default points to be the whole canvas corners
		if not PointA and not PointB then
			PointA = Vector2New(1, 1)
			PointB = self.Resolution
		end

		local ImageResolutionX = GetRange(PointA.X, PointB.X) + 1
		local ImageResolutionY = GetRange(PointA.Y, PointB.Y) + 1

		local ColoursData = self:GetPixels(PointA, PointB)
		local AlphasData = {}

		-- Canvas has no transparency. So all alpha values will be 255
		for i = 1, #ColoursData do
			TableInsert(AlphasData, 255)
		end

		return {ImageColours = ColoursData, ImageAlphas = AlphasData, ImageResolution = Vector2New(ImageResolutionX, ImageResolutionY)}
	end

	function Canvas:DrawImage(ImageData: Table, Point: Vector2, Scale: Vector2, TransparencyEnabled: boolean?): {}
		local ReturnPixelsPoints = {}

		if not Point then
			Point = Vector2New(1, 1)
		end
		
		if not Scale then
			Scale = Vector2New(1, 1)
		end

		local X = Point.X
		local Y = Point.Y
		
		local ScaleX = Scale.X
		local ScaleY = Scale.Y

		local ImageResolutionX = ImageData.ImageResolution.X
		local ImageResolutionY = ImageData.ImageResolution.Y
		local ImageColours = ImageData.ImageColours
		local ImageAlphas = ImageData.ImageAlphas

		if not TransparencyEnabled then
			-- Draw normal image with no transparency (most optimal)
			for ImgX = 1, ImageResolutionX * ScaleX do
				local SampleX = CeilN(ImgX / ScaleX)
				local PlacementX = X + ImgX - 1

				for ImgY = 1, ImageResolutionY * ScaleY do
					local SampleY = CeilN(ImgY / ScaleY)
					local PlacementY = Y + ImgY - 1

					local ImgPixelColour = ImageColours[SampleX + ((SampleY - 1) * ImageResolutionX)]
					local PlacementPoint = Vector2New(PlacementX, PlacementY)
					
					self:DrawPixel(PlacementPoint, ImgPixelColour)
					
					TableInsert(ReturnPixelsPoints, PlacementPoint)
				end
			end
		else
			-- Draw image with transaprency (more expensive)
			for ImgX = 1, ImageResolutionX * ScaleX do
				local SampleX = CeilN(ImgX / ScaleX)
				local PlacementX = X + ImgX - 1

				for ImgY = 1, ImageResolutionY * ScaleY do
					local SampleY = CeilN(ImgY / ScaleY)
					local PlacementY = Y + ImgY - 1
					
					local PlacementPoint = Vector2New(PlacementX, PlacementY)

					local ImgPixelIndex = SampleX + ((SampleY - 1) * ImageResolutionX)

					local BgColour = self:GetPixel(PlacementPoint)
					
					if BgColour then
						local ImgPixelColour = ImageColours[ImgPixelIndex]
						local ImgPixelAlpha = ImageAlphas[ImgPixelIndex]

						self:DrawPixel(PlacementPoint, BgColour:Lerp(ImgPixelColour, ImgPixelAlpha / 255))

						TableInsert(ReturnPixelsPoints, PlacementPoint)
					end
				end
			end
		end
		
		return ReturnPixelsPoints
	end

	function Canvas:DrawImageXY(ImageData: Table, X: number?, Y: number?, ScaleX: number?, ScaleY: number?, TransparencyEnabled: boolean?)
		if not X then
			X = 1
		end

		if not Y then
			Y = 1
		end

		if not ScaleX then
			ScaleX = 1
		end

		if not ScaleY then
			ScaleY = 1
		end

		local ImageResolutionX = ImageData.ImageResolution.X
		local ImageResolutionY = ImageData.ImageResolution.Y
		local ImageColours = ImageData.ImageColours
		local ImageAlphas = ImageData.ImageAlphas

		if not TransparencyEnabled then
			if ScaleX == 1 and ScaleY == 1 then
				-- Draw normal image with no transparency and no scale adjustments (most optimal)
				for ImgX = 1, ImageResolutionX do
					local PlacementX = X + ImgX - 1

					for ImgY = 1, ImageResolutionY do
						local PlacementY = Y + ImgY - 1

						local ImgPixelColour = ImageColours[ImgX + ((ImgY - 1) * ImageResolutionX)]
						InternalCanvas:SetPixel(PlacementX, PlacementY, ImgPixelColour)
					end
				end
			else
				-- Draw normal image with no transparency with scale adjustments (pretty optimal)
				for ImgX = 1, ImageResolutionX * ScaleX do
					local SampleX = CeilN(ImgX / ScaleX)
					local PlacementX = X + ImgX - 1

					for ImgY = 1, ImageResolutionY * ScaleY do
						local SampleY = CeilN(ImgY / ScaleY)
						local PlacementY = Y + ImgY - 1

						local ImgPixelColour = ImageColours[SampleX + ((SampleY - 1) * ImageResolutionX)]
						InternalCanvas:SetPixel(PlacementX, PlacementY, ImgPixelColour)
					end
				end
			end	
		else
			-- Draw image with transaprency (more expensive)
			for ImgX = 1, ImageResolutionX * ScaleX do
				local SampleX = CeilN(ImgX / ScaleX)
				local PlacementX = X + ImgX - 1

				for ImgY = 1, ImageResolutionY * ScaleY do
					local SampleY = CeilN(ImgY / ScaleY)
					local PlacementY = Y + ImgY - 1

					local ImgPixelIndex = SampleX + ((SampleY - 1) * ImageResolutionX)
					local ImgPixelAlpha = ImageAlphas[ImgPixelIndex]
					
					if ImgPixelAlpha < 255 then -- No need to do any calculations for completely transparent pixels
						continue
					end
					
					local BgColour = InternalCanvas:GetPixel(PlacementX, PlacementY)

					local ImgPixelColour = ImageColours[ImgPixelIndex]
					
					InternalCanvas:SetPixel(PlacementX, PlacementY, BgColour:Lerp(ImgPixelColour, ImgPixelAlpha / 255))
				end
			end
		end
	end


	---==<< Draw Functions >>==--

	function Canvas:ClearPixels(PixelPoints: table)
		self:FillPixels(PixelPoints, self.CanvasColour)
	end

	function Canvas:FillPixels(Points: table, Colour: Color3)
		for i, Point in pairs(Points) do
			self:DrawPixel(Point, Colour)
		end
	end

	function Canvas:FloodFill(Point: Vector2, Colour: Color3): {}
		Point = RoundPoint(Point)

		local OriginColour = self:GetPixel(Point)

		local ReturnPointsArray = {}

		local function CheckNeighbours(OriginPoint)
			local function CheckPixel(PointToCheck) 
				local PointToCheckX = PointToCheck.X
				local PointToCheckY = PointToCheck.Y

				-- Check if this point is within the canvas
				if PointToCheckX > 0 and PointToCheckY > 0 and PointToCheckX <= self.CurrentResX and PointToCheckY <= self.CurrentResY then
					-- Check if there is a pixel and it can be coloured
					if not TableFind(ReturnPointsArray, PointToCheck) then
						local PixelColourToCheck = InternalCanvas:GetPixel(PointToCheck)
						if PixelColourToCheck == OriginColour then
							TableInsert(ReturnPointsArray, PointToCheck)

							-- Colour the pixel
							InternalCanvas:SetPixel(PointToCheckX, PointToCheckY, Colour)

							CheckNeighbours(PointToCheck)
						end
					end
				end
			end

			-- Check all four directions of the pixel
			local PointUp = OriginPoint + Vector2New(0, -1)
			CheckPixel(PointUp)

			local PointDown = OriginPoint + Vector2New(0, 1)
			CheckPixel(PointDown)

			local PointLeft = OriginPoint + Vector2New(-1, 0)
			CheckPixel(PointLeft)

			local PointRight = OriginPoint + Vector2New(1, 0)
			CheckPixel(PointRight)
		end

		CheckNeighbours(Point)

		return ReturnPointsArray
	end

	function Canvas:DrawPixel(Point: Vector2, Colour: Color3): Vector2
		local X = RoundN(Point.X)
		local Y = RoundN(Point.Y)

		if X > 0 and Y > 0 and X <= self.CurrentResX and Y <= self.CurrentResY then	
			InternalCanvas:SetPixel(X, Y, Colour)
			return Point	
		end
	end

	function Canvas:SetPixel(X: number, Y: number, Colour: Color3) -- A raw and performant method to draw pixels (much faster than `DrawPixel()`)
		InternalCanvas:SetPixel(X, Y, Colour)
	end

	function Canvas:DrawCircle(Point: Vector2, Radius: number, Colour: Color3, Fill: boolean): {}
		local X = RoundN(Point.X)
		local Y = RoundN(Point.Y)

		local PointsArray = {}

		-- Draw the circle
		local dx, dy, err = Radius, 0, 1 - Radius

		local function CreatePixelForCircle(DrawPoint)
			self:DrawPixel(DrawPoint, Colour)
			TableInsert(PointsArray, DrawPoint)
		end

		local function CreateLineForCircle(PointB, PointA)
			local Line = self:DrawRectangle(PointA, PointB, Colour, true)

			for i, Point in pairs(Line) do
				TableInsert(PointsArray, Point)
			end
		end

		if Fill or type(Fill) == "nil" then
			while dx >= dy do -- Filled circle
				CreateLineForCircle(Vector2New(X + dx, Y + dy), Vector2New(X - dx, Y + dy))
				CreateLineForCircle(Vector2New(X + dx, Y - dy), Vector2New(X - dx, Y - dy))
				CreateLineForCircle(Vector2New(X + dy, Y + dx), Vector2New(X - dy, Y + dx))
				CreateLineForCircle(Vector2New(X + dy, Y - dx), Vector2New(X - dy, Y - dx))

				dy = dy + 1
				if err < 0 then
					err = err + 2 * dy + 1
				else
					dx, err = dx - 1, err + 2 * (dy - dx) + 1
				end
			end
		else
			while dx >= dy do -- Circle outline
				CreatePixelForCircle(Vector2New(X + dx, Y + dy))
				CreatePixelForCircle(Vector2New(X - dx, Y + dy))
				CreatePixelForCircle(Vector2New(X + dx, Y - dy))
				CreatePixelForCircle(Vector2New(X - dx, Y - dy))
				CreatePixelForCircle(Vector2New(X + dy, Y + dx))
				CreatePixelForCircle(Vector2New(X - dy, Y + dx))
				CreatePixelForCircle(Vector2New(X + dy, Y - dx))
				CreatePixelForCircle(Vector2New(X - dy, Y - dx))

				dy = dy + 1
				if err < 0 then
					err = err + 2 * dy + 1
				else
					dx, err = dx - 1, err + 2 * (dy - dx) + 1
				end
			end
		end

		return PointsArray
	end

	function Canvas:DrawCircleXY(X: number, Y: number, Radius: number, Colour: Color3, Fill: boolean)
		if X + Radius > self.CurrentResX or Y + Radius > self.CurrentResY or X - Radius < 1 or Y - Radius < 1 then
			OutputWarn("Circle (xy) is exceeding bounds! Drawing cancelled.")
			return
		end

		-- Draw the circle
		local dx, dy, err = Radius, 0, 1 - Radius

		local function CreatePixelForCircle(DrawX, DrawY)
			InternalCanvas:SetPixel(DrawX, DrawY, Colour)
		end

		local function CreateLineForCircle(EndX, StartX, Y)
			for DrawX = 0, EndX - StartX do
				InternalCanvas:SetPixel(StartX + DrawX, Y, Colour)
			end
		end

		if Fill or type(Fill) == "nil" then
			while dx >= dy do -- Filled circle
				CreateLineForCircle(X + dx, X - dx, Y + dy)
				CreateLineForCircle(X + dx, X - dx, Y - dy)
				CreateLineForCircle(X + dy, X - dy, Y + dx)
				CreateLineForCircle(X + dy, X - dy, Y - dx)

				dy = dy + 1
				if err < 0 then
					err = err + 2 * dy + 1
				else
					dx, err = dx - 1, err + 2 * (dy - dx) + 1
				end
			end
		else
			while dx >= dy do -- Circle outline
				CreatePixelForCircle(X + dx, Y + dy)
				CreatePixelForCircle(X - dx, Y + dy)
				CreatePixelForCircle(X + dx, Y - dy)
				CreatePixelForCircle(X - dx, Y - dy)
				CreatePixelForCircle(X + dy, Y + dx)
				CreatePixelForCircle(X - dy, Y + dx)
				CreatePixelForCircle(X + dy, Y - dx)
				CreatePixelForCircle(X - dy, Y - dx)

				dy = dy + 1
				if err < 0 then
					err = err + 2 * dy + 1
				else
					dx, err = dx - 1, err + 2 * (dy - dx) + 1
				end
			end
		end
	end

	function Canvas:DrawRectangle(PointA: Vector2, PointB: Vector2, Colour: Color3, Fill: boolean): {}
		local ReturnPoints = {}

		local X1 = RoundN(PointA.X)
		local Y1 = RoundN(PointA.Y)
		local X2 = RoundN(PointB.X)
		local Y2 = RoundN(PointB.Y)

		local RangeX = math.abs(X2 - X1)
		local RangeY = math.abs(Y2 - Y1)

		if Fill or type(Fill) == "nil" then
			-- Fill every pixel
			for PlotX = 0, RangeX do
				for PlotY = 0, RangeY do
					local DrawPoint = Vector2New(X1 + PlotX, Y1 + PlotY)
					self:DrawPixel(DrawPoint, Colour)
					TableInsert(ReturnPoints, DrawPoint)
				end
			end
		else
			-- Just draw the outlines
			for PlotX = 0, RangeX do -- Top and bottom
				local DrawPointUp = Vector2New(X1 + PlotX, Y1)
				local DrawPointDown = Vector2New(X1 + PlotX, Y2)

				self:DrawPixel(DrawPointUp, Colour)
				self:DrawPixel(DrawPointDown, Colour)


				TableInsert(ReturnPoints, DrawPointUp)
				TableInsert(ReturnPoints, DrawPointDown)
			end

			for PlotY = 0, RangeY do -- Left and right
				local DrawPointLeft = Vector2New(X1, Y1 + PlotY)
				local DrawPointRight = Vector2New(X2, Y1 + PlotY)

				self:DrawPixel(DrawPointLeft, Colour)
				self:DrawPixel(DrawPointRight, Colour)

				TableInsert(ReturnPoints, DrawPointLeft)
				TableInsert(ReturnPoints, DrawPointRight)
			end
		end

		return ReturnPoints
	end

	function Canvas:DrawRectangleXY(X1: number, Y1: number, X2: number, Y2: number, Colour: Color3, Fill: boolean)
		local RangeX = math.abs(X2 - X1)
		local RangeY = math.abs(Y2 - Y1)

		if Fill or type(Fill) == "nil" then
			-- Fill every pixel
			for PlotX = 0, RangeX do
				for PlotY = 0, RangeY do
					InternalCanvas:SetPixel(X1 + PlotX, Y1 + PlotY, Colour)
				end
			end
		else
			-- Just draw the outlines
			for PlotX = 0, RangeX do -- Top and bottom
				InternalCanvas:SetPixel(X1 + PlotX, Y1, Colour)
				InternalCanvas:SetPixel(X1 + PlotX, Y2, Colour)
			end

			for PlotY = 0, RangeY do -- Left and right
				InternalCanvas:SetPixel(X1, Y1 + PlotY, Colour)
				InternalCanvas:SetPixel(X2, Y1 + PlotY, Colour)
			end
		end
	end

	function Canvas:DrawTriangle(PointA: Vector2, PointB: Vector2, PointC: Vector2, Colour: Color3, Fill: boolean): {}
		local ReturnPoints = {}

		if typeof(Fill) == "nil" or Fill == true then
			local X1 = PointA.X
			local X2 = PointB.X
			local X3 = PointC.X
			local Y1 = PointA.Y
			local Y2 = PointB.Y
			local Y3 = PointC.Y

			local CurrentY1 = Y1
			local CurrentY2 = Y2
			local CurrentY3 = Y3

			local CurrentX1 = X1
			local CurrentX2 = X2
			local CurrentX3 = X3

			-- Sort the vertices based on Y ascending
			if Y3 < Y2 then
				Y3 = CurrentY2
				Y2 = CurrentY3
				X3 = CurrentX2
				X2 = CurrentX3

				CurrentY3 = Y3
				CurrentY2 = Y2
				CurrentX3 = X3
				CurrentX2 = X2
			end	
			if Y3 < Y1 then
				Y3 = CurrentY1
				Y1 = CurrentY3
				X3 = CurrentX1
				X1 = CurrentX3

				CurrentY1 = Y1
				CurrentY3 = Y3
				CurrentX1 = X1
				CurrentX3 = X3
			end	
			if Y2 < Y1 then
				Y2 = CurrentY1
				Y1 = CurrentY2
				X2 = CurrentX1
				X1 = CurrentX2
			end

			local function PlotLine(StartX, EndX, Y, TriY)
				local Range = EndX - StartX

				for X = 1, Range do
					local Point = Vector2New(StartX + X, TriY + Y)
					self:DrawPixel(Point, Colour)

					TableInsert(ReturnPoints, Point)
				end
			end

			local function DrawBottomFlatTriangle(TriX1, TriY1, TriX2, TriY2, TriX3, TriY3) 
			--[[
				TriX1, TriY1 - Triangle top point
				TriX2, TriY2 - Triangle bottom left corner
				TriX3, TriY3 - Triangle bottom right corner
			]]
				local invslope1 = (TriX2 - TriX1) / (TriY2 - TriY1)
				local invslope2 = (TriX3 - TriX1) / (TriY3 - TriY1)

				local curx1 = TriX1
				local curx2 = TriX1

				for Y = 0, TriY3 - TriY1 do
					PlotLine(math.floor(curx1), math.floor(curx2), Y, TriY1)
					curx1 += invslope1
					curx2 += invslope2
				end
			end

			local function DrawTopFlatTriangle(TriX1, TriY1, TriX2, TriY2, TriX3, TriY3)	
			--[[
				TriX1, TriY1 - Triangle top left corner
				TriX2, TriY2 - Triangle top right corner
				TriX3, TriY3 - Triangle bottom point
			]]
				local invslope1 = (TriX3 - TriX1) / (TriY3 - TriY1)
				local invslope2 = (TriX3 - TriX2) / (TriY3 - TriY2)

				local curx1 = TriX3
				local curx2 = TriX3

				for Y = 0, TriY3 - TriY1 do
					PlotLine(math.floor(curx1), math.floor(curx2), -Y, TriY3)
					curx1 -= invslope1
					curx2 -= invslope2
				end
			end

			local TriMidX = X1 + (Y2 - Y1) / (Y3 - Y1) * (X3 - X1)

			if TriMidX < X2 then
				DrawBottomFlatTriangle(X1, Y1, TriMidX, Y2, X2, Y2)
				DrawTopFlatTriangle(TriMidX, Y2, X2, Y2, X3, Y3)
			else
				DrawBottomFlatTriangle(X1, Y1, X2, Y2, TriMidX, Y2)
				DrawTopFlatTriangle(X2, Y2, TriMidX, Y2, X3, Y3)
			end
		end

		local LineA = self:DrawLine(PointA, PointB, Colour)
		local LineB = self:DrawLine(PointB, PointC, Colour)
		local LineC = self:DrawLine(PointC, PointA, Colour)

		for Point in pairs(LineA) do
			TableInsert(ReturnPoints, Point)
		end
		for Point in pairs(LineB) do
			TableInsert(ReturnPoints, Point)
		end
		for Point in pairs(LineC) do
			TableInsert(ReturnPoints, Point)
		end

		return ReturnPoints
	end


	function Canvas:DrawTriangleXY(X1: number, Y1: number, X2: number, Y2: number, X3: number, Y3: number, Colour: Color, Fill: boolean)
		if Fill or typeof(Fill) == "nil" then
			local CurrentY1 = Y1
			local CurrentY2 = Y2
			local CurrentY3 = Y3

			local CurrentX1 = X1
			local CurrentX2 = X2
			local CurrentX3 = X3

			-- Sort the vertices based on Y ascending
			if Y3 < Y2 then
				Y3 = CurrentY2
				Y2 = CurrentY3
				X3 = CurrentX2
				X2 = CurrentX3

				CurrentY3 = Y3
				CurrentY2 = Y2
				CurrentX3 = X3
				CurrentX2 = X2
			end	
			if Y3 < Y1 then
				Y3 = CurrentY1
				Y1 = CurrentY3
				X3 = CurrentX1
				X1 = CurrentX3

				CurrentY1 = Y1
				CurrentY3 = Y3
				CurrentX1 = X1
				CurrentX3 = X3
			end	
			if Y2 < Y1 then
				Y2 = CurrentY1
				Y1 = CurrentY2
				X2 = CurrentX1
				X1 = CurrentX2
			end

			local function PlotLine(StartX, EndX, Y, TriY)
				local Range = EndX - StartX

				for X = 1, Range do
					InternalCanvas:SetPixel(StartX + X, TriY + Y, Colour)
				end
			end

			local function DrawBottomFlatTriangle(TriX1, TriY1, TriX2, TriY2, TriX3, TriY3) 
			--[[
				TriX1, TriY1 - Triangle top point
				TriX2, TriY2 - Triangle bottom left corner
				TriX3, TriY3 - Triangle bottom right corner
			]]
				local invslope1 = (TriX2 - TriX1) / (TriY2 - TriY1)
				local invslope2 = (TriX3 - TriX1) / (TriY3 - TriY1)

				local curx1 = TriX1
				local curx2 = TriX1

				for Y = 0, TriY3 - TriY1 do
					PlotLine(math.floor(curx1), math.floor(curx2), Y, TriY1)
					curx1 += invslope1
					curx2 += invslope2
				end
			end

			local function DrawTopFlatTriangle(TriX1, TriY1, TriX2, TriY2, TriX3, TriY3)	
			--[[
				TriX1, TriY1 - Triangle top left corner
				TriX2, TriY2 - Triangle top right corner
				TriX3, TriY3 - Triangle bottom point
			]]
				local invslope1 = (TriX3 - TriX1) / (TriY3 - TriY1)
				local invslope2 = (TriX3 - TriX2) / (TriY3 - TriY2)

				local curx1 = TriX3
				local curx2 = TriX3

				for Y = 0, TriY3 - TriY1 do
					PlotLine(math.floor(curx1), math.floor(curx2), -Y, TriY3)
					curx1 -= invslope1
					curx2 -= invslope2
				end
			end

			local TriMidX = X1 + (Y2 - Y1) / (Y3 - Y1) * (X3 - X1)

			if TriMidX < X2 then
				DrawBottomFlatTriangle(X1, Y1, TriMidX, Y2, X2, Y2)
				DrawTopFlatTriangle(TriMidX, Y2, X2, Y2, X3, Y3)
			else
				DrawBottomFlatTriangle(X1, Y1, X2, Y2, TriMidX, Y2)
				DrawTopFlatTriangle(X2, Y2, TriMidX, Y2, X3, Y3)
			end
		end

		self:DrawLineXY(X1, Y1, X2, Y2, Colour)
		self:DrawLineXY(X2, Y2, X3, Y3, Colour)
		self:DrawLineXY(X3, Y3, X1, Y1, Colour)
	end


	function Canvas:DrawLine(PointA: Vector2, PointB: Vector2, Colour: Color3): {}
		local DrawnPointsArray = {PointA}

		local X1 = RoundN(PointA.X)
		local X2 = RoundN(PointB.X)
		local Y1 = RoundN(PointA.Y)
		local Y2 = RoundN(PointB.Y)

		local sx, sy, dx, dy

		if X1 < X2 then
			sx = 1
			dx = X2 - X1
		else
			sx = -1
			dx = X1 - X2
		end

		if Y1 < Y2 then
			sy = 1
			dy = Y2 - Y1
		else
			sy = -1
			dy = Y1 - Y2
		end

		local err, e2 = dx-dy, nil

		while not (X1 == X2 and Y1 == Y2) do
			e2 = err + err
			if e2 > -dy then
				err = err - dy
				X1  = X1 + sx
			end
			if e2 < dx then
				err = err + dx
				Y1 = Y1 + sy
			end

			local Point = Vector2New(X1, Y1)
			self:DrawPixel(Point, Colour)
			TableInsert(DrawnPointsArray, Point)
		end

		return DrawnPointsArray
	end

	function Canvas:DrawLineXY(X1: number, Y1: number, X2: number, Y2: number, Colour: Color3)
		local sx, sy, dx, dy

		if X1 < X2 then
			sx = 1
			dx = X2 - X1
		else
			sx = -1
			dx = X1 - X2
		end

		if Y1 < Y2 then
			sy = 1
			dy = Y2 - Y1
		else
			sy = -1
			dy = Y1 - Y2
		end

		local err, e2 = dx-dy, nil

		while not(X1 == X2 and Y1 == Y2) do
			e2 = err + err
			if e2 > -dy then
				err = err - dy
				X1  = X1 + sx
			end
			if e2 < dx then
				err = err + dx
				Y1 = Y1 + sy
			end
			InternalCanvas:SetPixel(X1, Y1, Colour)
		end
	end

	function Canvas:DrawText(Text: string, Point: Vector2, Colour: Color3, Scale: number?, Wrap: boolean?, Spacing: number?)
		local X = math.round(Point.X)
		local Y = math.round(Point.Y)

		if not Spacing then
			Spacing = 1
		end

		if not Scale then
			Scale = 1
		end

		Scale = math.clamp(math.round(Scale), 1, 50)

		local CharWidth = 3 * Scale
		local CharHeight = 5 * Scale

		local TextLines = string.split(Text, "\n ")

		for i, TextLine in pairs(TextLines) do
			local Characters = string.split(TextLine, "")

			local OffsetX = 0
			local OffsetY = (i - 1) * (CharHeight + Spacing)

			for i, Character in pairs(Characters) do
				local TextCharacter = PixelTextCharacters[Character:lower()]

				if TextCharacter then
					if OffsetX + CharWidth * Scale >= self.CurrentResX then
						if Wrap or type(Wrap) == "nil" then
							OffsetY += CharHeight + Spacing
							OffsetX = 0
						else
							break -- Don't write anymore text since it's outside the canvas
						end
					end

					for SampleY = 1, CharHeight do
						local PlacementY = Y + SampleY - 1 + OffsetY
						SampleY = math.ceil(SampleY / Scale)

						if PlacementY - 1 >= self.CurrentResY then
							break
						end

						for SampleX = 1, CharWidth do
							local PlacementX = X + SampleX - 1 + OffsetX
							SampleX = math.ceil(SampleX / Scale)

							local Fill = TextCharacter[SampleY][SampleX]
							if Fill == 1 then
								InternalCanvas:SetPixel(PlacementX, PlacementY, Colour)
							end
						end
					end
				end

				OffsetX += CharWidth + Spacing
			end
		end
	end

	function Canvas:DrawTextXY(Text: string, X: number, Y: number, Colour: Color3, Scale: number?, Wrap: boolean?, Spacing: number?)
		if not Spacing then
			Spacing = 1
		end

		if not Scale then
			Scale = 1
		end

		Scale = math.clamp(math.round(Scale), 1, 50)

		local CharWidth = 3 * Scale
		local CharHeight = 5 * Scale

		local TextLines = string.split(Text, "\n ")

		for i, TextLine in pairs(TextLines) do
			local Characters = string.split(TextLine, "")

			local OffsetX = 0
			local OffsetY = (i - 1) * (CharHeight + Spacing)

			for i, Character in pairs(Characters) do
				local TextCharacter = PixelTextCharacters[Character:lower()]

				if TextCharacter then
					if OffsetX + CharWidth * Scale >= self.CurrentResX then
						if Wrap or type(Wrap) == "nil" then
							OffsetY += CharHeight + Spacing
							OffsetX = 0
						else
							break -- Don't write anymore text since it's outside the canvas
						end
					end

					for SampleY = 1, CharHeight do
						local PlacementY = Y + SampleY - 1 + OffsetY
						SampleY = math.ceil(SampleY / Scale)

						if PlacementY - 1 >= self.CurrentResY then
							break
						end

						for SampleX = 1, CharWidth do
							local PlacementX = X + SampleX - 1 + OffsetX
							SampleX = math.ceil(SampleX / Scale)

							local Fill = TextCharacter[SampleY][SampleX]
							if Fill == 1 then
								InternalCanvas:SetPixel(PlacementX, PlacementY, Colour)
							end
						end
					end
				end

				OffsetX += CharWidth + Spacing
			end
		end
	end

	return Canvas
end


--============================================================================================================--
--====  <<   CanvasDraw Module ImageData API   >>   ===========================================================--
--============================================================================================================--

function CanvasDrawModule.GetImageDataFromSaveObject(SaveObject: Folder): {}
	local SaveDataImageColours = SaveObject:GetAttribute("ImageColours")
	local SaveDataImageAlphas = SaveObject:GetAttribute("ImageAlphas")
	local SaveDataImageResolution = SaveObject:GetAttribute("ImageResolution")

	-- Decompress the data
	local DecompressedSaveDataImageColours = StringCompressor.Decompress(SaveDataImageColours)
	local DecompressedSaveDataImageAlphas = StringCompressor.Decompress(SaveDataImageAlphas)


	-- Get a single pixel colour info form the data
	local PixelDataColoursString = string.split(DecompressedSaveDataImageColours, "S")
	local PixelDataAlphasString = string.split(DecompressedSaveDataImageAlphas, "S")

	local PixelColours = {}
	local PixelAlphas = {}

	for i, PixelColourString in pairs(PixelDataColoursString) do
		local RGBValues = string.split(PixelColourString, ",")
		local PixelColour = Color3.fromRGB(table.unpack(RGBValues))

		local PixelAlpha = tonumber(PixelDataAlphasString[i])

		TableInsert(PixelColours, PixelColour)
		TableInsert(PixelAlphas, PixelAlpha)
	end

	-- Convert the SaveObject into image data
	local ImageData = {ImageColours = PixelColours, ImageAlphas = PixelAlphas, ImageResolution = SaveDataImageResolution}

	return ImageData
end

function CanvasDrawModule.CreateSaveObject(ImageData: Table, InstantCreate: boolean?): Folder
	if ImageData.ImageResolution.X > SaveObjectResolutionLimit.X and ImageData.ImageResolution.Y > SaveObjectResolutionLimit.Y then
		warn("Failed to create an image save object (ImageData too large). Please try to keep the resolution of the image no higher than '" .. SaveObjectResolutionLimit.X .. " x " .. SaveObjectResolutionLimit.Y .. "'.")
		return
	end
	
	local FastWaitCount = 0

	local function FastWait(Count) -- Avoid lag spikes
		if FastWaitCount >= Count then
			FastWaitCount = 0
			RunService.Heartbeat:Wait()
		else
			FastWaitCount += 1
		end
	end

	local function ConvertColoursToListString(Colours)
		local ColourData = {}
		local RgbStringFormat = "%d,%d,%d"

		for i, Colour in ipairs(Colours) do
			local R, G, B = RoundN(Colour.R * 255), RoundN(Colour.G * 255), RoundN(Colour.B * 255)
			TableInsert(ColourData, RgbStringFormat:format(R, G, B))
			
			if not InstantCreate then
				FastWait(4000)
			end
		end

		return table.concat(ColourData, "S")
	end

	local function ConvertAlphasToListString(Alphas)	
		local AlphasListString = table.concat(Alphas, "S")
		return AlphasListString
	end

	local ImageColoursString = ConvertColoursToListString(ImageData.ImageColours)
	local ImageAlphasString = ConvertAlphasToListString(ImageData.ImageAlphas)

	local CompressedImageColoursString = StringCompressor.Compress(ImageColoursString)
	local CompressedImageAlphasString = StringCompressor.Compress(ImageAlphasString)

	local NewSaveObject = Instance.new("Folder")
	NewSaveObject.Name = "NewSave"

	NewSaveObject:SetAttribute("ImageColours", CompressedImageColoursString)
	NewSaveObject:SetAttribute("ImageAlphas", CompressedImageAlphasString)
	NewSaveObject:SetAttribute("ImageResolution", ImageData.ImageResolution)

	return NewSaveObject
end

function CanvasDrawModule.GetPixelFromImage(ImageData: Table, Point: Vector2): (Color3, number)
	local PixelIndex = PointToPixelIndex(Point, ImageData.ImageResolution) -- Convert the point into an index for the array of colours

	local PixelColour = ImageData.ImageColours[PixelIndex]
	local PixelAlpha = ImageData.ImageAlphas[PixelIndex]

	return PixelColour, PixelAlpha
end

function CanvasDrawModule.GetPixelFromImageXY(ImageData: Table, X: number, Y: number): (Color3, number)
	local PixelIndex = XYToPixelIndex(X, Y, ImageData.ImageResolution.X) -- Convert the coordinates into an index for the array of colours

	local PixelColour = ImageData.ImageColours[PixelIndex]
	local PixelAlpha = ImageData.ImageAlphas[PixelIndex]

	return PixelColour, PixelAlpha
end

return CanvasDrawModule
