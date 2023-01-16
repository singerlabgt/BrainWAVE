

function [cross_coords,xCenter,yCenter]=initialize_fixation_cross(window,theRect)

    [screenXpixels, screenYpixels] = Screen('WindowSize', window);

    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Setup the text type for the window
    Screen('TextFont', window, 'Ariel');
    Screen('TextSize', window, 36);

    % Here we set the size of the arms of our fixation cross
    fixCrossDimPix = (min([screenXpixels, screenYpixels])/3)/2;

    % Now we set the coordinates (these are all relative to zero we will let
    % the drawing routine center the cross in the center of our monitor for us)
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    cross_coords = [xCoords; yCoords];
    
end