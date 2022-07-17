function IClustTotal=breakToEllipses(ImageSize,pixelList)

O = zeros(ImageSize);
O(pixelList) = 1;
s = regionprops(O,'BoundingBox');
apoX = round(s.BoundingBox(2));
eosX = min(size(O,1),apoX+round(s.BoundingBox(4)));
apoY = round(s.BoundingBox(1));
eosY = min(size(O,2),apoY+round(s.BoundingBox(3)));
Ocrop = O(apoX:eosX,apoY:eosY);
    
IClust = runMergeFitting(Ocrop,1);%DEFA method
IClustTotal = zeros(ImageSize);

M = max(IClustTotal(:));
Bit = IClust > 0;
IClust = IClust+M*Bit;
IClustTotal(apoX:eosX,apoY:eosY) = IClustTotal(apoX:eosX,apoY:eosY)+IClust;
% totEll(i).EL = EL;
% totEll(i).NUMEllipses = NUMEllipses;
end