
function PTParameters=initialize_psychToolbox()
    
    Screen('Preference','SkipSyncTests',1);
    KbName('UnifyKeyNames');
    AssertOpenGL;
    KbCheck;
	WaitSecs(0.1);%wait 0.1 secs
    GetSecs;
    sound(1); %initialize sound so that doesn't take too long first time we use it
    
    presentation_screen = max(Screen('Screens'));%should be: first screen (e.g., laptop = 0) and second screen (if external) = 1
    Screen('Preference', 'VisualDebuglevel', 3);%initial screen will be black rather than white
    [PTParameters.Window,PTParameters.theRect] = Screen(presentation_screen,'OpenWindow',[255 255 255]); %open white screen
    [PTParameters.xCenter, PTParameters.yCenter] = RectCenter(PTParameters.theRect);
    [PTParameters.screenXpixels, PTParameters.screenYpixels] = Screen('WindowSize', PTParameters.Window);
    
    PTParameters.cross_coords=initialize_fixation_cross(PTParameters.Window,PTParameters.theRect);
    PTParameters.key.quit=KbName('q');
    PTParameters.key.pause=KbName('p');
    PTParameters.key.resume=KbName('r');
    PTParameters.key.in=KbName('LeftArrow');
    PTParameters.key.out=KbName('RightArrow');
    
    %for the test phase:
    PTParameters.key.one=KbName('1!');
    PTParameters.key.two=KbName('2@');
    PTParameters.key.three=KbName('3#');
    PTParameters.key.four=KbName('4$');
    
end