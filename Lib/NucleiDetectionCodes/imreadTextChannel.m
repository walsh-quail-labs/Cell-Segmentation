function result = imreadTextChannel(Pano,headerIndex)


allData = Pano.data;

sizeI2 = max(allData(:,4))+1;
sizeI1 = max(allData(:,5))+1;


Y = allData(:,4);
X = allData(:,5);
I191 = zeros(sizeI1,sizeI2);

for itr = 1:length(X)
%     try
    if (X(itr)+1 > 0 && X(itr)+1 < size(I191,1) && Y(itr)+1 > 0 && Y(itr)+1 < size(I191,2)) 
        if ~isempty(allData(itr,headerIndex))
            I191(X(itr)+1,Y(itr)+1) = allData(itr,headerIndex);
        end
    end
%     catch XE
%         allData(itr,headerIndex)
%         I191(X(itr)+1,Y(itr)+1)
%     end
    
end

sensity = 1.5;
result = uint16(I191)*uint16(bisection(I191))*sensity;


end


