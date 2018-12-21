% PREPAREIMAGES:
%    reads images, normalizes to global extrema und stores
%    images again using fixed-width numbering format
%    optionally displays every frame.
%
% SYNTAX: 
%    function prepareImages(instub,first,last,infmt,outstub,ext,outfmt,viz)
% 
% INPUT ARGUMENTS:
%    instub          location and file name stub of input files
%    first           number of first image to process
%    last            number of last image to process
%    infmt           numbering format of input file names (see below)
%    outstub         location and file name stub of output files
%    ext             file extension of input and output
%    outfmt          numbering format of output file names (see below)
%    viz             =1 to show every frame, =0 to show nothing
%
% RETURN VALUE:
%    none.
%
% FORMATS:
%    infmt and outfmt specify the file numbering format for input and
%    output as follows: if the parameter is equal to an integer number >0
%    is specifies the number of digits in a fixed numbering (e.g. infmt=3
%    -> 001, 002, ..., 010, 011, ..., 100, 101, ..., 999) if the parameter
%    is equal to the string 'free', the numbering is free format (i.e.
%    infmt='free' -> 1, 2, 3, ..., 10, 11, ..., 100, 101, ...).
%
% AUTHOR:
%    Ivo Sbalzarini, ETHZ, July 8, 2003
%
% VERSION:
%    0.1 rev.A
%

%-------------------------------------------------------------------
% No user-adjustable parameters below this line
%-------------------------------------------------------------------

function prepareImages(instub,first,last,infmt,outstub,ext,outfmt,viz)

    % argument validity checks
    if or(nargin<8, nargin>8),
	disp('ERROR: wrong number of input arguments. See "help prepareImages" !');
	return;
    end;
    if length(instub)<2,
	disp('ERROR: instub must be a non-empty string !');
	return;
    end;
    if length(outstub)<2,
	disp('ERROR: outstub must be a non-empty string !');
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
    if or(and(length(round(outfmt))>1, ~strcmp(outfmt,'free')),round(outfmt)<1),
	if ~strcmp(outfmt,'free'), outfmt = round(outfmt); end;
	disp('ERROR: outfmt must be a positive integer or "free"');
	return;
    end;
    if and(viz ~= 0, viz ~= 1),
	disp('ERROR: viz must be either 0 or 1 !');
	return;
    end;
    if sum(strcmp(ext,{'tif','jpg','bmp','png','hdf','pcx','xwd'})) ~= 1,
	disp('ERROR: ext must be one of the following: tif,jpg,bmp,png,hdf,pcx,xwd');
	return;
    end;

    % read files and determine global extrema
    imax = 0;
    imin = Inf;
    disp('Scaning images for global optima. Please wait...');
    for img=round(first):round(last),
	file = getFileName(img,infmt,instub,ext);
	a = double(imread(file));
	u = max(max(a));
	l = min(min(a));
	if u>imax, imax=u; end;
	if l<imin, imin=l; end;
	disp(sprintf('     %d of %d',img,last));
    end;

    disp(' ');

    % second read: normalize images and store using new file names
    for img=round(first):round(last),
	file = getFileName(img,infmt,instub,ext);
	a = double(imread(file));
	b = (a-imin)/(imax-imin);
	outfile = getFileName(img,outfmt,outstub,ext);
	imwrite(b,outfile,ext)
	if viz,
	    disp('Displaying movie in figure 1. Press any key to proceed to next frame');
	    figure(1)
	    clf
	    imshow(b)
	    pause
	end;
    end;

    return;
% end;         function prepareImages

%-----------------------------------------------------------------
% construct formated file name from user input
%-----------------------------------------------------------------

function fname = getFileName(index,fmt,stub,ext)
    if fmt=='free',
	if index < 10,
	    fname = sprintf('%s%1.1d.%s',stub,index,ext);
        elseif index < 100,
	    fname = sprintf('%s%2.2d.%s',stub,index,ext);
	elseif index < 1000,
	    fname = sprintf('%s%3.3d.%s',stub,index,ext);
	elseif index < 10000,
	    fname = sprintf('%s%4.4d.%s',stub,index,ext);
	elseif index < 100000,
	    fname = sprintf('%s%5.5d.%s',stub,index,ext);
	else
	    fname = sprintf('%s%6.6d.%s',stub,index,ext);
        end;
    else
	fname = sprintf(strcat('%s%',sprintf('%d',fmt),'.',sprintf('%d',fmt),'d.%s'),stub,index,ext);
    end;
    return;
% end;   function getFileName

