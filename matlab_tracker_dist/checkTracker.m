%
% CHECKTRACKER
%    Check tracker performance by plotting the setected particles and 
%    trajectories in overlay with the original movie frames.
%
% SYNTAX: 
%    checkTracker(instub,first,last,infmt,ext,framewise,rescale,resultfile,
%                 cutlength,numtraj)
% 
% INPUT ARGUMENTS:
%    instub          location and file name stub of input files
%    first           number of first image to process
%    last            number of last image to process
%    infmt           numbering format of input file names (see below)
%    ext             file extension of input and output
%    framewise       wait for keypress after every frame?
%    rescale         normalize images before display?
%    resultfile      name of the tracker result file containing the
%                    trajectories and particle detections
%    cutlength       only trajectories longer than cutlength frames are
%                    considered
%    numtraj         the ntraj longest trajectories will be taken 
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
%    Ivo Sbalzarini, ETHZ, August 15, 2003
%
% VERSION:
%    0.1 rev.B
%

%-------------------------------------------------------------------
% No user-adjustable parameters below this line
%-------------------------------------------------------------------

function checkTracker(instub,first,last,infmt,ext,framewise,rescale,resultfile,cutlength,numtraj)

% argument validity checks
if or(nargin<10, nargin>10),
    disp('ERROR: wrong number of input arguments. See "help checkTracker" !');
    return;
end;
if length(instub)<2,
    disp('ERROR: instub must be a non-empty string !');
    return;
end;
if length(resultfile)<2,
    disp('ERROR: resultfile must be a non-empty string !');
    return;
end;
if or(first<0, length(first)>1),
    disp('ERROR: first must be a non-negative integer !');
    return;
end;
if cutlength < 1
    disp('cutlength must be larger than 0. Reset to 1.');
end;
if numtraj < 1
    disp('numtraj must be larger than 0. Reset to 1.');
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

data = loadTraj(resultfile,cutlength);
Ntraj = length(data);
if Ntraj < 1,
    disp('No trajectories read.')
    return;
end;

% sort trajectories by length
trajlen = zeros(Ntraj,1);
for itraj=1:Ntraj,
    trajlen(itraj) = size(data{itraj},1);
end
[lensort,sortidx] = sort(trajlen);   % sort on ascending order
figure(10)
hist(lensort,Ntraj)
title('Histogram of trajectory lengths')
if numtraj > Ntraj,
    numtraj = Ntraj;
end;
disp(sprintf('%d longest trajectories will be included in analysis',numtraj))

disp(' ');

% save trajectories in files
for it=1:numtraj,
    % get it-longest trajectory
    t = sortidx(Ntraj-it+1);
    % save trajectory to file
    outfile = sprintf('SPT_onlyone_%3.3d.xy',it);
    pdet = data{t};
    save(outfile,'pdet','-ASCII')
end
disp(sprintf('Extracted %d trajectories to xy files',numtraj))

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
    imshow(b);

    % find and plot all particle detections and trajectories in this frame
    for it=1:numtraj,
	% get it-longest trajectory
	t = sortidx(Ntraj-it+1);
	% current particle detections
	pdet = data{t}(find(data{t}(:,1)==img),2:3);
	figure(1)
	hold on
	plot(pdet(:,2)+1,pdet(:,1)+1,'ro')
	% trajectories
	if data{t}(length(data{t}(:,1)),1) < img,
	    % trajectory t is completed by now => add to plot in green
            plot(data{t}(:,3)+1,data{t}(:,2)+1,'g-');
	elseif and(data{t}(1,1)<=img, data{t}(length(data{t}(:,1)),1)>=img),
	    % trajectory is active => add to plot using red lines
	    bp = find(data{t}(:,1)==img);
            plot(data{t}(1:bp,3)+1,data{t}(1:bp,2)+1,'r-');
	end;
    end;
    figure(1)
    hold off

    if framewise,
	disp(sprintf('Frame %d of %d. Press any key to proceed...',img,last)) 
	pause;
    end;
end;

