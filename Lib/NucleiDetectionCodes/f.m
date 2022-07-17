function result = f(I,factor)


J = I*factor;
V = sort(J(:),'descend');
n = floor(length(V)/20);
result = sum(V(1:n))/(n*35000) - 1;


end