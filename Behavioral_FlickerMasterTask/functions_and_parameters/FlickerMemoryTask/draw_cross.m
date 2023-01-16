

function draw_cross(key,Window,xCenter,yCenter,cross_coords,duration)
    
    startTime=GetSecs;
    Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Draw the fixation cross in white, set it to the center of our screen and set good quality antialiasing
    Screen('DrawLines', Window, cross_coords,4, 0, [xCenter yCenter], 2);

    % Flip to the screen
    Screen('Flip', Window);
    
    while GetSecs-startTime<=duration
        [ ~, ~, keyCode ] = KbCheck;
        if (keyCode(key.pause))
            disp('Task paused (press R to resume)');
            resume=0;
            while ~resume
                [ ~, ~, keyCode ] = KbCheck;
                if keyCode(key.resume)
                    resume=1;
                    disp('Task resumed');
                    startTime=GetSecs;
                    draw_cross(key,Window,xCenter,yCenter,cross_coords,duration);
                end
            end
        elseif (keyCode(key.quit))
            quitTask(Window);
        end
    end
    
end