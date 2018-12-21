%% Create movie from images
% code from https://de.mathworks.com/matlabcentral/answers/153925-how-to-make-a-video-from-images
function [] = Create_movie_for_stack(ImageStack,fps,OutputFile,grey_map)
        % ImageStack multidimensional array of Images(:,:,frame)
        % fps video frame per second frame
        % OutputFile  video file frame
        % grey_map grey color map same for all images
        
        % create the video writer with 1 fps
        
        writerObj = VideoWriter(OutputFile,'MPEG-4');
        writerObj.FrameRate = fps;

        % open the video writer
        open(writerObj);
 
        % write the frames to the video
        
        for u=1:size(ImageStack,3)
            % convert the image to a frame
            frame = im2frame(ImageStack(:,:,u),grey_map);
            writeVideo(writerObj, frame);   
        end
        close(writerObj);
end
