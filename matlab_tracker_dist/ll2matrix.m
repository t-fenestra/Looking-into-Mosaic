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
%         peaks{t}(:,6)    linked list index to the same
%                          particle at time t+1
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

function matrices = ll2matrix(peaks)

% convert linked list trajectories into a list of (x,y) matrices
matrices = [];
for ii=1:length(peaks)         % loop over all frames
    npart = length(peaks{ii}(:,1));
    for ipart=1:npart,         % loop over all particles
	iframe = ii;
	next = peaks{iframe}(ipart,6);
	if (next > 0),         % if particle starts a trajectory,
	                       % follow it
	    matrix = [peaks{iframe}(ipart,1), peaks{iframe}(ipart,2)];
	    peaks{iframe}(ipart,6) = -1;   % mark used
	    while (next > 0),  % convert to matrix form
		iframe = iframe + 1;
		matrix = [matrix; peaks{iframe}(next,1), peaks{iframe}(next,2)];
		nextold = next;
		next = peaks{iframe}(next,6);    % mark used
		peaks{iframe}(nextold,6) = -1;
	    end;
	    matrix = {matrix};
	    matrices = [matrices, matrix];
	end;
    end;
end;

return

