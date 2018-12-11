%
% SHOWIMAGES:
%    reads images, normalizes to global extrema and displays them
%    frame by frame.
%
% SYNTAX: 
%    showImages(instub,first,last,infmt,ext,framewise,rescale)
% 
% INPUT ARGUMENTS:
%    instub          location and file name stub of input files
%    first           number of first image to process
%    last            number of last image to process
%    infmt           numbering format of input file names (see below)
%    ext             file extension of input and output
%    framewise       wait for keypress after every frame?
%    rescale         normalize images before display?
%
% RETURN VALUE:
%    none.
%
% FORMATS:
%    infmt specifies the file numbering format for input and
%    output as follows: if the parameter is equal to an integer number >0
%    is specifies the number of digits in a fixed numbering (e.g. infmt=3
%    -> 001, 002, ..., 010, 011, ..., 100, 101, ..., 999) if the parameter
%    is equal to the string 'free', the numbering is free format (i.e.
%    infmt='free' -> 1, 2, 3, ..., 10, 11, ..., 100, 101, ...).
%
% AUTHOR:
%    Ivo Sbalzarini, ETHZ, July 29, 2003
%
% VERSION:
%    0.1 rev.A
%

%-------------------------------------------------------------------
% No user-adjustable parameters below this line
%-------------------------------------------------------------------

function showImages(instub,first,last,infmt,ext,framewise,rescale)

    % argument validity checks
    if or(nargin<7, nargin>7),
	disp('ERROR: wrong number of input arguments. See "help showImages" !');
	return;
    end;
    if length(instub)<2,
	disp('ERROR: instub must be a non-empty string !');
	return;
    end;
    if or(first<0, length(first)>1),
	disp('ERROR: first must be a non-negative integer !');
	return;
    end;
    if or(last<0, length(last)>1),
	disp('ERROR: last must be a non-negative integer !');
	return;
    end;
    if last<first,
	disp('ERROR: last must be larger than first !');
	return;
    end;
    if or(and(length(round(infmt))>1, ~strcmp(infmt,'free')),round(infmt)<1),
	if ~strcmp(infmt,'free'), infmt = round(infmt); end;
	disp('ERROR: infmt must be a positive integer or "free"');
	return;
    end;
    if and(framewise ~= 0, framewise ~= 1),
	disp('ERROR: framewise must be either 0 or 1 !');
	return;
    end;
    if and(rescale ~= 0, rescale ~= 1),
	disp('ERROR: rescale must be either 0 or 1 !');
	return;
    end;
    if sum(strcmp(ext,{'tif','jpg','bmp','png','hdf','pcx','xwd'})) ~= 1,
	disp('ERROR: ext must be one of the following: tif,jpg,bmp,png,hdf,pcx,xwd');
	return;
    end;

    if rescale,
	% read files and determine global extrema
	[imin,imax] = getGlobalExtrema(instub,first,last,infmt,ext);
    end;

    disp(' ');

    % second read: normalize images and display them
    for img=round(first):round(last),
	file = getFileName(img,infmt,instub,ext);
	a = double(imread(file));
	if rescale,
	    b = (a-imin)/(imax-imin);
	else
	    b = a;
	end;
        figure(1)
        clf
        imshow(b)
        if framewise,
            disp(sprintf('Displaying frame %d of %d. Press any key to proceed...',img,last));
	    pause
        end;
    end;

    return;
% end;         function showImages

