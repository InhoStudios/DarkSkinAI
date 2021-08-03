sog = imread('images/img11.jpg');

lab = rgb2lab(sog);
a = lab(:, :, 2);
b = lab(:, :, 3);

aAvg = mean(a(:));
bAvg = mean(b(:));

aDev = std(a(:));
bDev = std(b(:));

disp(strcat("average a*: ", string(aAvg), ", dev: ", string(aDev)));
disp(strcat("average b*: ", string(bAvg), ", dev: ", string(bDev)));

colorcloud(sog)

% plot(a, b);

% disp(strcat("a: ", string(a), ", b: ", string(b)));