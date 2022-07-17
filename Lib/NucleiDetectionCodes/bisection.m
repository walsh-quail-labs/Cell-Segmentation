function result = bisection(I)

finished = 0;
x_0 = 0.00001;
x_1 = 100000;
tol = 0.01;

while finished ~= 1
    middle = (x_0+x_1)/2;
    if(abs(middle-x_0) < tol)
        result = middle;
        finished = 1;
    elseif ((f(I,middle)*f(I,x_0)) < 0)
        x_1 = middle;
    else
        x_0 = middle;
    end
end

end 