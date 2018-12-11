%====================================================================== 
%
% LL2MATRIX: Converts trajectories in the linked-list representation
%            to matrix form
%
% SYNTAX:  matrices = msd(peaks)
%
% INPUTS:  peaks   trajectories in linked list form as:
%
%         peaks{t}(:,1)    x (col)-positions at time t
%         peaks{t}(:,2)    y (row)-positions at time t
%         peaks{t}(:,3)    zero order intensity moments
%         peaks{t}(:,4)    second order intensity moments
%         peaks{t}(:,6)    linked list index to the same
%                          particle at time t+1
%         trajLen          minimum trajectory length to be further
%                          processed
%
% The function returns a cell list of matrices where matrices{i}
% is the i-th trajectory in the form of an N times 2 matrix
% where N is the length of the trajectory and each row contains
% a [x,y] vector of positions.
%
% Ivo Sbalzarini, 26.3.2003
% Institute of Computational Science, Swiss Federal
% Institute of Technology (ETH) Zurich. 
% E-mail: sbalzarini@inf.ethz.ch
%
%====================================================================== 

function matrices_selected = ll2matrix(peaks,trajLen)

% convert linked list trajectories into a list of (x,y) matrices
matrices = [];
for ii=1:length(peaks)         % loop over all frames
    npart = length(peaks{ii}(:,1));
    for ipart=1:npart,         % loop over all particles
	iframe = ii;
	next = peaks{iframe}(ipart,6);
	if (next > 0),         % if particle starts a trajectory,
	                       % follow it
	    matrix = [iframe,peaks{iframe}(ipart,1), peaks{iframe}(ipart,2),peaks{iframe}(ipart,3),peaks{iframe}(ipart,4)];
	    peaks{iframe}(ipart,6) = -1;   % mark used
	    while (next > 0),  % convert to matrix form
		iframe = iframe + 1;
		matrix = [matrix; iframe, peaks{iframe}(next,1), peaks{iframe}(next,2),peaks{iframe}(next,3),peaks{iframe}(next,4)];
		nextold = next;
		next = peaks{iframe}(next,6);    % mark used
		peaks{iframe}(nextold,6) = -1;
	    end;
	    matrix = {matrix};
	    matrices = [matrices, matrix];
	end;
    end;

    
matrices_selected=[] 
for jj=1:length(matrices)
    % delete trajectories with the length less than trajLen
    if size(matrices{jj},1)>trajLen
        matrices_selected=[matrices_selected,{matrices{jj}}]
    end
end;    
    
    
end;

return

