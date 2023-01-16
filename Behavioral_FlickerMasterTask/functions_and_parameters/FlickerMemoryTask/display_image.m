%NEED TO FIGURE OUT HOW TO RESCALE IMAGE APPROPRIATELY

function [startrt,imagetexture]=display_image(filePath,Window,xCenter,yCenter,screenXpixels,screenYpixels)
    im=imread(filePath);
    imagetexture=Screen('MakeTexture', Window, im);
    framerect = RectOfMatrix(im);
    
    [s1, s2, ~] = size(im);
    lengthScreen=min(screenXpixels,screenYpixels); %ONLY NEEDED IF SCREEN IS NOT A SQUARE
    if s2>=s1 %horizontal side longer
        scaleFactor=(0.8*lengthScreen)/s2;
    elseif s2<s1
        scaleFactor=(0.8*lengthScreen)/s1;
    end

    biggerframerect = round(ScaleRect(framerect, scaleFactor, scaleFactor));%make the image a bit bigger (150%)
    %where on screen to put frame?
    cueFrameRect = CenterRectOnPoint(biggerframerect,xCenter,yCenter);
    %cueFrameRect = CenterRectOnPoint(biggerframerect,monitor_width/2,monitor_height/2);
    Screen('DrawTexture', Window, imagetexture, framerect, cueFrameRect);
    [~, startrt]=Screen('Flip', Window);
end