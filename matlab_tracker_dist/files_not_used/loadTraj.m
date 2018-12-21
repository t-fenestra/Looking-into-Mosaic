% LOADTRAJ
%loads trajectory data from tracker text output file
%
% syntax:   data = loadTraj('filename',cutlength)
%
% inputs:   filename    name of the text file to be read
%           cutlength   only keep trajectories longer than cutlength frames
%
% output:   data        trajectories in the format described below.
%
% loads the trajectory x,y-data in file 'filename' and returns a list
% of arrays data{} where data{i} is the i-th trajectory of the data
% set. data{i}(:,1) is the frame number, data{i}(:,2) is the x position 
% and data{i}(:,3) the y position.
%
% Ivo Sbalzarini, July 29, 2003
%

function data = loadTraj(filename,cutlength)

% initialize empty arrays
data = {};
block = [];

% check parameters
if or(nargin<2, nargin>2),
    disp('ERROR: wrong number of input arguments. See "help loadTraj" !');
    return;
end;
if cutlength < 1,
    disp('loadTraj: cutlength must be at least 1. Reset to 1.')
end;

% open file 
infile = fopen(filename,'rt');
if infile == -1,
   disp('Cannot open trajectory data file');
   return;
end;

% read file line by line
k = 1;              % initialize trajectory counter
while 1
   % get line
   line = fgetl(infile);
   if ~is_comment(line),
       % if line is shorter than 4 characters, consider it empty
       if length(line) < 4,
	  % add last trajectory to data set if of sufficient length
	  if size(block,1) > cutlength,
	     data = {data{:} block};
	  end; 
	  % increase trajectory counter
	  k = k + 1;
	  % start with empty trajectory block again
	  block = [];
       else     % if we are still in the same block
	  % decode line 
	  a = sscanf(line, '%f %f %f');
	  % add numbers to current trajectory and uniform unity time interval
	  block = [block; a(1:3)'];
       end;   
   end;
   % if end of file is reached, store last data and exit loop
   if feof(infile),
      if size(block,1) > cutlength,
         data = {data{:} block};
      end; 
      k = k + 1;
      break;
   end;
end;
% close file
fclose(infile);
disp(sprintf('%d trajectories read from file %s',length(data),filename))

return;

%
% checks if a line is a coment or not
%

function ic = is_comment(line)

    ic = 0;
    if (length(line) < 1),
	return;
    end;
    pos = 1;
    while and(pos<=length(line),ic == 0),
	if line(pos) == '%',
	    ic = 1;
	end;
	if double(line(pos)) > 32,
	    break;
	end;
	pos = pos+1;
    end;

return;

