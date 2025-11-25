-- Simple image display for TI-Nspire
-- Automatically finds and displays the first image

platform.apiLevel = "2.5"

local myImage = nil

function on.construction()
    -- Try to load any available image
    if _R and _R.IMG then
        for imgName, imgResource in pairs(_R.IMG) do
            myImage = image.new(imgResource)
            if myImage then
                break
            end
        end
    end
end

function on.paint(gc)
    gc:setColorRGB(255, 255, 255)
    gc:fillRect(0, 0, platform.window:width(), platform.window:height())

    if myImage then
        -- Draw the image scaled to fit screen if needed
        local w = myImage:width()
        local h = myImage:height()
        local sw = platform.window:width()
        local sh = platform.window:height()

        -- Scale down if image is larger than screen
        local scale = math.min(sw/w, sh/h, 1)
        local nw = w * scale
        local nh = h * scale

        gc:drawImage(myImage, (sw-nw)/2, (sh-nh)/2, nw, nh)
    else
        gc:setColorRGB(0, 0, 0)
        gc:drawString("Kein Bild gefunden!", 10, 10, "top")

        -- Debug info
        if _R and _R.IMG then
            gc:drawString("Verfügbare Ressourcen:", 10, 30, "top")
            local y = 50
            for name, _ in pairs(_R.IMG) do
                gc:drawString("- " .. name, 20, y, "top")
                y = y + 20
            end
        else
            gc:drawString("Keine Bild-Ressourcen verfügbar", 10, 30, "top")
        end
    end
end

function on.resize()
    platform.window:invalidate()
end
