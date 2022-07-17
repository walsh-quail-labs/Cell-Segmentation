function result = imreadTiff(fileName)

I = imread(fileName);
result = I*bisection(I);

end