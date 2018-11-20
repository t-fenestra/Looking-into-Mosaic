
% fitness function for bilinear fit used by moments.m

function f=bilinearfit(x,t,m)

f = 0;
for i=1:length(t),
    if t(i)<x(4),
	f=f+((m(i)-(x(1)*t(i)+x(2)))^2);
    else
 	d = x(1)*x(4)+x(2)-x(3)*x(4);
	f=f+((m(i)-(x(3)*t(i)+d))^2);
    end 
end

if x(4) >= t(length(t)),
    f = 1e8*f;
end

return
