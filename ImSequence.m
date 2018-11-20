function ImSequence(NumberFiles,Image_stack)
    videofig(10, @(frames) redraw(frames, Image_stack));
    % Display initial frame
    redraw(NumberFiles,Image_stack)
end