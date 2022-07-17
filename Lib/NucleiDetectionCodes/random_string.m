
function str = random_string(length, type)

	
	if (type == 1)
		% Upper case letters
		% A = 65 ... Z = 90
		str = char(65 + floor(26 .* rand(length,1)))';
	elseif (type == 2)
		% Lower case letters
		% a = 97 ... z = 122
		str = char(97 + floor(26 .* rand(length,1)))';
	elseif (type == 3)
		% Upper case, lower case, numbers, and special characters
		% !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
		str = char(33 + floor(94 .* rand(length,1)))';
	else
		error(sprintf('Unrecognized "type" argument in %s',mfilename()))
	end
end