function [NX,NY]=trace_contour_correctly_magnify(BW,X,Y,magScale,imsize)

try
    SI = zeros(size(BW));
    Inds = sub2ind(size(BW),X,Y);
    SI(Inds) = 1;

    N = length(X);
    neighborSize = zeros(size(X));
    PointNeighbors = zeros(N,2);


    for p = 1 : N

        stX = max(X(p)-1,1);
        stY = max(Y(p)-1,1);
        finX = min(X(p)+1,size(SI,1));
        finY = min(Y(p)+1,size(SI,2));

        neighborSize(p) = sum(sum(SI(stX:finX,stY:finY)))-1;
    end
    % NX = X;
    % NY = Y;


    T = find(neighborSize ==1);
    s = T(1);
    cur_x = X(s);
    cur_y = Y(s);
    P = [cur_x,cur_y];
    fstep = 'N';
    B = bwtraceboundary(BW,P,fstep);
    X = B(:,1);
    Y = B(:,2);
    N = (length(X)+1)/2;
    EX = X(1:N);
    EY = Y(1:N);
catch XE
    EX = X;
    EY = Y;
end

if magScale~=1
    NX = [];
    NY = [];
    for i = 1 : length(EX)-1
        p1 = [EX(i),EY(i)]*magScale;
        p2 = [EX(i+1),EY(i+1)]*magScale;
        [ind, ~] = drawline(p1,p2,imsize);
        [PX,PY] = ind2sub(imsize,ind);
        NX = [NX,PX];
        NY = [NY,PY];
    end
    NX = NX';
    NY = NY';
else
    NX = EX;
    NY = EY;
end





end
