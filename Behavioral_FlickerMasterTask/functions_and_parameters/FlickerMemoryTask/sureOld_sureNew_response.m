

function [rt,response]=sureOld_sureNew_response(Window,filePath,xCenter,yCenter,screenXpixels,screenYpixels,key,image_duration,font_size,instructions)
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
    cueFrameRect = CenterRectOnPoint(biggerframerect,xCenter,yCenter-screenYpixels/15);
    Screen('DrawTexture', Window, imagetexture, framerect, cueFrameRect);
    Screen('Flip', Window);
    
    WaitSecs(image_duration);
    
    
    Screen('DrawTexture', Window, imagetexture, framerect, cueFrameRect);
    Screen('TextSize', Window, font_size);%use a big font size
    Screen('TextStyle', Window,0);%normal
    %Screen('DrawText',Window,instructions);
    DrawFormattedText(Window, instructions, 'center', screenYpixels*0.9,  [0, 0, 0]);
    Screen('Flip', Window);
    
    startrt=GetSecs;
    rt =0;
    [ ~, ~, keyCode ] = KbCheck;
    while (~keyCode(key.one) && ~keyCode(key.two) && ~keyCode(key.three) && ~keyCode(key.four))
        [ ~, ~, keyCode ] = KbCheck;
        if (keyCode(key.one) && rt==0)
            rt=GetSecs-startrt;
            response='old_sure';
        elseif (keyCode(key.two) && rt==0)
            rt=GetSecs-startrt;
            response='old_maybe';
        elseif (keyCode(key.three) && rt==0)
            rt=GetSecs-startrt;
            response='new_maybe';
        elseif (keyCode(key.four) && rt==0)
            rt=GetSecs-startrt;
            response='new_sure';
        elseif(keyCode(key.quit))
            quitTask(Window);
        end
        WaitSecs(0.001);%slow down the while loop a bit
    end
    
    %erase image and free up memeory used by image since we've already copied it to buffer
    blankScreen(Window);
    Screen('Close', imagetexture);
    
end