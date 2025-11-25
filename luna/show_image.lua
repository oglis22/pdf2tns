-- Display image on TI-Nspire
-- Works with OS 3.6+ using resource system

platform.apiLevel = "2.5"

function on.paint(gc)
    -- Try to load image from resources
    if _R and _R.IMG and _R.IMG.img_01 then
        local img = image.new(_R.IMG.img_01)
        if img then
            gc:drawImage(img, 0, 0)
        else
            gc:drawString("Image load failed", 10, 10, "top")
        end
    else
        gc:drawString("Image resource not found", 10, 10, "top")
        gc:drawString("Resources available:", 10, 30, "top")
        if _R and _R.IMG then
            local y = 50
            for name, _ in pairs(_R.IMG) do
                gc:drawString(name, 20, y, "top")
                y = y + 20
            end
        end
    end
end

function on.resize(width, height)
    platform.window:invalidate()
end
